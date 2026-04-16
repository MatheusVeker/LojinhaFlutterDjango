class Fabricante {
  String? idFabricante;
  String nome;
  String? logo;
  String? site;

  Fabricante({
    this.idFabricante,
    required this.nome,
    this.logo,
    this.site,
  });

  factory Fabricante.fromJson(Map<String, dynamic> json) {
    return Fabricante(
      idFabricante: json['id_fabricante'],
      nome: json['nome'],
      logo: json['logo'],
      site: json['site'],
    );
  }

  // Método para converter o objeto em JSON antes de mandar para o Django
  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'logo': logo,
      'site': site,
    };
  }
}