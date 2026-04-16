class Produto {
  String? idProduto;
  String nome;
  String fabricanteId;
  double? valorCusto;
  double valorVenda;
  String? validade;

  Produto({
    this.idProduto,
    required this.nome,
    required this.fabricanteId,
    this.valorCusto,
    required this.valorVenda,
    this.validade,
  });

  factory Produto.fromJson(Map<String, dynamic> json) {
    return Produto(
      idProduto: json['id_produto'],
      nome: json['nome'],
      fabricanteId: json['fabricante'].toString(), 
      valorCusto: json['valorCusto'] != null ? double.parse(json['valorCusto'].toString()) : null,
      valorVenda: double.parse(json['valorVenda'].toString()),
      validade: json['validade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'fabricante': fabricanteId,
      'valorCusto': valorCusto,
      'valorVenda': valorVenda,
      if (validade != null && validade!.isNotEmpty) 'validade': validade,
    };
  }
}