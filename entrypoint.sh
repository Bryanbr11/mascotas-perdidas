#!/bin/bash

# Habilitar modo de depuración
export PYTHONUNBUFFERED=1
exec 1> >(tee -a /var/log/app_stdout.log) 2> >(tee -a /var/log/app_stderr.log >&2)

# Mostrar información del sistema
echo "=== INFORMACIÓN DEL SISTEMA ==="
uname -a
echo "=============================="

# Mostrar variables de entorno
echo "=== VARIABLES DE ENTORNO ==="
printenv | sort
echo "============================"

# Establecer el directorio de trabajo
cd /app

# Verificar la estructura del proyecto
echo "=== ESTRUCTURA DEL PROYECTO ==="
ls -la
echo "=============================="

# Instalar dependencias si es necesario
echo "=== INSTALANDO DEPENDENCIAS ==="
pip install -r requirements.txt
echo "=============================="

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
    --log-level=debug \
    --access-logfile - \
    --error-logfile - \
    --log-file - \
    --capture-output \
    --enable-stdio-inheritance

# Note: The $PORT variable is automatically set by Railway
