from django.shortcuts import render, get_object_or_404, redirect, HttpResponseRedirect
from django.contrib.auth.decorators import login_required
from django.contrib import messages, auth
from django.contrib.auth import login, authenticate
from django.core.paginator import Paginator
from django.urls import reverse
from django.http import HttpResponseForbidden, HttpResponse
from django.views.generic import CreateView
from django.contrib.auth.models import User
from .models import Mascota
from .forms import MascotaForm
from .forms_auth import RegistroForm

def lista_mascotas(request):
    # Obtener todas las mascotas ordenadas por fecha de publicación
    mascotas_list = Mascota.objects.all().order_by('-fecha_publicacion')
    
    # Configurar la paginación (10 mascotas por página)
    paginator = Paginator(mascotas_list, 10)
    page_number = request.GET.get('page')
    mascotas = paginator.get_page(page_number)
    
    return render(request, 'mascotas/lista_mascotas.html', {'mascotas': mascotas})

def detalle_mascota(request, mascota_id):
    mascota = get_object_or_404(Mascota, id=mascota_id)
    return render(request, 'mascotas/detalle_mascota.html', {'mascota': mascota})

@login_required
def nueva_mascota(request):
    if request.method == 'POST':
        print("Método POST recibido")  # Depuración
        print("Datos del formulario:", request.POST)  # Depuración
        print("Archivos:", request.FILES)  # Depuración
        
        form = MascotaForm(request.POST, request.FILES)
        print("Formulario válido?", form.is_valid())  # Depuración
        print("Errores del formulario:", form.errors)  # Depuración
        
        if form.is_valid():
            try:
                mascota = form.save(commit=False)
                mascota.usuario = request.user
                mascota.save()
                print("Mascota guardada con ID:", mascota.id)  # Depuración
                messages.success(request, '¡La mascota ha sido registrada correctamente!')
                return redirect('mascotas:detalle_mascota', mascota_id=mascota.id)
            except Exception as e:
                print("Error al guardar la mascota:", str(e))  # Depuración
                messages.error(request, f'Ocurrió un error al guardar la mascota: {str(e)}')
        else:
            print("Formulario inválido")  # Depuración
            messages.error(request, 'Por favor, corrige los errores en el formulario.')
    else:
        print("Método GET recibido")  # Depuración
        form = MascotaForm()
    
    return render(request, 'mascotas/nueva_mascota.html', {'form': form})

@login_required
def mis_mascotas(request):
    # Obtener solo las mascotas del usuario actual con paginación
    mascotas_list = Mascota.objects.filter(usuario=request.user).order_by('-fecha_publicacion')
    
    # Configurar la paginación (10 mascotas por página)
    paginator = Paginator(mascotas_list, 10)
    page_number = request.GET.get('page')
    mascotas = paginator.get_page(page_number)
    
    return render(request, 'mascotas/mis_mascotas.html', {'mascotas': mascotas})

@login_required
def editar_mascota(request, mascota_id):
    mascota = get_object_or_404(Mascota, id=mascota_id)
    
    # Verificar que el usuario sea el dueño de la mascota
    if mascota.usuario != request.user:
        messages.error(request, 'No tienes permiso para editar esta mascota')
        return redirect('mascotas:detalle_mascota', mascota_id=mascota.id)
    
    if request.method == 'POST':
        form = MascotaForm(request.POST, request.FILES, instance=mascota)
        if form.is_valid():
            try:
                form.save()
                messages.success(request, '¡La información de la mascota ha sido actualizada correctamente!')
                return redirect('mascotas:detalle_mascota', mascota_id=mascota.id)
            except Exception as e:
                messages.error(request, f'Error al actualizar la mascota: {str(e)}')
        else:
            # Mostrar errores de validación
            for field, errors in form.errors.items():
                for error in errors:
                    messages.error(request, f'Error en {field}: {error}')
    else:
        form = MascotaForm(instance=mascota)
    
    return render(request, 'mascotas/editar_mascota.html', {
        'form': form,
        'mascota': mascota
    })

@login_required
def marcar_encontrada(request, mascota_id):
    mascota = get_object_or_404(Mascota, id=mascota_id)
    
    # Verificar que el usuario sea el dueño de la mascota
    if mascota.usuario != request.user:
        return HttpResponseForbidden("No tienes permiso para realizar esta acción")
    
    if request.method == 'POST':
        # Actualizar el estado a 'encontrado'
        mascota.estado = 'encontrado'
        
        # Agregar mensaje de éxito si se proporciona
        mensaje = request.POST.get('mensaje', '').strip()
        if mensaje:
            mascota.descripcion += f"\n\n---\n**Actualización:** {mensaje}"
        
        mascota.save()
        messages.success(request, f'¡Genial! {mascota.nombre} ha sido marcado como encontrado.')
        return redirect('mascotas:detalle_mascota', mascota_id=mascota.id)
    else:
        # Si es una solicitud GET, mostrar un formulario para confirmar
        return render(request, 'mascotas/confirmar_encontrada.html', {'mascota': mascota})

@login_required
def eliminar_mascota(request, mascota_id):
    try:
        mascota = get_object_or_404(Mascota, id=mascota_id)
        
        # Verificar que el usuario sea el dueño de la mascota
        if mascota.usuario != request.user:
            messages.error(request, 'No tienes permiso para realizar esta acción')
            return redirect('mascotas:detalle_mascota', mascota_id=mascota.id)
        
        if request.method == 'POST':
            try:
                nombre_mascota = mascota.nombre
                mascota.delete()
                messages.success(request, f'La mascota {nombre_mascota} ha sido eliminada correctamente.')
                return redirect('mascotas:mis_mascotas')
            except Exception as e:
                messages.error(request, f'Error al eliminar la mascota: {str(e)}')
                return redirect('mascotas:detalle_mascota', mascota_id=mascota.id)
        
        # Si no es una solicitud POST, redirigir al detalle
        return redirect('mascotas:detalle_mascota', mascota_id=mascota.id)
    except Exception as e:
        messages.error(request, f'Error al procesar la solicitud: {str(e)}')
        return redirect('mascotas:lista_mascotas')

def registro(request):
    """
    Vista para el registro de nuevos usuarios
    """
    if request.method == 'POST':
        form = RegistroForm(request.POST)
        if form.is_valid():
            # Guardar el usuario
            user = form.save()
            
            # Autenticar al usuario después del registro
            username = form.cleaned_data.get('username')
            password = form.cleaned_data.get('password1')
            user = authenticate(username=username, password=password)
            
            if user is not None:
                login(request, user)
                messages.success(request, f'¡Bienvenido/a, {user.get_full_name()}! Tu cuenta ha sido creada exitosamente.')
                
                # Redirigir a la página de inicio o a donde desees
                next_url = request.GET.get('next', 'mascotas:lista_mascotas')
                return redirect(next_url)
    else:
        form = RegistroForm()
    
    return render(request, 'registration/registro.html', {'form': form})
