import 'package:fere/body_page.dart';
import 'package:fere/database_helper.dart';
import 'package:flutter/material.dart';

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
    _tabController = TabController(length: 4, vsync: this);
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
                final dbHelper = DatabaseHelper.instance;
                dbHelper.backupDatabase();
                // dbHelper.resetDatabase();
              },
              child: const Text("Sauvegarder")),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Articles'),
            Tab(text: 'Inventaires'),
            Tab(text: 'Achats'),
            Tab(text: 'Ventes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BodyPage(
            addArticleVisibility: false,
            title: "Ajouter un article",
            colonnesArg: true,
            typeArg: -1,
            groupArg: const ['libelle'],
          ),
          BodyPage(
            title: "Ajouter un article",
            typeArg: 0,
          ),
          BodyPage(
            title: "Ajouter un achat",
            typeArg: 1,
          ),
          BodyPage(
            title: "Ajouter une vente",
            typeArg: 2,
          ),
        ],
      ),
    );
  }
}
