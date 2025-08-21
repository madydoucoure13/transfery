import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmailOtpAuthPage extends StatefulWidget {
  const EmailOtpAuthPage({Key? key}) : super(key: key);

  @override
  State<EmailOtpAuthPage> createState() => _EmailOtpAuthPageState();
}

class _EmailOtpAuthPageState extends State<EmailOtpAuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  bool _otpSent = false;
  String? _email;

  /// === ENVOYER OTP PAR EMAIL ===
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (!email.contains("@")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email invalide")),
      );
      return;
    }

    try {
      var response = await http.post(
        Uri.parse("https://ton-serveur.com/send-otp.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _otpSent = true;
          _email = email;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP envoyé par email 📧")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur envoi OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur réseau")),
      );
    }
  }

  /// === VÉRIFIER OTP ===
  Future<void> _verifyOtp() async {
    if (_email == null) return;

    try {
      var response = await http.post(
        Uri.parse("https://ton-serveur.com/verify-otp.php"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _email, "otp": _otpController.text.trim()}),
      );

      var data = jsonDecode(response.body);

      if (data["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connexion réussie ✅")),
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
      appBar: AppBar(title: const Text("Auth OTP par Email")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_otpSent) ...[
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendOtp,
                child: const Text("Envoyer OTP"),
              ),
            ] else ...[
              Text("Un code a été envoyé à $_email"),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(
                  labelText: "Entrez OTP",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyOtp,
                child: const Text("Valider OTP"),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
