from django.db import models
from django.utils import timezone
from django.contrib.auth.models import User

class Mascota(models.Model):
    TIPO_CHOICES = [
        ('perro', 'Perro'),
        ('gato', 'Gato'),
        ('otro', 'Otro'),
    ]

    ESTADO_CHOICES = [
        ('perdido', 'Perdido'),
        ('encontrado', 'Encontrado'),
        ('en_adopcion', 'En adopción'),
    ]

    nombre = models.CharField(max_length=100)
    tipo = models.CharField(max_length=20, choices=TIPO_CHOICES)
    raza = models.CharField(max_length=100, blank=True)
    descripcion = models.TextField()
    estado = models.CharField(max_length=20, choices=ESTADO_CHOICES, default='perdido')
    fecha_perdida = models.DateField('fecha de extravío', default=timezone.now)
    lugar_perdida = models.CharField('lugar donde se perdió', max_length=200)
    telefono_contacto = models.CharField('teléfono de contacto', max_length=20)
    email_contacto = models.EmailField('email de contacto')
    foto = models.ImageField(upload_to='mascotas/', blank=True, null=True)
    fecha_publicacion = models.DateTimeField('fecha de publicación', auto_now_add=True)
    usuario = models.ForeignKey(User, on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.get_tipo_display()}: {self.nombre} - {self.get_estado_display()}"

    class Meta:
        verbose_name = 'mascota'
        verbose_name_plural = 'mascotas'
        ordering = ['-fecha_publicacion']

class PerfilUsuario(models.Model):
    """
    Modelo para almacenar información adicional del usuario
    """
    usuario = models.OneToOneField(User, on_delete=models.CASCADE, related_name='perfil')
    telefono = models.CharField('teléfono', max_length=20, blank=True, null=True)
    direccion = models.CharField('dirección', max_length=255, blank=True, null=True)
    ciudad = models.CharField(max_length=100, blank=True, null=True)
    pais = models.CharField('país', max_length=100, blank=True, null=True)
    foto_perfil = models.ImageField(upload_to='perfiles/', blank=True, null=True)
    fecha_nacimiento = models.DateField('fecha de nacimiento', blank=True, null=True)
    biografia = models.TextField('biografía', blank=True, null=True)
    sitio_web = models.URLField('sitio web', blank=True, null=True)
    twitter = models.CharField('usuario de Twitter', max_length=100, blank=True, null=True)
    facebook = models.URLField('perfil de Facebook', blank=True, null=True)
    instagram = models.CharField('usuario de Instagram', max_length=100, blank=True, null=True)
    
    # Campos para autenticación social
    social_auth = models.JSONField('datos de autenticación social', default=dict, blank=True)
    
    # Campos de auditoría
    creado = models.DateTimeField(auto_now_add=True)
    actualizado = models.DateTimeField(auto_now=True)
    
    def __str__(self):
        return f"Perfil de {self.usuario.username}"
    
    class Meta:
        verbose_name = 'perfil de usuario'
        verbose_name_plural = 'perfiles de usuario'
        ordering = ['usuario__username']

# Señales para crear/actualizar el perfil cuando se crea/actualiza un usuario
from django.db.models.signals import post_save
from django.dispatch import receiver

@receiver(post_save, sender=User)
def crear_perfil_usuario(sender, instance, created, **kwargs):
    """
    Señal para crear automáticamente un perfil cuando se crea un usuario
    """
    if created:
        PerfilUsuario.objects.get_or_create(usuario=instance)

@receiver(post_save, sender=User)
def guardar_perfil_usuario(sender, instance, **kwargs):
    """
    Señal para guardar automáticamente el perfil cuando se guarda un usuario
    """
    instance.perfil.save()
