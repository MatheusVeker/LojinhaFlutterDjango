from django.contrib import admin
from django.urls import path, include
from rest_framework import routers
from estoque.api import viewsets

router = routers.DefaultRouter()
router.register(r'fabricantes', viewsets.FabricanteViewSet)
router.register(r'produtos', viewsets.ProdutoViewSet)
router.register(r'perfis', viewsets.PerfilViewSet)
router.register(r'vendas', viewsets.VendaViewSet)
router.register(r'itens-venda', viewsets.ItemVendaViewSet)
router.register(r'usuarios', viewsets.UserViewSet)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('api/', include(router.urls)),
]