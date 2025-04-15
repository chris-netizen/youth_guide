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
    final results = await db.query(
      'verses',
      where: 'version = ? AND book = ? AND chapter = ?',
      whereArgs: [version, book, chapter],
      orderBy: 'verse ASC',
    );

    // Deduplicate results using a Set
    final uniqueVerses = <String, Map<String, dynamic>>{};
    for (var result in results) {
      final key =
          '${result['version']}-${result['book']}-${result['chapter']}-${result['verse']}-${result['text']}';
      uniqueVerses[key] = result;
    }
    return uniqueVerses.values.toList();
  }

  Future<List<Map<String, dynamic>>> getVerseFromReference(
    String reference,
    String version,
  ) async {
    final db = await BibleDatabase.database;

    // Split reference into book and chapter:verse parts
    final parts = reference.split(RegExp(r'\s*:\s*'));
    if (parts.length != 2) return [];

    // Split the first part into book name and chapter
    final verseParts = parts[0].trim().split(' ');
    if (verseParts.isEmpty) return [];

    final chapter = int.tryParse(verseParts.last.trim()) ?? 1;
    final bookInput =
        verseParts.sublist(0, verseParts.length - 1).join(' ').trim();

    // Parse verse part for single verse or range
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

    // Function to query books with a prefix of given length
    Future<List<String>> findMatchingBooks(String prefix) async {
      final result = await db.rawQuery(
        'SELECT DISTINCT book FROM verses WHERE version = ? AND book LIKE ?',
        [version, '$prefix%'],
      );
      return result.map((row) => row['book'] as String).toList();
    }

    // Start with the first 3 characters of the book name
    String book = bookInput;
    int prefixLength = 3;

    // If the book name is shorter than 3 characters, use it directly
    if (bookInput.length < 3) {
      prefixLength = bookInput.length;
    }

    while (prefixLength <= bookInput.length) {
      final prefix = bookInput.substring(0, prefixLength).toLowerCase();
      final matchingBooks = await findMatchingBooks(prefix);

      if (matchingBooks.isEmpty) {
        // No matches found, return empty result
        return [];
      } else if (matchingBooks.length == 1) {
        // Unique match found, use this book
        book = matchingBooks.first;
        break;
      } else {
        // Multiple matches, try a longer prefix
        prefixLength++;
      }
    }

    // If no unique match was found, try exact match as fallback
    if (prefixLength > bookInput.length) {
      final exactMatch = await findMatchingBooks(bookInput);
      if (exactMatch.isNotEmpty) {
        book = exactMatch.first;
      } else {
        return [];
      }
    }

    // Query the verse(s) with the matched book name and version
    List<Map<String, dynamic>> results;
    if (endVerse != null && endVerse >= startVerse) {
      // Query a range of verses
      results = await db.query(
        'verses',
        where:
            'version = ? AND book = ? AND chapter = ? AND verse >= ? AND verse <= ?',
        whereArgs: [version, book, chapter, startVerse, endVerse],
      );
    } else {
      // Query a single verse
      results = await db.query(
        'verses',
        where: 'version = ? AND book = ? AND chapter = ? AND verse = ?',
        whereArgs: [version, book, chapter, startVerse],
      );
    }

    // Deduplicate results using a Set
    final uniqueVerses = <String, Map<String, dynamic>>{};
    for (var result in results) {
      final key =
          '${result['version']}-${result['book']}-${result['chapter']}-${result['verse']}-${result['text']}';
      uniqueVerses[key] = result;
    }
    return uniqueVerses.values.toList();
  }
}
