import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class BibleDatabase {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'bible.db');
    _db = await openDatabase(
      path,
      version: 2,
      onCreate: _createDb,
      onUpgrade: _upgradeDb,
    );
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
    await db.execute('''
      CREATE TABLE books (
        version TEXT,
        book TEXT,
        PRIMARY KEY (version, book)
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_version_book_chapter_verse ON verses(version, book, chapter, verse);',
    );
  }

  static Future<void> _upgradeDb(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE books (
          version TEXT,
          book TEXT,
          PRIMARY KEY (version, book)
        )
      ''');
      await db.execute(
        'CREATE INDEX idx_version_book_chapter_verse ON verses(version, book, chapter, verse);',
      );
      // Populate books table from verses
      final versions = await db.rawQuery('SELECT DISTINCT version FROM verses');
      for (var versionRow in versions) {
        final version = versionRow['version'] as String;
        final books = await db.rawQuery(
          'SELECT DISTINCT book FROM verses WHERE version = ? ORDER BY book ASC',
          [version],
        );
        final batch = db.batch();
        for (var bookRow in books) {
          final book = bookRow['book'] as String;
          batch.rawInsert(
            'INSERT OR IGNORE INTO books (version, book) VALUES (?, ?)',
            [version, book],
          );
        }
        await batch.commit();
      }
    }
  }

  static Future<void> populateBooks(String version, List<String> books) async {
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var book in books) {
        batch.rawInsert(
          'INSERT OR IGNORE INTO books (version, book) VALUES (?, ?)',
          [version, book],
        );
      }
      await batch.commit();
    });
  }
}
