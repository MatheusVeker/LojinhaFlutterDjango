import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/produto.dart';
import '../models/fabricante.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api'; 
  
  static String? _tokenBasicAuth; 
  static String? _usernameLogado;

  Future<bool> fazerLogin(String usernameDigitado, String senhaDigitada) async {
    try {
      String tokenTemporario = 'Basic ${base64Encode(utf8.encode('$usernameDigitado:$senhaDigitada'))}';
      final response = await http.get(
        Uri.parse('$baseUrl/perfis/'),
        headers: {'Authorization': tokenTemporario},
      );

      if (response.statusCode == 200) {
        _tokenBasicAuth = tokenTemporario;
        _usernameLogado = usernameDigitado;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Erro no login: $e");
      throw Exception('Erro de conexão com o servidor.');
    }
  }

  Future<void> cadastrarUsuarioCompleto({
    required String username,
    required String email,
    required String senha,
    required String nome,
    required String sobrenome,
    required String telefone,
  }) async {
    final responseUser = await http.post(
      Uri.parse('$baseUrl/usuarios/'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': senha,
      }),
    );

    if (responseUser.statusCode != 201) {
      throw Exception('Erro ao criar credenciais. Utilizador já existe.');
    }

    final userData = jsonDecode(utf8.decode(responseUser.bodyBytes));
    final int userId = userData['id']; 
    String tokenNovoUsuario = 'Basic ${base64Encode(utf8.encode('$username:$senha'))}';

    final responsePerfil = await http.post(
      Uri.parse('$baseUrl/perfis/'),
      headers: {
        'Authorization': tokenNovoUsuario, 
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'nome': nome,
        'sobrenome': sobrenome,
        'telefone': telefone,
        'usuario': userId,
      }),
    );

    if (responsePerfil.statusCode != 201) {
      throw Exception('Erro ao criar o perfil do utilizador.');
    }
  }

  Future<List<Produto>> getProdutos() async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/produtos/'),
      headers: {'Authorization': _tokenBasicAuth!},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Produto.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar produtos.');
    }
  }

  Future<Produto> criarProduto(Produto produto) async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/produtos/'),
      headers: {
        'Authorization': _tokenBasicAuth!,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(produto.toJson()),
    );

    if (response.statusCode == 201) {
      return Produto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao criar produto.');
    }
  }

  Future<Produto> atualizarProduto(String id, Produto produto) async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.put(
      Uri.parse('$baseUrl/produtos/$id/'),
      headers: {
        'Authorization': _tokenBasicAuth!,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(produto.toJson()),
    );

    if (response.statusCode == 200) {
      return Produto.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao atualizar produto.');
    }
  }

  Future<void> deletarProduto(String id) async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.delete(
      Uri.parse('$baseUrl/produtos/$id/'),
      headers: {'Authorization': _tokenBasicAuth!},
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao deletar produto.');
    }
  }

  Future<List<Fabricante>> getFabricantes() async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/fabricantes/'),
      headers: {'Authorization': _tokenBasicAuth!},
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((item) => Fabricante.fromJson(item)).toList();
    } else {
      throw Exception('Falha ao carregar fabricantes.');
    }
  }

  Future<Fabricante> criarFabricante(Fabricante fabricante) async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.post(
      Uri.parse('$baseUrl/fabricantes/'),
      headers: {
        'Authorization': _tokenBasicAuth!,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(fabricante.toJson()),
    );

    if (response.statusCode == 201) {
      return Fabricante.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao criar fabricante.');
    }
  }

  Future<Fabricante> atualizarFabricante(String id, Fabricante fabricante) async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.put(
      Uri.parse('$baseUrl/fabricantes/$id/'),
      headers: {
        'Authorization': _tokenBasicAuth!,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(fabricante.toJson()),
    );

    if (response.statusCode == 200) {
      return Fabricante.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Falha ao atualizar fabricante.');
    }
  }

  Future<void> deletarFabricante(String id) async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.delete(
      Uri.parse('$baseUrl/fabricantes/$id/'),
      headers: {'Authorization': _tokenBasicAuth!},
    );

    if (response.statusCode != 204) {
      throw Exception('Falha ao deletar fabricante.');
    }
  }

  Future<String> _getMeuPerfilId() async {
    final resUsuarios = await http.get(Uri.parse('$baseUrl/usuarios/'), headers: {'Authorization': _tokenBasicAuth!});
    List usuarios = jsonDecode(utf8.decode(resUsuarios.bodyBytes));
    var meuUsuario = usuarios.firstWhere((u) => u['username'] == _usernameLogado, orElse: () => null);
    
    if (meuUsuario == null) throw Exception('Usuário não encontrado na base de dados.');
    int userId = meuUsuario['id'];
    final resPerfis = await http.get(Uri.parse('$baseUrl/perfis/'), headers: {'Authorization': _tokenBasicAuth!});
    List perfis = jsonDecode(utf8.decode(resPerfis.bodyBytes));
    var meuPerfil = perfis.firstWhere((p) => p['usuario'] == userId, orElse: () => null);
    
    if (meuPerfil == null) throw Exception('Não tem um Perfil associado. Crie um perfil!');

    return meuPerfil['id'].toString();
  }

  Future<void> registrarVenda(List<Map<String, dynamic>> carrinho, double subtotal) async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    String idPerfil = await _getMeuPerfilId();

    final responseVenda = await http.post(
      Uri.parse('$baseUrl/vendas/'),
      headers: {
        'Authorization': _tokenBasicAuth!,
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'subtotal': subtotal, 'perfil': idPerfil}),
    );

    if (responseVenda.statusCode != 201) throw Exception('Falha ao registar a Venda');
    String idVenda = jsonDecode(utf8.decode(responseVenda.bodyBytes))['id_venda'];

    for (var item in carrinho) {
      final responseItem = await http.post(
        Uri.parse('$baseUrl/itens-venda/'),
        headers: {
          'Authorization': _tokenBasicAuth!,
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'venda': idVenda,
          'produto': item['produto'].idProduto,
          'qtd': item['qtd'],
        }),
      );
      if (responseItem.statusCode != 201) throw Exception('Falha ao salvar um item da venda');
    }
  }

  Future<List<dynamic>> getVendas() async {
    if (_tokenBasicAuth == null) throw Exception('Utilizador não autenticado');

    final response = await http.get(
      Uri.parse('$baseUrl/vendas/'),
      headers: {'Authorization': _tokenBasicAuth!},
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception('Falha ao carregar o histórico de vendas.');
    }
  }
}