"""
WSGI config for mascotas_perdidas project.
"""

import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mascotas_perdidas.settings')

application = get_wsgi_application()
