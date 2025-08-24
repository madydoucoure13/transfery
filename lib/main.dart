import 'package:shared_preferences/shared_preferences.dart';
import 'package:transfery/contact_page.dart';
import 'package:transfery/email_otp_page.dart';
import 'package:transfery/infos_page.dart';
import 'package:transfery/my_home_page.dart';
import 'package:flutter/material.dart';
import 'package:transfery/test.dart';
import 'package:transfery/user_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

// Fonction pour récupérer depuis SharedPreferences
  Future<Entreprise?> getEntreprise() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('entreprise');
    if (data != null) {
      return Entreprise.fromJson(data);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Entreprise?>(
        future: getEntreprise(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Pendant le chargement
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data?.status != "1") {
            return ContactPage(
                entreprise: snapshot.data ??
                    Entreprise(
                        etsName: "", email: "", phoneNumber: "", status: "0"));
          } else if (snapshot.hasData && snapshot.data != null) {
            print(snapshot.data?.status);
            // Entreprise déjà enregistrée
            return HomePage();
          } else {
            return InfosPage();
          }
        },
      ),
    );
  }
}
