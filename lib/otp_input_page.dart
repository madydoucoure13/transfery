import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpPage extends StatefulWidget {
  final String email;
  const OtpPage({super.key, required this.email});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  String otpCode = "";
  bool loading = false;

  Future<void> verifyOTP() async {
    setState(() => loading = true);

    try {
      var response = await http.post(
        Uri.parse("https://ton-api.com/verify-otp"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": widget.email, "otp": otpCode}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connexion réussie ✅")),
        );
        // TODO: Naviguer vers ta HomePage
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP invalide ❌")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur de serveur")),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Vérifier OTP")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Entrez le code reçu par email"),
            const SizedBox(height: 20),
            PinCodeTextField(
              appContext: context,
              length: 6,
              onChanged: (value) => otpCode = value,
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: verifyOTP,
                    child: const Text("Vérifier"),
                  ),
          ],
        ),
      ),
    );
  }
}
