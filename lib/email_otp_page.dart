import 'package:flutter/material.dart';
import 'dart:math';

class EmailOtpAuthPage extends StatefulWidget {
  const EmailOtpAuthPage({Key? key}) : super(key: key);

  @override
  _EmailOtpAuthPageState createState() => _EmailOtpAuthPageState();
}

class _EmailOtpAuthPageState extends State<EmailOtpAuthPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  String? _generatedOtp;
  bool _otpSent = false;

  // Générer un OTP aléatoire à 6 chiffres
  String _generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  // Simuler l'envoi de l'OTP par email
  void _sendOtp() {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Email invalide")));
      return;
    }

    _generatedOtp = _generateOtp();
    setState(() {
      _otpSent = true;
    });

    // Dans une vraie app, ici tu enverrais l'OTP via backend / email
    print("OTP envoyé à $email : $_generatedOtp");
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP envoyé à votre email")));
  }

  void _verifyOtp() {
    if (_otpController.text.trim() == _generatedOtp) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("OTP correct !")));
      // Naviguer vers la page suivante
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("OTP incorrect")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Authentification par OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_otpSent) ...[
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendOtp,
                child: const Text("Envoyer OTP"),
              ),
            ] else ...[
              Text(
                "Un code OTP a été envoyé à ${_emailController.text}",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Entrez le OTP",
                  border: OutlineInputBorder(),
                ),
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
