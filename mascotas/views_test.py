from django.http import HttpResponse
from django.views.decorators.http import require_GET

@require_GET
def test_view(request):
    return HttpResponse("<h1>¡La aplicación está funcionando correctamente!</h1><p>Si puedes ver este mensaje, significa que Django está funcionando bien.</p>", content_type="text/html")
