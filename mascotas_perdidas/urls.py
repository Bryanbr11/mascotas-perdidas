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
from mascotas.views import registro, inicio_social_auth, error_social_auth, chatbot

urlpatterns = [
    path('admin/', admin.site.urls),
    
    # URLs de autenticación
    path('accounts/login/', auth_views.LoginView.as_view(template_name='registration/login.html'), name='login'),
    path('accounts/logout/', auth_views.LogoutView.as_view(next_page='mascotas:lista_mascotas'), name='logout'),
    path('accounts/registro/', registro, name='registro'),
    
    # Incluir las URLs de la aplicación mascotas
    path('', include('mascotas.urls', namespace='mascotas')),
    
    # URLs de autenticación de Django
    path('accounts/', include('django.contrib.auth.urls')),  # Incluye URLs como password_reset, etc.
    
    # URLs para autenticación social
    path('social-auth/', include('social_django.urls', namespace='social')),
    path('inicio-social/', inicio_social_auth, name='inicio_social_auth'),
    path('error-social/', error_social_auth, name='error_social_auth'),
    
    # Páginas de autenticación
    path('auth/', include('django.contrib.auth.urls')),
    path('auth/registro/completar-perfil/', TemplateView.as_view(template_name='registration/complete_profile.html'), 
         name='complete_profile'),
    
    # API para el chatbot
    path('api/chatbot/', csrf_exempt(chatbot), name='chatbot'),
]

# Servir archivos estáticos y multimedia en desarrollo
if settings.DEBUG:
    from django.conf.urls.static import static
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
