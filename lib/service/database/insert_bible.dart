import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:youth_guide/service/database/bible_db.dart';

Future<void> insertBibleFromJson(String jsonString, String version) async {
  final data = jsonDecode(jsonString) as Map<String, dynamic>;
  final db = await BibleDatabase.database;

  Batch batch = db.batch();

  data.forEach((book, chapters) {
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
}
