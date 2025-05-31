from django.http import HttpResponse
from django.views.decorators.http import require_GET

@require_GET
def health_check(request):
    """
    Vista simple para verificar el estado del servicio.
    """
    return HttpResponse('OK', status=200)
