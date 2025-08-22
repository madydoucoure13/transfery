import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
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

  /// === VÉRIFIER DES INFOS ===
  Future<void> _sendInfos() async {
    final email = _emailController.text.trim();
    if (_email == null) return;
    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email invalide")),
      );
      return;
    }
    try {
      var response = await http.post(
        Uri.parse("https://ton-serveur.com/verify-otp.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "ets_name": _etsNameController.text.trim(),
          "email": _email,
          "phone_number": _phoneNumberController.text.trim()
        }),
      );

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
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

  @override
  Widget build(BuildContext context) {
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
