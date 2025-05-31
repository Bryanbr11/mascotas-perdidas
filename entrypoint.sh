#!/bin/bash
set -e

# Aplicar migraciones
python manage.py migrate --noinput

# Recolectar archivos estáticos
python manage.py collectstatic --noinput

# Iniciar el servidor con Gunicorn
exec gunicorn mascotas_perdidas.wsgi:application --bind 0.0.0.0:$PORT
