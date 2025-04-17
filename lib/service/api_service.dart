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
    try {
      final db = await BibleDatabase.database;
      final results = await db.query(
        'verses',
        columns: ['version', 'book', 'chapter', 'verse', 'text'],
        where: 'version = ? AND book = ? AND chapter = ?',
        whereArgs: [version, book, chapter],
        orderBy: 'verse ASC',
        distinct: true,
      );
      return results;
    } catch (e) {
      debugPrint('Error fetching chapter $book $chapter ($version): $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getVerseFromReference(
    String reference,
    String version,
  ) async {
    try {
      final db = await BibleDatabase.database;
      final parts = reference.split(RegExp(r'\s*:\s*'));
      if (parts.length != 2) return [];

      final verseParts = parts[0].trim().split(' ');
      if (verseParts.isEmpty) return [];

      final chapter = int.tryParse(verseParts.last.trim()) ?? 1;
      final bookInput =
          verseParts.sublist(0, verseParts.length - 1).join(' ').trim();

      final versePart = parts[1].trim();
      int startVerse = 1;
      int? endVerse;

      if (versePart.contains('-')) {
        final verseRange = versePart.split('-');
        if (verseRange.length == 2) {
          startVerse = int.tryParse(verseRange[0].trim()) ?? 1;
          endVerse = int.tryParse(verseRange[1].trim()) ?? startVerse;
        }
      } else {
        startVerse = int.tryParse(versePart) ?? 1;
      }

      String? book;
      var books = await db.query(
        'books',
        columns: ['book'],
        where: 'version = ? AND book = ?',
        whereArgs: [version, bookInput],
      );
      if (books.isNotEmpty) {
        book = books.first['book'] as String;
      } else {
        books = await db.query(
          'books',
          columns: ['book'],
          where: 'version = ? AND book LIKE ?',
          whereArgs: [version, '$bookInput%'],
        );
        if (books.length == 1) {
          book = books.first['book'] as String;
        }
      }

      if (book == null) return [];

      List<Map<String, dynamic>> results;
      if (endVerse != null && endVerse >= startVerse) {
        results = await db.query(
          'verses',
          columns: ['version', 'book', 'chapter', 'verse', 'text'],
          where:
              'version = ? AND book = ? AND chapter = ? AND verse >= ? AND verse <= ?',
          whereArgs: [version, book, chapter, startVerse, endVerse],
          orderBy: 'verse ASC',
          distinct: true,
        );
      } else {
        results = await db.query(
          'verses',
          columns: ['version', 'book', 'chapter', 'verse', 'text'],
          where: 'version = ? AND book = ? AND chapter = ? AND verse = ?',
          whereArgs: [version, book, chapter, startVerse],
          distinct: true,
        );
      }
      return results;
    } catch (e) {
      debugPrint('Error fetching verse $reference ($version): $e');
      return [];
    }
  }
}
