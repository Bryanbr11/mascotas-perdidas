"""
WSGI config for mascotas_perdidas project.

It exposes the WSGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.1/howto/deployment/wsgi/
"""

import os
from django.core.wsgi import get_wsgi_application
from whitenoise import WhiteNoise
from pathlib import Path

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mascotas_perdidas.settings')

# Aplicación WSGI de Django
django_app = get_wsgi_application()

# Configuración de WhiteNoise
application = WhiteNoise(
    django_app,
    root=os.path.join(Path(__file__).resolve().parent.parent, 'staticfiles'),
    prefix='/static/',
)

# Añadir directorios adicionales para archivos estáticos
application.add_files(os.path.join(Path(__file__).resolve().parent.parent, 'static'), prefix='static/')
application.add_files(os.path.join(Path(__file__).resolve().parent.parent, 'media'), prefix='media/')
