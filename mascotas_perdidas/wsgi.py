"""
WSGI config for mascotas_perdidas project.
"""

import os
from django.core.wsgi import get_wsgi_application
from whitenoise import WhiteNoise
from pathlib import Path

# Establecer el módulo de configuración de Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mascotas_perdidas.settings')

# Obtener la aplicación WSGI de Django
application = get_wsgi_application()

# Configurar WhiteNoise para servir archivos estáticos
application = WhiteNoise(
    application,
    root=os.path.join(Path(__file__).resolve().parent.parent, 'staticfiles'),
    prefix='/static/'
)
