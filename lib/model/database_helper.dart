import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('favorites.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        channelName TEXT UNIQUE
      )
    ''');
  }

  Future<int> addFavorite(String channelName) async {
    final db = await database;
    return await db.insert('favorites', {
      'channelName': channelName,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<int> removeFavorite(String channelName) async {
    final db = await database;
    return await db.delete(
      'favorites',
      where: 'channelName = ?',
      whereArgs: [channelName],
    );
  }

  Future<List<String>> getFavorites() async {
    final db = await database;
    final result = await db.query('favorites');
    return result.map((row) => row['channelName'] as String).toList();
  }
}
