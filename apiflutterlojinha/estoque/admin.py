from django.contrib import admin
from estoque.models import Fabricante, Produto, Perfil, Venda, ItemVenda

class FabricanteAdmin(admin.ModelAdmin):
    list_display = ['id_fabricante', 'nome', 'site']

class ProdutoAdmin(admin.ModelAdmin):
    list_display = ['id_produto', 'nome', 'valorVenda', 'fabricante']

class PerfilAdmin(admin.ModelAdmin):
    list_display = ['id_perfil', 'nome', 'sobrenome']

class ItemVendaInline(admin.TabularInline):
    model = ItemVenda
    extra = 1

class VendaAdmin(admin.ModelAdmin):
    list_display = ['id_venda', 'subtotal', 'perfil']
    inlines = [ItemVendaInline]

admin.site.register(Fabricante)
admin.site.register(Produto)
admin.site.register(Perfil)
admin.site.register(Venda)
admin.site.register(ItemVenda)