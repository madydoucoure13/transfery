import 'package:transfery/body_page.dart';
import 'package:transfery/database_helper.dart';
import 'package:flutter/material.dart';
import 'package:transfery/infos_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text('DOUCOURE'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfosPage(),
                  ),
                );
              },
              child: const Text("Infos")),
          TextButton(
              onPressed: () {
                final dbHelper = DatabaseHelper.instance;
                dbHelper.backupDatabase();
                // dbHelper.resetDatabase();
              },
              child: const Text("Sauvegarder")),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Comptes'),
            // Tab(text: 'Comptes'),
            Tab(text: 'Entrés'),
            Tab(text: 'Sorties'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BodyPage(
            addTransfertVisibility: false,
            title: "Ajouter un compte",
            colonnesArg: true,
            typeArg: -1,
            groupArg: const ['name'],
          ),
          // BodyPage(
          //   title: "Ajouter un article",
          //   typeArg: 0,
          // ),
          BodyPage(
            title: "Ajouter une entrée",
            typeArg: 1,
          ),
          BodyPage(
            title: "Ajouter une sortie",
            typeArg: 2,
          ),
        ],
      ),
    );
  }
}
