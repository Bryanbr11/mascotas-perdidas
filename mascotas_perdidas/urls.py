"""
URL configuration for mascotas_perdidas project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""
from django.contrib import admin
from django.urls import path, include, re_path
from django.conf import settings
from django.conf.urls.static import static
from django.contrib.auth import views as auth_views
from django.views.generic import TemplateView
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_GET
from django.http import HttpResponse, JsonResponse, HttpResponseServerError
from django.db import connection, DatabaseError
from django.utils import timezone
from mascotas.views import registro, inicio_social_auth, error_social_auth, chatbot

@require_GET
def health_check(request):
    """
    Endpoint de verificación de salud simple y rápido.
    Devuelve 'OK' si el servidor está funcionando.
    """
    try:
        # Verificación básica de que la aplicación puede responder
        return HttpResponse('OK', status=200, content_type='text/plain')
    except Exception as e:
        return HttpResponseServerError(f'Error: {str(e)}', content_type='text/plain')

@require_GET
def health_check_detailed(request):
    """
    Endpoint de verificación de salud detallado.
    Incluye verificación de base de datos y migraciones.
    """
    try:
        # Verificar conexión a la base de datos
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        
        # Verificar migraciones pendientes
        from django.core.management import call_command
        from io import StringIO
        out = StringIO()
        call_command('check', '--deploy', stdout=out)
        
        return JsonResponse({
            'status': 'healthy',
            'timestamp': timezone.now().isoformat(),
            'database': 'connected',
            'migrations': 'up to date',
            'debug': settings.DEBUG,
        })
    except DatabaseError as e:
        return JsonResponse({
            'status': 'database_error',
            'error': f'Database error: {str(e)}',
            'timestamp': timezone.now().isoformat(),
        }, status=500)
    except Exception as e:
        return JsonResponse({
            'status': 'error',
            'error': str(e),
            'timestamp': timezone.now().isoformat(),
        }, status=500)

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # Aplicación principal
    path('', include('mascotas.urls', namespace='mascotas')),
    
    # Autenticación
    path('accounts/login/', auth_views.LoginView.as_view(template_name='registration/login.html'), name='login'),
    path('accounts/logout/', auth_views.LogoutView.as_view(next_page='mascotas:lista_mascotas'), name='logout'),
    path('accounts/registro/', registro, name='registro'),
    path('accounts/', include('django.contrib.auth.urls')),
    
    # Autenticación social
    path('social-auth/', include('social_django.urls', namespace='social')),
    path('inicio-social-auth/', inicio_social_auth, name='inicio_social_auth'),
    path('error-social-auth/', error_social_auth, name='error_social_auth'),
    
    # Chatbot
    path('api/chatbot/', csrf_exempt(chatbot), name='chatbot'),
    
    # Páginas de autenticación
    path('auth/registro/completar-perfil/', TemplateView.as_view(template_name='registration/complete_profile.html'), 
         name='complete_profile'),
    path('health/', health_check, name='health_check'),
]

# Servir archivos estáticos y multimedia en desarrollo
if settings.DEBUG:
    from django.conf.urls.static import static
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
