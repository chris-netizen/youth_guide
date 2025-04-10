import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:youth_guide/model/favourite.dart';
import 'package:youth_guide/model/journal.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'journal_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create journal entries table
        await db.execute('''
          CREATE TABLE journal_entries(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT,
            devotionalTopic TEXT,
            reflection TEXT,
            devotionalContent TEXT
          )
        ''');

        // Create favorites table
        await db.execute('''
          CREATE TABLE favorites(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            date TEXT NOT NULL,
            devotional_content TEXT NOT NULL,
            date_added TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return await db.insert('journal_entries', entry.toMap());
  }

  Future<List<JournalEntry>> getEntries() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('journal_entries');
    return List.generate(maps.length, (i) => JournalEntry.fromMap(maps[i]));
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.update(
      'journal_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.delete('journal_entries', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertFavorite(FavoriteDevotional favorite) async {
    final db = await database;
    return await db.insert('favorites', favorite.toMap());
  }

  Future<void> removeFavorite(String date) async {
    final db = await database;
    await db.delete('favorites', where: 'date = ?', whereArgs: [date]);
  }

  Future<bool> isFavorite(String date) async {
    final db = await database;
    final result = await db.query(
      'favorites',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.isNotEmpty;
  }

  Future<List<FavoriteDevotional>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) {
      return FavoriteDevotional.fromMap(maps[i]);
    });
  }
}
