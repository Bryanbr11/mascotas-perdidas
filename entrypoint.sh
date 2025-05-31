#!/bin/bash

# Exit on error
set -o errexit
set -x  # Habilita modo debug

# Mostrar información del entorno
echo "=== INFORMACIÓN DEL ENTORNO ==="
printenv
echo "=============================="

# Asegurarse de que el directorio de trabajo sea correcto
cd /app

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

echo "=== INICIANDO SERVIDOR EN EL PUERTO $PORT ==="

# Iniciar Gunicorn
exec gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 3 \
    --timeout 120 \
    --log-level=debug \
    --access-logfile - \
    --error-logfile -

# Note: The $PORT variable is automatically set by Railway
