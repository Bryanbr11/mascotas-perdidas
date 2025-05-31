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

# Crear directorio para la base de datos SQLite
mkdir -p /app/db

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

# Iniciar Gunicorn
echo "=== INICIANDO SERVIDOR EN EL PUERTO $PORT ==="
exec gunicorn mascotas_perdidas.wsgi:application \
    --bind 0.0.0.0:$PORT \
    --workers 1 \
    --timeout 120 \
    --log-level debug \
    --access-logfile - \
    --error-logfile -
