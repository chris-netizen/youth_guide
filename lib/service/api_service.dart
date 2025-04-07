import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:youth_guide/service/database/bible_db.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection(collection).get();

      return querySnapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting collection: $e');
      }
      rethrow;
    }
  }
}

class BibleService {
  Future<List<Map<String, dynamic>>> getChapter(
    String version,
    String book,
    int chapter,
  ) async {
    final db = await BibleDatabase.database;
    return db.query(
      'verses',
      where: 'version = ? AND book = ? AND chapter = ?',
      whereArgs: [version, book, chapter],
      orderBy: 'verse ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getVerseFromReference(
    String reference,
  ) async {
    final db = await BibleDatabase.database;

    final parts = reference.split(RegExp(r'\s*:\s*'));
    if (parts.length != 2) return [];

    final verseParts = parts[0].trim().split(' ');
    final book = verseParts.sublist(0, verseParts.length - 1).join(' ');
    final chapter = int.tryParse(verseParts.last.trim()) ?? 1;
    final verseNumber = int.tryParse(parts[1].trim()) ?? 1;

    return db.query(
      'verses',
      where: 'book = ? AND chapter = ? AND verse = ?',
      whereArgs: [book, chapter, verseNumber],
    );
  }
}
