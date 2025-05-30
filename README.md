# Mascotas Perdidas

Aplicación web para reportar y buscar mascotas perdidas.

## Características

- Registro e inicio de sesión de usuarios
- Reporte de mascotas perdidas con fotos
- Búsqueda de mascotas por ubicación y características
- Panel de administración para gestionar reportes

## Requisitos

- Python 3.11.4+
- PostgreSQL (para producción)
- pip

## Instalación

1. Clona el repositorio:
   ```bash
   git clone https://github.com/tu-usuario/mascotas-perdidas.git
   cd mascotas-perdidas
   ```

2. Crea un entorno virtual y actívalo:
   ```bash
   python -m venv venv
   source venv/bin/activate  # En Windows: venv\Scripts\activate
   ```

3. Instala las dependencias:
   ```bash
   pip install -r requirements.txt
   ```

4. Crea un archivo `.env` basado en `.env.example` y configura las variables de entorno.

5. Aplica las migraciones:
   ```bash
   python manage.py migrate
   ```

6. Crea un superusuario:
   ```bash
   python manage.py createsuperuser
   ```

7. Ejecuta el servidor de desarrollo:
   ```bash
   python manage.py runserver
   ```

## Despliegue en Railway

1. Crea una cuenta en [Railway](https://railway.app/)
2. Conecta tu repositorio de GitHub
3. Configura las variables de entorno en Railway:
   - `DEBUG`: `False`
   - `SECRET_KEY`: Tu clave secreta de Django
   - `DATABASE_URL`: URL de la base de datos PostgreSQL (proporcionada por Railway)
   - `RAILWAY_ENV`: `True`

4. Railway detectará automáticamente que es una aplicación Django y configurará el despliegue.

## Variables de entorno

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```
DEBUG=True
SECRET_KEY=tu_clave_secreta_aqui
DATABASE_URL=postgresql://usuario:contraseña@localhost:5432/nombre_bd
```

## Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo `LICENSE` para más detalles.
