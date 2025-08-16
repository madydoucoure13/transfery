class Article {
  int? id;
  String libelle;
  int quantite;
  double prix;
  DateTime date;
  int type;

  Article({
    this.id,
    required this.libelle,
    required this.quantite,
    required this.prix,
    DateTime?
        date, // La date est optionnelle et prendra la date du jour par défaut
    this.type = 0,
  }) : date = date ??
            DateTime
                .now(); // Si aucune date n'est fournie, utiliser la date actuelle

  static Article emptyArticle() {
    return Article(libelle: "", quantite: 0, prix: 0);
  }

  // Convertir un article en Map pour SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'libelle': libelle,
      'quantite': quantite,
      'prix': prix,
      'date': date.toIso8601String(), // Convertir en chaîne ISO pour SQLite
      'type': type,
    };
  }

  // Créer un Article à partir d'un Map
  factory Article.fromMap(Map<String, dynamic> map) {
    return Article(
      id: map['id'],
      libelle: map['libelle'],
      quantite: map['quantite'],
      prix: map['prix'],
      date: DateTime.parse(map['date']),
      type: map['type'],
    );
  }
}
