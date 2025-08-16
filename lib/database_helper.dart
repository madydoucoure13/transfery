import 'dart:io';

import 'package:fere/articles_model.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init() {
    // Initialisation spécifique pour Windows avec sqflite_common_ffi
    //if (Platform.isWindows) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
   // }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('articles.db');
    return _database!;
  }

  // Initialisation de la base de données
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationSupportDirectory();
    final path = join(dbPath.path, filePath);
    print("voici le link =================");
    print(path);
    return await databaseFactoryFfi.openDatabase(path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: _createDB,
        ));
  }

  // Création de la table articles
  Future _createDB(Database db, int version) async {
    const articleTable = '''
    CREATE TABLE articles (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      libelle TEXT NOT NULL,
      quantite INTEGER NOT NULL,
      prix REAL NOT NULL,
      date TEXT NOT NULL,
      type INTEGER DEFAULT 0
    )
    ''';
    await db.execute(articleTable);
  }

  // CRUD: Create (Ajouter un article)
  Future<int> createArticle(Article article) async {
    final db = await instance.database;
    return await db.insert('articles', article.toMap());
  }

  // CRUD: Read (Récupérer un article par id)
  Future<Article?> readArticle(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      'articles',
      columns: ['id', 'libelle', 'quantite', 'prix', 'date', 'type'],
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Article.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // CRUD: Read All (Récupérer tous les articles)
  Future<List<Article>> readAllArticles({
    String orderBy = 'id DESC',
    bool addColumn = false,
    int? typeFilter,
    List<String>?
        groupBy, // Paramètre optionnel pour GROUP BY, acceptant plusieurs colonnes
  }) async {
    final db = await instance.database;
    final dbPath1 = await getApplicationSupportDirectory();
    print("voici le chemminn de la base données");
    print(dbPath1);
    print("fin du cheminn ----------------------->");
    // Construction de la clause WHERE en fonction de typeFilter
    final whereClause = typeFilter != null ? 'type = ?' : null;
    final whereArgs = typeFilter != null ? [typeFilter] : null;

    // Construction de la clause GROUP BY si des colonnes sont fournies
    final groupByClause =
        groupBy != null && groupBy.isNotEmpty ? groupBy.join(', ') : null;

    final columns = [
      'libelle',
      'SUM(quantite) as quantite', // Calcul de la somme des quantités
      'prix',
      'date',
      'type',
    ];
    final result = await db.query(
      'articles',
      columns: addColumn ? columns : null,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: orderBy, // Applique l'ordre ici
      groupBy: groupByClause, // Applique GROUP BY si fourni
    );

    return result.map((map) => Article.fromMap(map)).toList();
  }

  // CRUD: Update (Mettre à jour un article)
  Future<int> updateArticle(Article article) async {
    final db = await instance.database;
    print(article.type);
    return await db.update(
      'articles',
      article.toMap(),
      where: 'id = ?',
      whereArgs: [article.id],
    );
  }

  // CRUD: Delete (Supprimer un article)
  Future<int> deleteArticle(int id) async {
    final db = await instance.database;

    return await db.delete(
      'articles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Méthode pour supprimer la base de données
  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'articles.db');

    // Supprime la base de données
    await deleteDatabase(path);

    // Réinitialise la connexion à la base de données
    _database = null;
  }

// Fonction pour sauvegarder la base de données
  Future<void> backupDatabase() async {
    try {
      // Chemin de la base de données
      final dbPath = await getApplicationSupportDirectory();
      final sourcePath = join(dbPath.path, 'articles.db');

      // Emplacement pour la sauvegarde
      // final backupDir =
      //     await getExternalStorageDirectory(); // Utilise l'emplacement de stockage externe
      Directory? downloadDir = await getDownloadsDirectory();
      final backupPath = join(downloadDir!.path, 'backup_articles.db');

      // Copier la base de données
      final backupFile = await File(sourcePath).copy(backupPath);

      print('Sauvegarde réussie : ${backupFile.path}');
    } catch (e) {
      print('Erreur lors de la sauvegarde : $e');
    }
  }

  Future<void> backupDatabase2() async {
    // Obtenir le chemin de la base de données existante
    Directory appDocDir = await getApplicationDocumentsDirectory();
    String dbPath = join(appDocDir.path, "articles.db");

    // Vérifie si le fichier de la base de données existe
    File dbFile = File(dbPath);
    if (await dbFile.exists()) {
      // Créer un dossier pour sauvegarde dans les documents
      String backupFolder = join(appDocDir.path, "backup");
      Directory(backupFolder).createSync(); // Crée le dossier s'il n'existe pas

      // Définir le chemin de sauvegarde
      String backupPath = join(backupFolder, 'articles.db');

      // Copier le fichier de la base de données vers le chemin de sauvegarde
      await dbFile.copy(backupPath);

      print("Base de données sauvegardée avec succès dans $backupPath");
    } else {
      print("Le fichier de base de données n'existe pas.");
    }
  }

  // Fermer la base de données
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
