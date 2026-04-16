from rest_framework import serializers
from django.contrib.auth.models import User
from estoque import models

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'password']
        extra_kwargs = {'password': {'write_only': True}}

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class FabricanteSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Fabricante
        fields = '__all__'

class ProdutoSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Produto
        fields = '__all__'

class PerfilSerializer(serializers.ModelSerializer):
    class Meta:
        model = models.Perfil
        fields = '__all__'

class ItemVendaSerializer(serializers.ModelSerializer):
    nome_produto = serializers.ReadOnlyField(source='produto.nome')

    class Meta:
        model = models.ItemVenda
        fields = ['id_item', 'venda', 'produto', 'nome_produto', 'qtd']

class VendaSerializer(serializers.ModelSerializer):
    itens = ItemVendaSerializer(many=True, read_only=True)
    
    class Meta:
        model = models.Venda
        fields = '__all__'