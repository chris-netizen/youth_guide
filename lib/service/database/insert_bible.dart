// insert_bible.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:youth_guide/service/database/bible_db.dart';

Future<void> insertBibleFromJson(String jsonString, String version) async {
  try {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    final db = await BibleDatabase.database;
    final List<String> books = [];

    Batch batch = db.batch();
    data.forEach((book, chapters) {
      books.add(book);
      (chapters as Map<String, dynamic>).forEach((chapter, verses) {
        (verses as Map<String, dynamic>).forEach((verse, text) {
          batch.insert('verses', {
            'version': version,
            'book': book,
            'chapter': int.parse(chapter),
            'verse': int.parse(verse),
            'text': text,
          });
        });
      });
    });
    await batch.commit(noResult: true);
    await BibleDatabase.populateBooks(version, books);
  } catch (e) {
    debugPrint('Error inserting Bible data for $version: $e');
    rethrow;
  }
}
