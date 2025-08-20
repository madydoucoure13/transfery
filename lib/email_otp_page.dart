import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:transfery/otp_input_page.dart';

class EmailInputPage extends StatefulWidget {
  @override
  State<EmailInputPage> createState() => _EmailInputPageState();
}

class _EmailInputPageState extends State<EmailInputPage> {
  final TextEditingController _emailController = TextEditingController();
  bool loading = false;

  Future<void> sendOTP() async {
    setState(() => loading = true);

    try {
      // Appel API pour générer et envoyer l’OTP
      var response = await http.post(
        Uri.parse("https://ton-api.com/send-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": _emailController.text}),
      );

      if (response.statusCode == 200) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpPage(email: _emailController.text),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l’envoi de l’OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible de contacter le serveur")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion par email")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: sendOTP,
                    child: const Text("Envoyer OTP"),
                  ),
          ],
        ),
      ),
    );
  }
}
