FROM python:3.11-slim

# Variables de entorno
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PORT=8000

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instalar dependencias de Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el proyecto
COPY . .

# Recolectar archivos estáticos
RUN python manage.py collectstatic --noinput

# Puerto expuesto
EXPOSE $PORT

# Comando de inicio
CMD ["gunicorn", "mascotas_perdidas.wsgi:application", "--bind", "0.0.0.0:$PORT"]
