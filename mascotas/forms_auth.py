from django import forms
from django.contrib.auth.forms import UserCreationForm
from django.contrib.auth.models import User

class RegistroForm(UserCreationForm):
    email = forms.EmailField(
        label='Correo electrónico',
        max_length=254,
        required=True,
        help_text='Requerido. Ingrese una dirección de correo electrónico válida.'
    )
    first_name = forms.CharField(
        label='Nombres',
        max_length=30,
        required=True,
        help_text='Requerido. Ingrese su nombre.'
    )
    last_name = forms.CharField(
        label='Apellidos',
        max_length=30,
        required=True,
        help_text='Requerido. Ingrese su apellido.'
    )

    class Meta:
        model = User
        fields = ('username', 'first_name', 'last_name', 'email', 'password1', 'password2')
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        # Personalizar mensajes de ayuda
        self.fields['username'].help_text = 'Requerido. 150 caracteres o menos. Letras, dígitos y @/./+/-/_ solamente.'
        self.fields['password1'].help_text = (
            'Su contraseña no puede ser demasiado similar a su otra información personal.<br>'
            'Su contraseña debe contener al menos 8 caracteres.<br>'
            'Su contraseña no puede ser una contraseña de uso común.<br>'
            'Su contraseña no puede ser completamente numérica.'
        )
        self.fields['password2'].help_text = 'Ingrese la misma contraseña que antes, para verificación.'
        
        # Hacer que los campos sean requeridos
        for field in self.fields.values():
            field.required = True
