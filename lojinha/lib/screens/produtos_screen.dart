import 'package:flutter/material.dart';
import '../models/produto.dart';
import '../models/fabricante.dart';
import '../services/api_service.dart';

class ProdutosScreen extends StatefulWidget {
  const ProdutosScreen({super.key});

  @override
  State<ProdutosScreen> createState() => _ProdutosScreenState();
}

class _ProdutosScreenState extends State<ProdutosScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Produto>> futureProdutos;
  List<Fabricante> listaFabricantes = [];

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  void _carregarDados() async {
    setState(() {
      futureProdutos = apiService.getProdutos();
    });
    try {
      final fabricantes = await apiService.getFabricantes();
      if (mounted) {
        setState(() {
          listaFabricantes = fabricantes;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar fabricantes: $e");
    }
  }

  void _mostrarDialogoFormulario({Produto? produtoAtual}) {
    if (listaFabricantes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastre pelo menos um Fabricante primeiro!')),
      );
      return;
    }

    final nomeController = TextEditingController(text: produtoAtual?.nome ?? '');
    final custoController = TextEditingController(text: produtoAtual?.valorCusto?.toString() ?? '');
    final vendaController = TextEditingController(text: produtoAtual?.valorVenda.toString() ?? '');
    final validadeController = TextEditingController(text: produtoAtual?.validade ?? '');
    
    String fabricanteSelecionado = produtoAtual?.fabricanteId ?? listaFabricantes.first.idFabricante!;
    final bool isEdicao = produtoAtual != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEdicao ? 'Editar Produto' : 'Novo Produto'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome do Produto *')),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Fabricante *'),
                      initialValue: fabricanteSelecionado,
                      items: listaFabricantes.map((fab) {
                        return DropdownMenuItem(
                          value: fab.idFabricante,
                          child: Text(fab.nome),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          fabricanteSelecionado = newValue!;
                        });
                      },
                    ),
                    TextField(
                      controller: custoController, 
                      decoration: const InputDecoration(labelText: 'Valor de Custo (Ex: 10.50)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextField(
                      controller: vendaController, 
                      decoration: const InputDecoration(labelText: 'Valor de Venda * (Ex: 25.90)'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    TextField(
                      controller: validadeController, 
                      decoration: const InputDecoration(labelText: 'Validade (AAAA-MM-DD)', hintText: 'Ex: 2026-12-31'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (nomeController.text.isEmpty || vendaController.text.isEmpty) return;

                    final novoProduto = Produto(
                      nome: nomeController.text,
                      fabricanteId: fabricanteSelecionado,
                      valorCusto: custoController.text.isNotEmpty ? double.tryParse(custoController.text) : null,
                      valorVenda: double.parse(vendaController.text),
                      validade: validadeController.text,
                    );

                    try {
                      if (isEdicao) {
                        await apiService.atualizarProduto(produtoAtual.idProduto!, novoProduto);
                      } else {
                        await apiService.criarProduto(novoProduto);
                      }

                      if (!dialogContext.mounted) return;
                      Navigator.pop(dialogContext);

                      if (!mounted) return;
                      _carregarDados();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Salvo com sucesso!')));
                    } catch (e) {
                      if (!dialogContext.mounted) return;
                      ScaffoldMessenger.of(dialogContext).showSnackBar(const SnackBar(content: Text('Erro ao salvar.')));
                    }
                  },
                  child: const Text('Salvar'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _deletarProduto(String id) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Atenção'),
        content: const Text('Excluir este produto?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await apiService.deletarProduto(id);
                
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                
                if (!mounted) return;
                _carregarDados();
              } catch (e) {
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciar Produtos')),
      body: FutureBuilder<List<Produto>>(
        future: futureProdutos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Erro ao carregar produtos.'));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Nenhum produto cadastrado.'));

          List<Produto> produtos = snapshot.data!;

          return ListView.builder(
            itemCount: produtos.length,
            itemBuilder: (context, index) {
              final prod = produtos[index];
              String nomeFab = listaFabricantes.firstWhere((f) => f.idFabricante == prod.fabricanteId, orElse: () => Fabricante(nome: 'Desconhecido')).nome;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.inventory_2),
                  ),
                  title: Text(prod.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('R\$ ${prod.valorVenda.toStringAsFixed(2)} • $nomeFab'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _mostrarDialogoFormulario(produtoAtual: prod)),
                      IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => _deletarProduto(prod.idProduto!)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoFormulario(),
        child: const Icon(Icons.add),
      ),
    );
  }
}