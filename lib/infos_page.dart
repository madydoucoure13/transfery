import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfery/user_model.dart';
import 'dart:convert';

import 'package:transfery/widget/custom_button.dart';

class InfosPage extends StatefulWidget {
  const InfosPage({Key? key}) : super(key: key);

  @override
  State<InfosPage> createState() => _InfosPageState();
}

class _InfosPageState extends State<InfosPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _etsNameController = TextEditingController();

  bool _otpSent = false;
  String? _email;
  Entreprise? entreprise;

  /// === VÉRIFIER DES INFOS ===
  Future<void> _sendInfos() async {
    final email = _emailController.text.trim();
    _email = email;
    if (_email == null) return;
    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email invalide")),
      );
      return;
    }
    try {
      var uri = "http://localhost/transferly/save_infos.php";
      var uriS = "https://transferly.sugubougou.com/save_infos.php";
      var response = await http.post(
        Uri.parse(uriS),
        headers: {
          "Access-Control-Allow-Origin": "*",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "ets_name": _etsNameController.text.trim(),
          "email": _email,
          "phone_number": _phoneNumberController.text.trim()
        }),
      );

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        Entreprise entreprise = Entreprise(
            etsName: _etsNameController.text.trim(),
            email: _emailController.text,
            status: "1",
            phoneNumber: _phoneNumberController.text.trim());
        saveEntreprise(entreprise);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Infos envoyé avec succè réussie ✅")),
        );
        // Ici c'est comme Firebase: tu stockes un token JWT en local
        // puis tu navigues vers HomePage
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "OTP invalide ❌")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur serveur")),
      );
    }
  }

  late SharedPreferences _prefs;

  Future<void> _initSharedPref() async {
    _prefs = await SharedPreferences.getInstance();
    final data = _prefs.getString("entreprise");
    if (data != null) {
      final user = Entreprise.fromJson(data);
      _emailController.text = user.email;
      _phoneNumberController.text = user.phoneNumber;
      _etsNameController.text = user.etsName;
      setState(() {});
    }
  }

  Future<void> saveEntreprise(Entreprise entreprise) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('entreprise', entreprise.toJson());
  }

  @override
  void initState() {
    super.initState();
    _initSharedPref();
  }

  @override
  Widget build(BuildContext context) {
    // print(data);

    return Scaffold(
      appBar: AppBar(title: const Text("Save Infos")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            constraints: BoxConstraints(maxWidth: 300, maxHeight: 230),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_otpSent) ...[
                  TextField(
                    controller: _etsNameController,
                    decoration: const InputDecoration(
                      labelText: "ETS Name",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _phoneNumberController,
                    decoration: const InputDecoration(
                      labelText: "Phone number",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  CustomButton(onTap: _sendInfos, text: "Save"),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}
