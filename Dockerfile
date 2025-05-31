# Usar una imagen base de Python 3.11
FROM python:3.11-slim

# Establecer variables de entorno
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONPATH=/app \
    PORT=8000 \
    DJANGO_SETTINGS_MODULE=mascotas_perdidas.settings \
    DEBUG=False

# Crear y establecer el directorio de trabajo
WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el proyecto
COPY . .

# Recolectar archivos estáticos
RUN python manage.py collectstatic --noinput

# Hacer ejecutable el script de entrada
RUN chmod +x entrypoint.sh

# Puerto expuesto
EXPOSE $PORT

# Comando de inicio
CMD ["./entrypoint.sh"]
