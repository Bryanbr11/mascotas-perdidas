#!/bin/bash

# Habilitar modo de depuración
export PYTHONUNBUFFERED=1

# Crear directorios de logs si no existen
mkdir -p /var/log/app

# Redirigir salida estándar y de error a archivos de log
exec 1> >(tee -a /var/log/app/app_stdout.log) 2> >(tee -a /var/log/app/app_stderr.log >&2)

# Mostrar información del sistema
echo "=== INFORMACIÓN DEL SISTEMA ==="
uname -a
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
    conn.close()
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
python manage.py collectstatic --noinput

# Verificar que el puerto está configurado
if [ -z "$PORT" ]; then
    export PORT=8000
fi

# Verificar que la aplicación puede iniciar
echo "=== VERIFICANDO LA APLICACIÓN ==="
python manage.py check --deploy
echo "================================"

# Iniciar Gunicorn
echo "=== INICIANDO SERVIDOR EN EL PUERTO $PORT ==="
exec gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 3 \
    --timeout 600 \
    --log-level debug \
    --access-logfile - \
    --error-logfile - \
    --capture-output \
    --enable-stdio-inheritance \
    --worker-class sync \
    --threads 4 \
    --worker-connections 1000 \
    --max-requests 1000 \
    --max-requests-jitter 50
