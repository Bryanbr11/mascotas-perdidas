#!/bin/bash

# Habilitar modo de depuración
export PYTHONUNBUFFERED=1

# Crear directorios necesarios
mkdir -p /var/log/app
mkdir -p /tmp/staticfiles
mkdir -p /tmp/media

# Redirigir salida estándar y de error a archivos de log
exec 1> >(tee -a /var/log/app/app_stdout.log) 2> >(tee -a /var/log/app/app_stderr.log >&2)

# Mostrar información del sistema
echo "=== INFORMACIÓN DEL SISTEMA ==="
uname -a
python --version
pip --version
echo "=============================="

# Mostrar variables de entorno (sin credenciales sensibles)
echo "=== VARIABLES DE ENTORNO ==="
printenv | grep -v -i 'pass\|secret\|key\|token\|pwd' | sort
echo "============================"

# Establecer el directorio de trabajo
cd /app

# Verificar la estructura del proyecto
echo "=== ESTRUCTURA DEL PROYECTO ==="
ls -la
echo "=============================="

# Instalar dependencias si es necesario
echo "=== INSTALANDO DEPENDENCIAS ==="
pip install --upgrade pip
pip install -r requirements.txt
echo "=============================="

# Verificar conexión a la base de datos
echo "=== VERIFICANDO CONEXIÓN A LA BASE DE DATOS ==="
if [ -n "$DATABASE_URL" ]; then
    echo "Intentando conectar a la base de datos..."
    if python -c "
import os
import sys
import psycopg2
from urllib.parse import urlparse

try:
    db_url = os.environ['DATABASE_URL']
    print(f'URL de la base de datos: {db_url}')
    
    # Extraer componentes de la URL
    result = urlparse(db_url)
    dbname = result.path[1:]
    user = result.username
    password = result.password
    host = result.hostname
    port = result.port or 5432
    
    print(f'Conectando a PostgreSQL en {host}:{port}...')
    conn = psycopg2.connect(
        dbname=dbname,
        user=user,
        password=password,
        host=host,
        port=port,
        connect_timeout=10
    )
    print('Conexión exitosa a la base de datos')
    
    # Verificar que podemos ejecutar una consulta simple
    cur = conn.cursor()
    cur.execute('SELECT version();')
    db_version = cur.fetchone()
    print(f'Versión de PostgreSQL: {db_version[0]}')
    
    cur.close()
    conn.close()
    print('Conexión cerrada correctamente')
    
except Exception as e:
    print(f'Error al conectar a la base de datos: {str(e)}')
    sys.exit(1)
"; then
        echo "Conexión exitosa a la base de datos"
    else
        echo "ERROR: No se pudo conectar a la base de datos"
        exit 1
    fi
else
    echo "ADVERTENCIA: No se encontró la variable DATABASE_URL"
fi

# Aplicar migraciones
echo "=== APLICANDO MIGRACIONES ==="
python manage.py migrate --noinput

# Recolectar archivos estáticos
echo "=== RECOLECTANDO ARCHIVOS ESTÁTICOS ==="
python manage.py collectstatic --noinput --clear

# Verificar que el puerto está configurado
if [ -z "$PORT" ]; then
    export PORT=8000
fi

# Verificar que la aplicación puede iniciar
echo "=== VERIFICANDO LA APLICACIÓN ==="
python manage.py check --deploy
echo "================================"

# Crear un archivo de verificación de salud
cat > /app/healthcheck.py << 'EOF'
from http.server import BaseHTTPRequestHandler, HTTPServer
import os
import sys
import json

class HealthCheckHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == '/health/':
            try:
                # Verificar conexión a la base de datos
                from django.db import connections
                db_conn = connections['default']
                db_conn.cursor()
                db_status = 'ok'
            except Exception as e:
                db_status = str(e)
            
            status = 200 if db_status == 'ok' else 503
            self.send_response(status)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            response = {
                'status': 'healthy' if status == 200 else 'unhealthy',
                'database': db_status,
            }
            self.wfile.write(json.dumps(response).encode('utf-8'))
        else:
            self.send_response(404)
            self.end_headers()

def run(server_class=HTTPServer, handler_class=HealthCheckHandler, port=8000):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    httpd.serve_forever()

if __name__ == '__main__':
    run(port=int(os.getenv('HEALTHCHECK_PORT', '8000')))
EOF

# Iniciar el healthcheck en segundo plano
echo "=== INICIANDO HEALTHCHECK ==="
python /app/healthcheck.py &
HEALTHCHECK_PID=$!

trap "echo 'Deteniendo healthcheck...'; kill $HEALTHCHECK_PID" EXIT

# Esperar a que el healthcheck esté listo
echo "Esperando a que el healthcheck esté listo..."
sleep 5

# Verificar que el healthcheck responde
HEALTH_CHECK_URL="http://localhost:$PORT/health/"
if curl --fail --silent --retry 3 --retry-delay 5 "$HEALTH_CHECK_URL" > /dev/null; then
    echo "Healthcheck exitoso"
else
    echo "ERROR: El healthcheck falló"
    exit 1
fi

# Iniciar Gunicorn
echo "=== INICIANDO SERVIDOR EN EL PUERTO $PORT ==="
exec gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 3 \
    --timeout 120 \
    --keep-alive 5 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    --log-level=debug \
    --access-logfile - \
    --error-logfile - \
    --capture-output \
    --enable-stdio-inheritance \
    --worker-class sync \
    --threads 4 \
    --worker-connections 1000
