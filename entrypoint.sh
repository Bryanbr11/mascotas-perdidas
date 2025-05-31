#!/bin/bash

# Habilitar modo de depuración
export PYTHONUNBUFFERED=1

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

# Instalar dependencias
echo "=== INSTALANDO DEPENDENCIAS ==="
pip install --upgrade pip
pip install -r requirements.txt
echo "=============================="

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

# Crear un archivo de healthcheck simple
echo "from django.http import HttpResponse
from django.views.decorators.http import require_GET
@require_GET
def health_check(request):
    return HttpResponse('OK', status=200)" > /app/healthcheck.py

# Añadir la ruta de healthcheck a urls.py
echo "from django.urls import path
from . import healthcheck

urlpatterns = [
    path('health/', healthcheck.health_check, name='health_check'),
] + (urlpatterns if 'urlpatterns' in locals() else [])" > /app/mascotas_perdidas/urls_healthcheck.py

# Iniciar Gunicorn con configuración mínima
echo "=== INICIANDO SERVIDOR EN EL PUERTO $PORT ==="
exec gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 2 \
    --timeout 60 \
    --log-level debug \
    --access-logfile - \
    --error-logfile -
