from django import forms
from .models import Mascota

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
