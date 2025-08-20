import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'transferts_model.dart';

class CompteDetailsPage extends StatefulWidget {
  final String compteName;

  const CompteDetailsPage({Key? key, required this.compteName})
      : super(key: key);

  @override
  _CompteDetailsPageState createState() => _CompteDetailsPageState();
}

class _CompteDetailsPageState extends State<CompteDetailsPage> {
  late Future<List<Transfert>> _transfertsFuture;

  @override
  void initState() {
    super.initState();
    _transfertsFuture =
        DatabaseHelper.instance.readCompteTransfertByName(widget.compteName);
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0.00", "fr_FR");

    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text("Détails du compte")),
      body: Center(
        child: FutureBuilder<List<Transfert>>(
          future: _transfertsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Erreur : ${snapshot.error}"));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Aucun mouvement trouvé"));
            }
            final transferts = snapshot.data!;
            // Séparer entrées et sorties
            final entrees = transferts.where((t) => t.type == 1).toList();
            final sorties = transferts.where((t) => t.type == -1).toList();
            final solde = entrees.fold(0.0, (sum, t) => sum + t.montant) -
                sorties.fold(0.0, (sum, t) => sum + t.montant);

            return Column(
              children: [
                ListTile(
                  title: const Text("Solde total"),
                  trailing: Text(
                      "${numberFormat.format(solde)} ${transferts.first.devise}"),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20.0),
                    shrinkWrap: true,
                    itemCount: transferts.length,
                    itemBuilder: (context, index) {
                      final t = transferts[index];
                      return ListTile(
                        leading: Icon(
                          t.type == 1
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: t.type == 1 ? Colors.green : Colors.red,
                        ),
                        title: Text("${t.customerName} - ${t.code}"),
                        subtitle: Text(dateFormat.format(t.date)),
                        trailing: Text(
                          t.type == 1
                              ? "${t.montant}  ${t.devise}"
                              : "${t.montant} x ${t.rate} = ${numberFormat.format(t.rate * t.montant)} dirhams",
                          style: TextStyle(
                            color: t.type == 1 ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
