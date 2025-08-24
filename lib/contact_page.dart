import 'package:flutter/material.dart';
import 'package:transfery/main.dart';
import 'package:transfery/user_model.dart';
import 'package:transfery/widget/custom_button.dart';

class ContactPage extends StatefulWidget {
  Entreprise entreprise;
  ContactPage({super.key, required this.entreprise});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.all(15.0),
        child: Column(
          children: [
            Center(
              child: Text(
                  "Veuillez me contacter +971 56 582 7095 ou au +223 76 27 87 95 via whatsapp"),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(onPressed: () {}, child: Text("Try Again"))
          ],
        ),
      ),
    );
  }
}
