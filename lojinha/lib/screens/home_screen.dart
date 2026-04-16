import 'package:flutter/material.dart';
import 'fabricantes_screen.dart';
import 'produtos_screen.dart';
import 'vendas_screen.dart';
import 'cadastro_usuario_screen.dart';
import 'nova_venda_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _construirBotaoMenu(BuildContext context, String titulo, IconData icone, {Widget? telaDestino, VoidCallback? onTapCustomizado}) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      child: InkWell(
        onTap: onTapCustomizado ?? () {
          if (telaDestino != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => telaDestino),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icone, size: 40, color: Colors.blue),
              const SizedBox(width: 20),
              Text(
                titulo,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _mostrarMenuVendas(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Menu de Vendas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.list_alt, color: Colors.blue),
                title: const Text('Ver Vendas'),
                subtitle: const Text('Histórico de vendas realizadas'),
                onTap: () {
                  Navigator.pop(context); 
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => VendasScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_shopping_cart, color: Colors.green),
                title: const Text('Realizar Venda'),
                subtitle: const Text('Adicionar produtos ao carrinho'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NovaVendaScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel de Controle'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView( 
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _construirBotaoMenu(
                context, 
                'Fabricantes', 
                Icons.factory, 
                telaDestino: const FabricantesScreen()
              ),
              _construirBotaoMenu(
                context, 
                'Produtos', 
                Icons.inventory, 
                telaDestino: const ProdutosScreen()
              ),
              _construirBotaoMenu(
                context, 
                'Vendas', 
                Icons.point_of_sale, 
                onTapCustomizado: () => _mostrarMenuVendas(context),
              ),
              _construirBotaoMenu(
                context, 
                'Novo Usuário', 
                Icons.person_add, 
                telaDestino: const CadastroUsuarioScreen() 
              ),
            ],
          ),
        ),
      ),
    );
  }
}