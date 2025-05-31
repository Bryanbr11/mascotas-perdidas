#!/bin/bash
set -e  # Detener el script en caso de error

# Función para imprimir un encabezado
echo_header() {
    echo -e "\n\033[1;34m=== $1 ===\033[0m"
}

# Función para verificar si un puerto está en uso
wait_for_port() {
    local port=$1
    local max_attempts=30
    local attempt=0
    
    echo "Esperando a que el puerto $port esté disponible..."
    while [ $attempt -lt $max_attempts ]; do
        if nc -z localhost $port; then
            echo "El puerto $port está en uso."
            return 1
        fi
        echo "Intento $((attempt+1))/$max_attempts - Puerto $port no está en uso aún..."
        sleep 1
        attempt=$((attempt+1))
    done
    return 0
}

# Mostrar información del sistema
echo_header "INFORMACIÓN DEL SISTEMA"
uname -a
python --version
pip --version

# Mostrar variables de entorno (sin credenciales sensibles)
echo_header "VARIABLES DE ENTORNO"
printenv | grep -v -i 'pass\|secret\|key\|token\|pwd' | sort

# Establecer el directorio de trabajo
cd /app

# Instalar dependencias
echo_header "INSTALANDO DEPENDENCIAS"
pip install --upgrade pip
pip install --no-cache-dir -r requirements.txt

# Aplicar migraciones
echo_header "APLICANDO MIGRACIONES"
python manage.py migrate --noinput

# Recolectar archivos estáticos
echo_header "RECOLECTANDO ARCHIVOS ESTÁTICOS"
python manage.py collectstatic --noinput --clear

# Crear un archivo de salud temporal para verificar que el servidor está funcionando
echo "from django.http import HttpResponse\nfrom django.views.decorators.http import require_GET\n\n@require_GET\ndef health_check(request):\n    return HttpResponse('OK', status=200, content_type='text/plain')" > /tmp/healthcheck.py

# Verificar que el puerto está configurado
if [ -z "$PORT" ]; then
    export PORT=8000
fi

# Esperar a que el puerto esté disponible
wait_for_port $PORT || {
    echo "ERROR: El puerto $PORT ya está en uso."
    exit 1
}

# Configuración de Gunicorn
WORKERS=$(( 2 * $(nproc) + 1 ))
THREADS=2
TIMEOUT=120
KEEP_ALIVE=5

# Iniciar Gunicorn en segundo plano
echo_header "INICIANDO SERVIDOR EN EL PUERTO $PORT"
gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers $WORKERS \
    --threads $THREADS \
    --timeout $TIMEOUT \
    --keep-alive $KEEP_ALIVE \
    --worker-class gthread \
    --log-level info \
    --access-logfile - \
    --error-logfile - \
    --capture-output \
    --preload \
    --daemon

# Esperar a que Gunicorn esté listo
sleep 10

# Verificar que el servidor está funcionando
if ! curl -s http://localhost:$PORT/health/ > /dev/null; then
    echo "ERROR: No se pudo conectar al servidor en el puerto $PORT"
    exit 1
fi

echo_header "SERVIDOR INICIADO CORRECTAMENTE EN EL PUERTO $PORT"

# Mantener el contenedor en ejecución
tail -f /dev/null
