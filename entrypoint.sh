#!/bin/bash
set -e  # Detener el script en caso de error

# Configuración básica
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

# Crear un archivo de salud temporal para verificar que el servidor está funcionando
echo "from django.http import HttpResponse\nfrom django.views.decorators.http import require_GET\n\n@require_GET\ndef health_check(request):\n    return HttpResponse('OK', status=200)" > /tmp/healthcheck.py

# Iniciar Gunicorn en segundo plano
echo "=== INICIANDO SERVIDOR EN EL PUERTO $PORT ==="
gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 1 \
    --timeout 120 \
    --log-level debug \
    --access-logfile - \
    --error-logfile - \
    --daemon

# Esperar a que Gunicorn esté listo
sleep 5

# Verificar que el servidor está funcionando
if ! curl -s http://localhost:$PORT/health/ > /dev/null; then
    echo "ERROR: No se pudo conectar al servidor"
    exit 1
fi

echo "=== SERVIDOR INICIADO CORRECTAMENTE ==="

# Mantener el contenedor en ejecución
tail -f /dev/null
