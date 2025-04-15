import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:youth_guide/model/favourite.dart';
import 'package:youth_guide/model/journal.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;
  static final Map<String, List<JournalEntry>> _entryCache = {};
  static final Map<String, bool> _favoriteCache = {};

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
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT,
        devotionalTopic TEXT,
        reflection TEXT,
        devotionalContent TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE favorites(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        devotional_content TEXT NOT NULL,
        date_added TEXT NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_journal_id_date ON journal_entries(id, date);',
    );
    await db.execute('CREATE INDEX idx_favorites_date ON favorites(date);');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'CREATE INDEX idx_journal_id_date ON journal_entries(id, date);',
      );
      await db.execute('CREATE INDEX idx_favorites_date ON favorites(date);');
    }
  }

  Future<int> insertEntry(JournalEntry entry) async {
    final db = await database;
    return await db.transaction((txn) async {
      final id = await txn.insert('journal_entries', entry.toMap());
      _entryCache.clear(); // Invalidate cache
      return id;
    });
  }

  Future<List<JournalEntry>> getEntries() async {
    const cacheKey = 'all_entries';
    if (_entryCache.containsKey(cacheKey)) {
      return _entryCache[cacheKey]!;
    }

    final db = await database;
    final entries = await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query(
        'journal_entries',
        columns: [
          'id',
          'date',
          'devotionalTopic',
          'reflection',
          'devotionalContent',
        ],
        orderBy: 'date DESC',
      );
      return List.generate(maps.length, (i) => JournalEntry.fromMap(maps[i]));
    });

    _entryCache[cacheKey] = entries;
    return entries;
  }

  Future<int> updateEntry(JournalEntry entry) async {
    final db = await database;
    return await db.transaction((txn) async {
      final count = await txn.update(
        'journal_entries',
        entry.toMap(),
        where: 'id = ?',
        whereArgs: [entry.id],
      );
      _entryCache.clear(); // Invalidate cache
      return count;
    });
  }

  Future<int> deleteEntry(int id) async {
    final db = await database;
    return await db.transaction((txn) async {
      final count = await txn.delete(
        'journal_entries',
        where: 'id = ?',
        whereArgs: [id],
      );
      _entryCache.clear(); // Invalidate cache
      return count;
    });
  }

  Future<int> insertFavorite(FavoriteDevotional favorite) async {
    final db = await database;
    return await db.transaction((txn) async {
      final id = await txn.insert('favorites', favorite.toMap());
      _favoriteCache[favorite.date] = true;
      return id;
    });
  }

  Future<void> removeFavorite(String date) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('favorites', where: 'date = ?', whereArgs: [date]);
      _favoriteCache[date] = false;
    });
  }

  Future<bool> isFavorite(String date) async {
    if (_favoriteCache.containsKey(date)) {
      return _favoriteCache[date]!;
    }

    final db = await database;
    final result = await db.transaction((txn) async {
      return await txn.query(
        'favorites',
        columns: ['id'],
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );
    });

    final isFav = result.isNotEmpty;
    _favoriteCache[date] = isFav;
    return isFav;
  }

  Future<List<FavoriteDevotional>> getFavorites() async {
    final db = await database;
    final favorites = await db.transaction((txn) async {
      final List<Map<String, dynamic>> maps = await txn.query(
        'favorites',
        columns: ['id', 'date', 'devotional_content', 'date_added'],
        orderBy: 'date_added DESC',
      );
      return List.generate(
        maps.length,
        (i) => FavoriteDevotional.fromMap(maps[i]),
      );
    });
    // Update favorite cache
    _favoriteCache.clear();
    for (var fav in favorites) {
      _favoriteCache[fav.date] = true;
    }
    return favorites;
  }
}
