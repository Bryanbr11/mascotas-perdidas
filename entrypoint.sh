#!/bin/bash
set -e  # Detener el script en caso de error

# Mostrar información básica
echo "=== INICIANDO APLICACIÓN ==="
python --version

# Instalar dependencias
echo "Instalando dependencias..."
pip install -r requirements.txt

# Aplicar migraciones
echo "Aplicando migraciones..."
python manage.py migrate --noinput

# Recolectar archivos estáticos
echo "Recolectando archivos estáticos..."
python manage.py collectstatic --noinput --clear

# Configuración de Gunicorn
PORT=${PORT:-8000}
WORKERS=$(( 2 * $(nproc) + 1 ))

echo "Iniciando servidor en el puerto $PORT..."

exec gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers $WORKERS \
    --worker-class gthread \
    --threads 2 \
    --timeout 120 \
    --keep-alive 5 \
    --log-level info \
    --access-logfile - \
    --error-logfile -
