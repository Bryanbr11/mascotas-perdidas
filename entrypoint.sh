#!/bin/bash
set -e  # Detener el script en caso de error

# Configuración básica
export PYTHONUNBUFFERED=1

# Función para imprimir un encabezado
print_header() {
    echo -e "\n\033[1;34m=== $1 ===\033[0m"
}

# Mostrar información del sistema
print_header "INFORMACIÓN DEL SISTEMA"
uname -a
python --version
pip --version

# Mostrar variables de entorno (sin credenciales sensibles)
print_header "VARIABLES DE ENTORNO"
printenv | grep -v -i 'pass\|secret\|key\|token\|pwd' | sort

# Establecer el directorio de trabajo
cd /app

# Instalar dependencias
print_header "INSTALANDO DEPENDENCIAS"
pip install --upgrade pip
pip install --no-cache-dir -r requirements.txt

# Aplicar migraciones
print_header "APLICANDO MIGRACIONES"
python manage.py migrate --noinput

# Crear superusuario si no existe
if [ -z "$(python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print(User.objects.filter(is_superuser=True).count())" 2>/dev/null)" ] || [ "$(python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print(User.objects.filter(is_superuser=True).count())" 2>/dev/null)" = "0" ]; then
    echo "No se encontró un superusuario. Creando uno..."
    echo "from django.contrib.auth import get_user_model; User = get_user_model(); User.objects.create_superuser('admin', 'admin@example.com', 'admin') if not User.objects.filter(username='admin').exists() else None" | python manage.py shell
fi

# Recolectar archivos estáticos
print_header "RECOLECTANDO ARCHIVOS ESTÁTICOS"
python manage.py collectstatic --noinput --clear

# Verificar que el puerto está configurado
if [ -z "$PORT" ]; then
    export PORT=8000
fi

# Configuración de Gunicorn
WORKERS=$(( 2 * $(nproc --all) + 1 ))
THREADS=2
TIMEOUT=120
KEEP_ALIVE=5

# Iniciar Gunicorn en segundo plano
print_header "INICIANDO SERVIDOR EN EL PUERTO $PORT"
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
    --capture-output \
    --enable-stdio-inheritance \
    --preload

# Nota: Eliminamos el tail -f /dev/null ya que gunicorn se ejecuta en primer plano
