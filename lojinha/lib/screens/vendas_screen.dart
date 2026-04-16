import 'package:flutter/material.dart';
import '../services/api_service.dart';

class VendasScreen extends StatefulWidget {
  const VendasScreen({super.key});

  @override
  State<VendasScreen> createState() => _VendasScreenState();
}

class _VendasScreenState extends State<VendasScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _futureVendas;

  @override
  void initState() {
    super.initState();
    _futureVendas = _apiService.getVendas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Vendas'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _futureVendas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } 
          else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } 
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma venda registrada ainda.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              )
            );
          }

          final vendas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: vendas.length,
            itemBuilder: (context, index) {
              final venda = vendas[index];
              final List itens = venda['itens'] ?? [];
              final subtotal = venda['subtotal'] ?? 0.0;
              final idCurto = venda['id_venda'].toString().substring(0, 8);

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ExpansionTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.green,
                    child: Icon(Icons.attach_money, color: Colors.white),
                  ),
                  title: Text(
                    'Venda #$idCurto', 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                  subtitle: Text('Total: R\$ ${subtotal.toStringAsFixed(2)}'),
                  children: [
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Itens da Venda:', 
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)
                        ),
                      ),
                    ),
                    ...itens.map((item) {
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.inventory_2, size: 20),
                        title: Text(item['nome_produto'] ?? 'Produto não identificado'),
                        trailing: Text(
                          '${item['qtd']}x', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}