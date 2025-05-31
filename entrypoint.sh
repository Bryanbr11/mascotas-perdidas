#!/bin/bash
set -e  # Detener el script en caso de error

# Función para imprimir un encabezado
echo_header() {
    echo -e "\n\033[1;34m=== $1 ===\033[0m"
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

# Verificar que el puerto está configurado
if [ -z "$PORT" ]; then
    export PORT=8000
fi

# Configuración de Gunicorn
WORKERS=$(( 2 * $(nproc) + 1 ))
THREADS=2
TIMEOUT=120
KEEP_ALIVE=5

# Iniciar Gunicorn
echo_header "INICIANDO SERVIDOR EN EL PUERTO $PORT"
exec gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers $WORKERS \
    --threads $THREADS \
    --timeout $TIMEOUT \
    --keep-alive $KEEP_ALIVE \
    --worker-class gthread \
    --log-level info \
    --access-logfile - \
    --error-logfile - \
    --capture-output
