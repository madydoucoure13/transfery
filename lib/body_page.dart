import 'package:fere/articles_model.dart';
import 'package:fere/database_helper.dart';
import 'package:fere/widget/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BodyPage extends StatefulWidget {
  bool addArticleVisibility = true;
  final String title;

  bool colonnesArg = false;
  int typeArg = 0;
  var groupArg;
  BodyPage(
      {super.key,
      this.addArticleVisibility = true,
      required this.title,
      this.colonnesArg = false,
      this.typeArg = 0,
      this.groupArg});

  @override
  State<BodyPage> createState() => _BodyPageState();
}

class _BodyPageState extends State<BodyPage> {
  final TextEditingController _libelleController = TextEditingController();
  final TextEditingController _quantiteController = TextEditingController();
  final TextEditingController _prixController = TextEditingController();
  final FocusNode _libelleFocusNode = FocusNode();
  final FocusNode _quantiteFocusNode = FocusNode();
  final FocusNode _prixFocusNode = FocusNode();
  String _montant = "";
  List<Article> articles = [];
  Article articleEdit = Article(libelle: "", quantite: 0, prix: 0);
  late SharedPreferences _prefs;

  Future<void> _loadArticles() async {
    _prefs = await SharedPreferences.getInstance();

    _prefs.setString("name", "Bamady");
    final dbHelper = DatabaseHelper.instance;
    final loadedArticles = await dbHelper.readAllArticles(
        addColumn: widget.colonnesArg,
        typeFilter: widget.typeArg < 0 ? null : widget.typeArg,
        groupBy: widget.groupArg);
    setState(() {
      articles = loadedArticles;
      print("voici la taille des articles");
      print(articles.length);
      print("fin -----------------");
    });
  }

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _quantiteController.addListener(_updateMontant);
    _prixController.addListener(_updateMontant);
  }

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs et des FocusNodes
    _libelleController.dispose();
    _quantiteController.dispose();
    _prixController.dispose();
    _libelleFocusNode.dispose();
    _quantiteFocusNode.dispose();
    _prixFocusNode.dispose();
    super.dispose();
  }

  void _updateMontant() {
    final quantite = int.tryParse(_quantiteController.text) ?? 0;
    final prix = double.tryParse(_prixController.text) ?? 0.0;
    setState(() {
      _montant = _calculateMontant(quantite, prix).toString();
    });
  }

  String _calculateMontant(int quantite, double prix) {
    final montant = quantite * prix;
    final formatter = NumberFormat(); // Utilise la locale souhaitée
    return formatter.format(montant);
  }

  // Fonction pour afficher une boîte de confirmation avant de supprimer
  Future<void> _confirmDeleteArticle(Article article) async {
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
                    'Voulez-vous vraiment supprimer cet article : ${article.libelle}?'),
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
                await dbHelper
                    .deleteArticle(article.id ?? 0); // Supprimer l'article
                Navigator.of(context).pop(); // Fermer la boîte de dialogue
                _loadArticles(); // Recharger la liste des articles
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
              const DataColumn(label: Text('ID')),
              const DataColumn(label: Text('Libellé')),
              const DataColumn(label: Text('Quantité')),
              const DataColumn(label: Text('Prix')),
              const DataColumn(label: Text('Date')),
              DataColumn(
                  label: Text(widget.typeArg < 0 ? 'Montant' : 'Actions')),
            ],
            rows: articles
                .map((article) => DataRow(cells: [
                      DataCell(Text(article.id.toString())),
                      DataCell(Text(article.libelle)),
                      DataCell(Text(widget.typeArg == 2
                          ? (article.quantite * (-1)).toString()
                          : article.quantite.toString())),
                      DataCell(Text(article.prix.toString())),
                      DataCell(Text(article.date.toString().split(" ")[0])),
                      DataCell(
                        widget.typeArg < 0
                            ? Text(NumberFormat()
                                .format((article.quantite * article.prix)))
                            : Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      articleEdit = article;
                                      _libelleController.text = article.libelle;
                                      _quantiteController.text =
                                          article.quantite < 0
                                              ? (article.quantite * (-1))
                                                  .toString()
                                              : article.quantite.toString();
                                      _prixController.text =
                                          article.prix.toString();
                                      setState(() {});
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () {
                                      _confirmDeleteArticle(
                                          article); // Afficher la boîte de confirmation
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
          visible: widget.addArticleVisibility,
          child: SizedBox(
            width: 300,
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
                      title: "Libellé*",
                      controller: _libelleController,
                      focusNode: _libelleFocusNode),
                  TextFormFieldCustom(
                      title: "Quantité",
                      controller: _quantiteController,
                      focusNode: _quantiteFocusNode),
                  TextFormFieldCustom(
                      title: "Prix unitaire",
                      controller: _prixController,
                      focusNode: _prixFocusNode),
                  const SizedBox(
                    height: 10,
                  ),
                  Text("Montant: $_montant"),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Visibility(
                          visible: articleEdit.id != null,
                          child: CustomButton(
                              color: Colors.red,
                              onTap: () {
                                articleEdit = Article.emptyArticle();
                                setState(() {
                                  _libelleController.text = "";
                                  _quantiteController.text = "";
                                  _prixController.text = "";
                                });
                              },
                              text: "Annuler"),
                        ),
                        CustomButton(
                            onTap: () async {
                              String libelle = _libelleController.text;
                              int quantite =
                                  int.tryParse(_quantiteController.text) ?? 0;
                              double prix =
                                  double.tryParse(_prixController.text) ?? 0.0;

                              final dbHelper = DatabaseHelper.instance;
                              //  dbHelper.resetDatabase();
                              if (articleEdit.id == null) {
                                final resul = await dbHelper.createArticle(
                                    Article(
                                        libelle: libelle,
                                        quantite: widget.typeArg == 2
                                            ? quantite * (-1)
                                            : quantite,
                                        prix: prix,
                                        type: widget.typeArg));
                              } else {
                                final resul = await dbHelper.updateArticle(
                                    Article(
                                        id: articleEdit.id,
                                        libelle: libelle,
                                        quantite: widget.typeArg == 2
                                            ? quantite * (-1)
                                            : quantite,
                                        prix: prix,
                                        type: articleEdit.type));
                              }

                              final loadedArticles =
                                  await dbHelper.readAllArticles(
                                      addColumn: widget.colonnesArg,
                                      typeFilter: widget.typeArg < 0
                                          ? null
                                          : widget.typeArg,
                                      groupBy: widget.groupArg);
                              setState(() {
                                articles = loadedArticles;
                                _libelleController.text = "";
                                _quantiteController.text = "";
                                _prixController.text = "";
                              });
                            },
                            text: articleEdit.id != null
                                ? "Modifier"
                                : "Enregistrer"),
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
}

SizedBox TextFormFieldCustom({
  String title = "",
  TextEditingController? controller,
  FocusNode? focusNode,
  minLines,
  maxLines = 1,
}) {
  return SizedBox(
    height: 60,
    child: TextFormField(
      minLines: minLines,
      maxLines: maxLines,
      controller: controller,
      focusNode: focusNode,
      textInputAction: TextInputAction.next,
      onChanged: (value) {},
      decoration: InputDecoration(
        label: Text(title),
        contentPadding: const EdgeInsets.only(left: 10),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue)),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue)),
      ),
    ),
  );
}
