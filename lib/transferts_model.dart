// class Transfert {
//   int? id;
//   String code;
//   String? customerName;
//   String nom;
//   String devise;
//   double rate;
//   double montant;
//   DateTime date;
//   int type;

//   Transfert({
//     this.id,
//     this.customerName,
//     required this.code,
//     required this.rate,
//     required this.nom,
//     required this.devise,
//     required this.montant,
//     DateTime?
//         date, // La date est optionnelle et prendra la date du jour par défaut
//     this.type = 0,
//   }) : date = date ??
//             DateTime
//                 .now(); // Si aucune date n'est fournie, utiliser la date actuelle

//   static Transfert emptyTransfert() {
//     return Transfert(nom: "", code: "", devise: "", rate: 1, montant: 0);
//   }

//   // Convertir un article en Map pour SQLite
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': nom,
//       'customer_name': customerName,
//       'code': code,
//       'devise': devise,
//       'rate': rate,
//       'montant': montant,
//       'date': date.toIso8601String(), // Convertir en chaîne ISO pour SQLite
//       'type': type,
//     };
//   }

//   // Créer un Transfert à partir d'un Map
//   factory Transfert.fromMap(Map<String, dynamic> map) {
//     return Transfert(
//       id: map['id'],
//       code: map['code'],
//       nom: map['name'],
//       devise: map['devise'],
//       montant: map['montant'],
//       rate: map['rate'],
//       date: DateTime.parse(map['date']),
//       type: map['type'],
//     );
//   }
// }
class Transfert {
  int? id;
  String code;
  String? customerName;
  String nom;
  String devise;
  double rate;
  double montant;
  DateTime date;
  int type;

  Transfert({
    this.id,
    this.customerName,
    required this.code,
    required this.rate,
    required this.nom,
    required this.devise,
    required this.montant,
    DateTime? date,
    this.type = 0,
  }) : date = date ?? DateTime.now();

  static Transfert emptyTransfert() {
    return Transfert(nom: "", code: "", devise: "", rate: 1, montant: 0);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': nom,
      'customer_name': customerName,
      'code': code,
      'devise': devise,
      'rate': rate,
      'montant': montant,
      'date': date.toIso8601String(),
      'type': type,
    };
  }

  factory Transfert.fromMap(Map<String, dynamic> map) {
    return Transfert(
      id: map['id'],
      code: map['code'],
      nom: map['name'],
      customerName: map['customer_name'],
      devise: map['devise'] ?? "",
      montant: (map['montant'] ?? 0 as num).toDouble(),
      rate: (map['rate'] ?? 1 as num).toDouble(),
      date: map['date'] != null ? DateTime.parse(map['date']) : DateTime.now(),
      type: map['type'] ?? 0,
    );
  }
}
