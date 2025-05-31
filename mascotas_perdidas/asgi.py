"""
ASGI config for mascotas_perdidas project.
"""

import os
import sys
from pathlib import Path

from django.core.asgi import get_asgi_application

# Asegurar que el directorio del proyecto esté en el path
BASE_DIR = Path(__file__).resolve().parent.parent
if str(BASE_DIR) not in sys.path:
    sys.path.append(str(BASE_DIR))

# Configurar las variables de entorno
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mascotas_perdidas.settings')

# Crear la aplicación ASGI
application = get_asgi_application()

# Asegurar que la aplicación se cargue correctamente
try:
    from django.conf import settings
    print(f"ASGI configurado correctamente. DEBUG={settings.DEBUG}")
except Exception as e:
    print(f"Error al cargar la configuración ASGI: {e}")
    raise
