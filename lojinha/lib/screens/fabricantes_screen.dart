import 'package:flutter/material.dart';
import '../models/fabricante.dart';
import '../services/api_service.dart';

class FabricantesScreen extends StatefulWidget {
  const FabricantesScreen({super.key});

  @override
  State<FabricantesScreen> createState() => _FabricantesScreenState();
}

class _FabricantesScreenState extends State<FabricantesScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Fabricante>> futureFabricantes;

  @override
  void initState() {
    super.initState();
    _carregarFabricantes();
  }

  void _carregarFabricantes() {
    setState(() {
      futureFabricantes = apiService.getFabricantes();
    });
  }

  void _mostrarDialogoFormulario({Fabricante? fabricanteAtual}) {
    final nomeController = TextEditingController(text: fabricanteAtual?.nome ?? '');
    final logoController = TextEditingController(text: fabricanteAtual?.logo ?? '');
    final siteController = TextEditingController(text: fabricanteAtual?.site ?? '');
    final bool isEdicao = fabricanteAtual != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdicao ? 'Editar Fabricante' : 'Novo Fabricante'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nomeController, decoration: const InputDecoration(labelText: 'Nome *')),
                TextField(controller: logoController, decoration: const InputDecoration(labelText: 'Logo (URL)')),
                TextField(controller: siteController, decoration: const InputDecoration(labelText: 'Site (URL)')),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.isEmpty) return;

                final novoFabricante = Fabricante(
                  nome: nomeController.text,
                  logo: logoController.text,
                  site: siteController.text,
                );

                try {
                  if (isEdicao) {
                    await apiService.atualizarFabricante(fabricanteAtual.idFabricante!, novoFabricante);
                  } else {
                    await apiService.criarFabricante(novoFabricante);
                  }
                  
                  if (!dialogContext.mounted) return;
                  Navigator.pop(dialogContext);
                  
                  if (!mounted) return;
                  _carregarFabricantes();
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
      },
    );
  }

  void _deletarFabricante(String id) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Atenção'),
        content: const Text('Tem certeza que deseja excluir este fabricante?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              try {
                await apiService.deletarFabricante(id);
                
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                
                if (!mounted) return;
                _carregarFabricantes();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Deletado!')));
              } catch (e) {
                if (!dialogContext.mounted) return;
                Navigator.pop(dialogContext);
                
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao deletar.')));
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
      appBar: AppBar(title: const Text('Gerenciar Fabricantes')),
      body: FutureBuilder<List<Fabricante>>(
        future: futureFabricantes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar dados.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum fabricante cadastrado.'));
          }

          List<Fabricante> fabricantes = snapshot.data!;

          return ListView.builder(
            itemCount: fabricantes.length,
            itemBuilder: (context, index) {
              final fab = fabricantes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey[200],
                    child: const Icon(Icons.factory),
                  ),
                  title: Text(fab.nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(fab.site != null && fab.site!.isNotEmpty ? fab.site! : 'Sem site'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _mostrarDialogoFormulario(fabricanteAtual: fab),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deletarFabricante(fab.idFabricante!),
                      ),
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