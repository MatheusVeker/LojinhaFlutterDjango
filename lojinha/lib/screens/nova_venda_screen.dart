import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/produto.dart';

class NovaVendaScreen extends StatefulWidget {
  const NovaVendaScreen({super.key});

  @override
  State<NovaVendaScreen> createState() => _NovaVendaScreenState();
}

class _NovaVendaScreenState extends State<NovaVendaScreen> {
  final ApiService _apiService = ApiService();
  
  List<Produto> _produtos = [];
  final List<Map<String, dynamic>> _carrinho = [];
  bool _isLoading = true;

  Produto? _produtoSelecionado;
  int _quantidadeSelecionada = 1;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    try {
      final produtos = await _apiService.getProdutos();
      if (!mounted) return;
      setState(() {
        _produtos = produtos;
        _isLoading = false;
        if (_produtos.isNotEmpty) {
          _produtoSelecionado = _produtos[0];
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
  }

  double get _subtotal {
    double total = 0;
    for (var item in _carrinho) {
      Produto p = item['produto'];
      int qtd = item['qtd'];
      total += (p.valorVenda * qtd);
    }
    return total;
  }

  void _adicionarAoCarrinho() {
    if (_produtoSelecionado == null || _quantidadeSelecionada <= 0) return;

    setState(() {
      int index = _carrinho.indexWhere((item) => item['produto'].idProduto == _produtoSelecionado!.idProduto);
      if (index >= 0) {
        _carrinho[index]['qtd'] += _quantidadeSelecionada;
      } else {
        _carrinho.add({'produto': _produtoSelecionado, 'qtd': _quantidadeSelecionada});
      }
      _quantidadeSelecionada = 1;
    });
  }

  Future<void> _finalizarVenda() async {
    if (_carrinho.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('O carrinho está vazio!')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _apiService.registrarVenda(_carrinho, _subtotal);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venda realizada com sucesso!'), backgroundColor: Colors.green)
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao finalizar venda: $e'), backgroundColor: Colors.red)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realizar Venda'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<Produto>(
                          isExpanded: true,
                          initialValue: _produtoSelecionado,
                          decoration: const InputDecoration(labelText: 'Selecione um Produto', border: OutlineInputBorder()),
                          items: _produtos.map((Produto p) {
                            return DropdownMenuItem<Produto>(
                              value: p,
                              child: Text('${p.nome} (R\$ ${p.valorVenda.toStringAsFixed(2)})'),
                            );
                          }).toList(),
                          onChanged: (Produto? novoProduto) {
                            setState(() => _produtoSelecionado = novoProduto);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<int>(
                          initialValue: _quantidadeSelecionada,
                          decoration: const InputDecoration(labelText: 'Qtd', border: OutlineInputBorder()),
                          items: List.generate(10, (index) => index + 1).map((int qtd) {
                            return DropdownMenuItem<int>(value: qtd, child: Text(qtd.toString()));
                          }).toList(),
                          onChanged: (int? novaQtd) {
                            setState(() => _quantidadeSelecionada = novaQtd ?? 1);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _adicionarAoCarrinho,
                  icon: const Icon(Icons.add_shopping_cart),
                  label: const Text('Adicionar ao Carrinho'),
                ),
                const Divider(thickness: 2),

                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Carrinho de Compras', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: _carrinho.isEmpty
                      ? const Center(child: Text('Nenhum item adicionado.', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: _carrinho.length,
                          itemBuilder: (context, index) {
                            final item = _carrinho[index];
                            final Produto p = item['produto'];
                            final int qtd = item['qtd'];
                            return ListTile(
                              leading: const Icon(Icons.check_circle, color: Colors.green),
                              title: Text(p.nome),
                              subtitle: Text('$qtd x R\$ ${p.valorVenda.toStringAsFixed(2)}'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() => _carrinho.removeAt(index));
                                },
                              ),
                            );
                          },
                        ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Subtotal:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          Text('R\$ ${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: _finalizarVenda,
                        child: const Text('Finalizar', style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}