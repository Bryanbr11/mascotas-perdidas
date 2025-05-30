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
