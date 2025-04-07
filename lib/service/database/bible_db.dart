import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BibleDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'bible.db');
    _db = await openDatabase(path, version: 1, onCreate: _createDb);
    return _db!;
  }

  static Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE verses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        version TEXT,
        book TEXT,
        chapter INTEGER,
        verse INTEGER,
        text TEXT
      )
    ''');
  }
}
