from django.urls import path
from django.contrib.auth.decorators import login_required
from . import views
from .views_test import test_view

app_name = 'mascotas'

urlpatterns = [
    path('test/', test_view, name='test'),
    path('', views.lista_mascotas, name='lista_mascotas'),
    path('nueva/', views.nueva_mascota, name='nueva_mascota'),
    path('<int:mascota_id>/', views.detalle_mascota, name='detalle_mascota'),
    path('<int:mascota_id>/editar/', login_required(views.editar_mascota), name='editar_mascota'),
    path('<int:mascota_id>/eliminar/', login_required(views.eliminar_mascota), name='eliminar_mascota'),
    path('<int:mascota_id>/encontrada/', login_required(views.marcar_encontrada), name='marcar_encontrada'),
    path('mis-mascotas/', login_required(views.mis_mascotas), name='mis_mascotas'),
]
