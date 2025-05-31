#!/bin/bash

# Configuración básica
export PYTHONUNBUFFERED=1

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

# Mostrar la estructura del proyecto
echo "=== ESTRUCTURA DEL PROYECTO ==="
ls -la
echo "============================"

# Instalar dependencias si es necesario
echo "=== INSTALANDO DEPENDENCIAS ==="
pip install -r requirements.txt
echo "============================"

# Aplicar migraciones
echo "=== APLICANDO MIGRACIONES ==="
python manage.py migrate --noinput
echo "============================"

# Recolectar archivos estáticos
echo "=== RECOLECTANDO ARCHIVOS ESTÁTICOS ==="
python manage.py collectstatic --noinput
echo "======================================"

# Verificar que la aplicación puede iniciar
echo "=== VERIFICANDO LA APLICACIÓN ==="
python manage.py check --deploy
echo "=============================="

# Iniciar el servidor de desarrollo de Django
echo "=== INICIANDO SERVIDOR DE DESARROLLO ==="
python manage.py runserver 0.0.0.0:$PORT
