// versions.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youth_guide/service/database/insert_bible.dart';

enum AppVersions { kjv, niv, nkjv, nlt }

class Versions {
  Versions._();
  static final Versions instance = Versions._();

  Future<void> loadBibleVersions() async {
    try {
      final versions = [
        {
          'file': 'assets/bible/KJV_bible.json',
          'version': AppVersions.kjv.name,
        },
        {
          'file': 'assets/bible/NIV_bible.json',
          'version': AppVersions.niv.name,
        },
        {
          'file': 'assets/bible/NKJV_bible.json',
          'version': AppVersions.nkjv.name,
        },
        {
          'file': 'assets/bible/NLT_bible.json',
          'version': AppVersions.nlt.name,
        },
      ];

      for (var version in versions) {
        final jsonString = await rootBundle.loadString(version['file']!);
        await insertBibleFromJson(jsonString, version['version']!);
      }
    } catch (e) {
      debugPrint('Error loading Bible versions: $e');
      rethrow;
    }
  }
}
