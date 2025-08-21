import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:transfery/compte_details_page.dart';
import 'package:transfery/transferts_model.dart';
import 'package:transfery/database_helper.dart';
import 'package:transfery/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class BodyPage extends StatefulWidget {
  bool addTransfertVisibility = true;
  final String title;

  bool colonnesArg = false;
  int typeArg = 0;
  var groupArg;
  BodyPage(
      {super.key,
      this.addTransfertVisibility = true,
      required this.title,
      this.colonnesArg = false,
      this.typeArg = 0,
      this.groupArg});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _compteController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _deviseNameOrRate = TextEditingController();
  final TextEditingController _montantController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();
  final FocusNode _compteFocusNode = FocusNode();
  final FocusNode _customerFocusNode = FocusNode();
  final FocusNode _quantiteFocusNode = FocusNode();
  final FocusNode _prixFocusNode = FocusNode();
  String _montant = "";
  List<Transfert> transferts = [];
  Transfert transfertEdit =
      Transfert(nom: "", code: "", devise: "", montant: 0, rate: 1);
  late SharedPreferences _prefs;

  Future<void> _loadTransferts() async {
    _prefs = await SharedPreferences.getInstance();

    _prefs.setString("name", "Bamady");
    final dbHelper = DatabaseHelper.instance;
    final loadedTransferts = await dbHelper.readAllTransferts(
        addColumn: widget.colonnesArg,
        typeFilter: widget.typeArg < 0 ? null : widget.typeArg,
        groupBy: widget.groupArg);
    setState(() {
      transferts = loadedTransferts;
      print("voici la taille des transferts");
      print(transferts.length);
      print("fin -----------------");
    });
  }

  @override
  void initState() {
    super.initState();
    _loadTransferts();
    _deviseNameOrRate.addListener(_updateMontant);
    _montantController.addListener(_updateMontant);
  }

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs et des FocusNodes
    _codeController.dispose();
    _compteController.dispose();
    _customerController.dispose();
    _deviseNameOrRate.dispose();
    _montantController.dispose();
    _compteFocusNode.dispose();
    _customerFocusNode.dispose();
    _quantiteFocusNode.dispose();
    _prixFocusNode.dispose();
    super.dispose();
  }

  void _updateMontant() {
    final rate = double.tryParse(_deviseNameOrRate.text) ?? 1;
    final montant = double.tryParse(_montantController.text) ?? 0.0;
    setState(() {
      _montant = _calculateMontant(rate, montant).toString();
    });
  }

  String _calculateMontant(double rate, double montant) {
    final formatter = NumberFormat();
    if (widget.typeArg == 2) return formatter.format(rate * montant);

    return formatter.format(montant);
  }

  // Fonction pour afficher une boîte de confirmation avant de supprimer
  Future<void> _confirmDeleteTransfert(Transfert transfert) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // L'utilisateur doit confirmer ou annuler
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                    'Voulez-vous vraiment supprimer ce transfert : ${transfert.nom}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
            ),
            TextButton(
              child: const Text('Confirmer'),
              onPressed: () async {
                final dbHelper = DatabaseHelper.instance;
                await dbHelper.deleteTransfert(
                    transfert.id ?? 0); // Supprimer l'transfert
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _loadTransferts(); // Recharger la liste des transferts
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DataTable(
            columns: [
              if (widget.typeArg != -1) const DataColumn(label: Text('ID')),
              if (widget.typeArg != -1) const DataColumn(label: Text("Code")),
              const DataColumn(label: Text('Nom Compte')),
              if (widget.typeArg != -1)
                widget.typeArg == 2
                    ? const DataColumn(label: Text('Rate'))
                    : const DataColumn(label: Text('Devise')),
              const DataColumn(label: Text('Montant')),
              if (widget.typeArg != -1) const DataColumn(label: Text('Date')),
              DataColumn(label: Text('Actions')),
            ],
            rows: transferts
                .map((transfert) => DataRow(cells: [
                      if (widget.typeArg != -1)
                        DataCell(Text(transfert.id.toString())),
                      if (widget.typeArg != -1) DataCell(Text(transfert.code)),
                      DataCell(Text(transfert.nom)),
                      if (widget.typeArg != -1)
                        DataCell(Text(transfert.devise)),
                      DataCell(Text(widget.typeArg == 2
                          ? (transfert.montant * (-1)).toString()
                          : transfert.montant.toString())),
                      if (widget.typeArg != -1)
                        DataCell(Text(transfert.date.toString().split(" ")[0])),
                      DataCell(
                        widget.typeArg < 0
                            ? IconButton(
                                icon: const Icon(
                                  Icons.open_in_browser,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CompteDetailsPage(
                                          compteName: transfert.nom),
                                    ),
                                  );
                                  // Afficher la boîte de confirmation
                                },
                              )
                            : Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      transfertEdit = transfert;
                                      _codeController.text = transfert.code;
                                      _compteController.text = transfert.nom;
                                      _customerController.text =
                                          transfert.customerName ?? "";
                                      _deviseNameOrRate.text = transfert.devise;
                                      _montantController.text =
                                          transfert.montant < 0
                                              ? (transfert.montant * (-1))
                                                  .toString()
                                              : transfert.montant.toString();
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _confirmDeleteTransfert(
                                          transfert); // Afficher la boîte de confirmation
                                    },
                                  ),
                                ],
                              ),
                      ),
                    ]))
                .toList(),
          ),
        ),
        Visibility(
          visible: widget.addTransfertVisibility,
          child: SizedBox(
            width: 400,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.start,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFormFieldCustom(
                      title: "Code*",
                      controller: _codeController,
                      focusNode: _codeFocusNode),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormFieldCustom(
                            title: widget.typeArg == 2
                                ? "Compte Exp*"
                                : "Compte name",
                            controller: _compteController,
                            focusNode: _compteFocusNode),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: TextFormFieldCustom(
                            title: widget.typeArg == 2
                                ? "Nom Client*"
                                : "Provider name",
                            controller: _customerController,
                            focusNode: _customerFocusNode),
                      ),
                    ],
                  ),
                  TextFormFieldCustom(
                    title: "Montant",
                    controller: _montantController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d*')), // autorise décimal
                    ],
                  ),
                  widget.typeArg == 2
                      ? TextFormFieldCustom(
                          title: "Rate",
                          keyboardType: widget.typeArg == 2
                              ? const TextInputType.numberWithOptions(
                                  decimal: true)
                              : TextInputType.name,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*')), // autorise décimal
                          ],
                          controller: _deviseNameOrRate,
                          focusNode: _quantiteFocusNode)
                      : TextFormFieldCustom(
                          title: "Devise name",
                          keyboardType: TextInputType.name,
                          controller: _deviseNameOrRate,
                          focusNode: _quantiteFocusNode),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.typeArg == 2
                        ? "Montant en dirhams $_montant"
                        : "Montant $_montant",
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible: transfertEdit.id != null,
                          child: CustomButton(
                              color: Colors.red,
                              onTap: () {
                                transfertEdit = Transfert.emptyTransfert();
                                setState(() {
                                  _compteController.text = "";
                                  _customerController.text = "";
                                  _codeController.text = "";
                                  _deviseNameOrRate.text = "";
                                  _montantController.text = "";
                                });
                              },
                              text: "Annuler"),
                        ),
                        CustomButton(
                            onTap: () async {
                              String compteName = _compteController.text;
                              String customerName = _customerController.text;
                              String code = _codeController.text;
                              String devise = _deviseNameOrRate.text;
                              double rate =
                                  double.tryParse(_deviseNameOrRate.text) ??
                                      1.0;
                              double montant =
                                  double.tryParse(_montantController.text) ??
                                      0.0;

                              final dbHelper = DatabaseHelper.instance;
                              //  dbHelper.resetDatabase();
                              if (transfertEdit.id == null) {
                                final resul = await dbHelper.createTransfert(
                                    Transfert(
                                        nom: compteName,
                                        code: code,
                                        devise: devise,
                                        customerName: customerName,
                                        rate: rate,
                                        montant: widget.typeArg == 2
                                            ? montant * (-1)
                                            : montant,
                                        type: widget.typeArg));
                              } else {
                                final resul = await dbHelper.updateTransfert(
                                    Transfert(
                                        id: transfertEdit.id,
                                        code: code,
                                        nom: compteName,
                                        devise: devise,
                                        rate: rate,
                                        montant: widget.typeArg == 2
                                            ? montant * (-1)
                                            : montant,
                                        type: transfertEdit.type));
                              }

                              final loadedTransferts =
                                  await dbHelper.readAllTransferts(
                                      addColumn: widget.colonnesArg,
                                      typeFilter: widget.typeArg < 0
                                          ? null
                                          : widget.typeArg,
                                      groupBy: widget.groupArg);
                              setState(() {
                                transferts = loadedTransferts;
                                _compteController.text = "";
                                _customerController.text = "";
                                _deviseNameOrRate.text = "";
                                _montantController.text = "";
                              });
                            },
                            text: transfertEdit.id != null
                                ? "Modifier"
                                : "Enregistrer"),
                        CustomButton(
                            onTap: () {
                              // _printTransferts();
                              _printTransfertDetail(transfertEdit);
                              // _createPdf();
                            },
                            text: "Imprimer")
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _createPdf(Transfert t) {
    final doc = pw.Document();
    doc.addPage(pw.Page(
      build: (context) {
        return pw.Center();
      },
    ));
  }

  Future<void> _printTransfertDetail(Transfert t) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');
    final formatter = NumberFormat();
    final pageFormat =
        const PdfPageFormat(136, double.infinity, marginAll: 4); // largeur 48mm

    pdf.addPage(
      pw.Page(
        pageFormat: pageFormat,
        build: (pw.Context context) {
          return pw.Container(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    "Reçu de transfert",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Divider(),
                _buildDetailRow("ID", t.id.toString()),
                _buildDetailRow("Code", t.code),
                _buildDetailRow("name", t.nom),
                _buildDetailRow("Rate", t.devise),
                _buildDetailRow(
                    "Montant", "${formatter.format(t.montant * (-1))}"),
                _buildDetailRow(
                    "Montant en dirhams", //.toString()
                    "${formatter.format(t.montant * (-1))}"),
                _buildDetailRow("Date", dateFormat.format(t.date) ?? ""),
                pw.Divider(),
                pw.SizedBox(height: 8),
                pw.Center(
                  child: pw.Text(
                    "Merci pour votre confiance",
                    style: pw.TextStyle(
                        fontSize: 8, fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }

  /// Ligne formatée pour 48mm
  pw.Widget _buildDetailRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            flex: 3,
            child: pw.Text(
              "$label:",
              style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            flex: 5,
            child: pw.Text(
              value,
              style: pw.TextStyle(fontSize: 8),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _printTransferts() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Liste des transferts",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: ["ID", "Code", "Nom", "Devise", "Montant"],
                data: transferts
                    .map((t) => [
                          t.id.toString(),
                          t.code,
                          t.nom,
                          t.devise,
                          t.montant.toString()
                        ])
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}

bool isNumeric(String input) {
  // Si la chaîne est vide, on considère que ce n'est pas numérique
  if (input.isEmpty) return false;

  // Essaie de convertir en nombre
  final number = num.tryParse(input);
  return number != null;
}

SizedBox TextFormFieldCustom({
  String title = "",
  TextEditingController? controller,
  FocusNode? focusNode,
  int? minLines,
  int maxLines = 1,
  TextInputType? keyboardType, // clavier optionnel
  List<TextInputFormatter>? inputFormatters, // restriction optionnelle
}) {
  return SizedBox(
    height: 60,
    child: TextFormField(
      minLines: minLines,
      maxLines: maxLines,
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters, // 👈 utilisation
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        label: Text(title),
        contentPadding: const EdgeInsets.only(left: 10),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue),
        ),
      ),
    ),
  );
}
