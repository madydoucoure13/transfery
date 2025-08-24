import 'dart:convert';

class Entreprise {
  final String etsName;
  final String email;
  final String phoneNumber;
  final String status;

  Entreprise(
      {required this.etsName,
      required this.email,
      required this.phoneNumber,
      required this.status});

  // Convertir un objet en Map (pour jsonEncode)
  Map<String, dynamic> toMap() {
    return {
      'ets_name': etsName,
      'email': email,
      'phone_number': phoneNumber,
      'status': status
    };
  }

  // Recréer l’objet depuis un Map
  factory Entreprise.fromMap(Map<String, dynamic> map) {
    return Entreprise(
        etsName: map['ets_name'],
        email: map['email'],
        phoneNumber: map['phone_number'],
        status: map["status"]);
  }

  // Helpers pour JSON
  String toJson() => jsonEncode(toMap());

  factory Entreprise.fromJson(String source) =>
      Entreprise.fromMap(jsonDecode(source));
}
