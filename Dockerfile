FROM python:3.11-slim

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


# Puerto expuesto
EXPOSE 8000

# Comando de inicio
CMD ["gunicorn", "mascotas_perdidas.wsgi:application", "--bind", "0.0.0.0:8000"]
