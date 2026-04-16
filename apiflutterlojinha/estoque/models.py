from django.db import models
from django.contrib.auth.models import User 
from uuid import uuid4

class Fabricante(models.Model):
    id_fabricante = models.UUIDField(primary_key=True, unique=True, default=uuid4, editable=False)
    nome = models.CharField(max_length=100)
    logo = models.CharField(max_length=255, blank=True, null=True)
    site = models.CharField(max_length=255, blank=True, null=True)
    
    def __str__(self):
        return self.nome

class Perfil(models.Model):
    usuario = models.OneToOneField(User, on_delete=models.CASCADE, related_name='perfil')
    telefone = models.CharField(max_length=20)
    nome = models.CharField(max_length=100)
    sobrenome = models.CharField(max_length=100)

    def __str__(self):
        return f"Perfil de {self.usuario.username}"

class Produto(models.Model):
    id_produto = models.UUIDField(primary_key=True, unique=True, default=uuid4, editable=False)
    nome = models.CharField(max_length=100)
    fabricante = models.ForeignKey(Fabricante, on_delete=models.CASCADE)
    valorCusto = models.FloatField(blank=True, null=True)
    valorVenda = models.FloatField()
    validade = models.DateField(blank=True, null=True)

    def __str__(self):
        return self.nome

class Venda(models.Model):
    id_venda = models.UUIDField(primary_key=True, unique=True, default=uuid4, editable=False)
    subtotal = models.FloatField(blank=True, null=True)
    perfil = models.ForeignKey(Perfil, on_delete=models.CASCADE)

    def __str__(self):
        return f"Venda {self.id_venda}"

class ItemVenda(models.Model):
    id_item = models.UUIDField(primary_key=True, unique=True, default=uuid4, editable=False)
    venda = models.ForeignKey(Venda, on_delete=models.CASCADE, related_name='itens')
    produto = models.ForeignKey(Produto, on_delete=models.CASCADE)
    qtd = models.IntegerField()

    def __str__(self):
        return f"{self.qtd}x {self.produto.nome}"