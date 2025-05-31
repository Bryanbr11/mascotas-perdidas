from django import forms
from .models import Mascota, PerfilUsuario

class MascotaForm(forms.ModelForm):
    class Meta:
        model = Mascota
        fields = [
            'nombre', 'tipo', 'raza', 'descripcion', 'estado',
            'fecha_perdida', 'lugar_perdida', 'telefono_contacto',
            'email_contacto', 'foto'
        ]
        widgets = {
            'fecha_perdida': forms.DateInput(attrs={'type': 'date'}),
            'descripcion': forms.Textarea(attrs={'rows': 4}),
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Hacer que los campos sean requeridos excepto la raza y la foto
        for field in self.fields:
            if field not in ['raza', 'foto']:
                self.fields[field].required = True


class PerfilUsuarioForm(forms.ModelForm):
    """
    Formulario para editar el perfil de usuario
    """
    class Meta:
        model = PerfilUsuario
        fields = [
            'telefono', 'direccion', 'ciudad', 'pais', 'foto_perfil',
            'fecha_nacimiento', 'biografia', 'sitio_web', 'twitter',
            'facebook', 'instagram'
        ]
        widgets = {
            'fecha_nacimiento': forms.DateInput(
                attrs={'type': 'date', 'class': 'form-control'}
            ),
            'biografia': forms.Textarea(
                attrs={'rows': 4, 'class': 'form-control', 'placeholder': 'Cuéntanos sobre ti...'}
            ),
            'telefono': forms.TextInput(
                attrs={'class': 'form-control', 'placeholder': 'Ej: +56912345678'}
            ),
            'direccion': forms.TextInput(
                attrs={'class': 'form-control', 'placeholder': 'Tu dirección'}
            ),
            'ciudad': forms.TextInput(
                attrs={'class': 'form-control', 'placeholder': 'Tu ciudad'}
            ),
            'pais': forms.TextInput(
                attrs={'class': 'form-control', 'placeholder': 'Tu país'}
            ),
            'sitio_web': forms.URLInput(
                attrs={'class': 'form-control', 'placeholder': 'https://tusitio.com'}
            ),
            'twitter': forms.TextInput(
                attrs={'class': 'form-control', 'placeholder': '@usuario'}
            ),
            'facebook': forms.URLInput(
                attrs={'class': 'form-control', 'placeholder': 'https://facebook.com/tu-perfil'}
            ),
            'instagram': forms.TextInput(
                attrs={'class': 'form-control', 'placeholder': '@usuario'}
            ),
        }
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Hacer que la foto de perfil no sea obligatoria
        self.fields['foto_perfil'].required = False
        
        # Agregar clases de Bootstrap a los campos
        for field_name, field in self.fields.items():
            if field_name != 'foto_perfil':
                field.widget.attrs.update({'class': 'form-control'})
