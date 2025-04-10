import 'package:flutter/services.dart';
import 'package:youth_guide/service/database/insert_bible.dart';

enum AppVersions { kjv, niv, nkjv, nlt }

class Versions {
  Versions._();

  static final Versions instance = Versions._();

  Future<void> loadBibleVersions() async {
    String kjvJson = await rootBundle.loadString('assets/bible/KJV_bible.json');
    await insertBibleFromJson(kjvJson, AppVersions.kjv.name);

    String nitJson = await rootBundle.loadString('assets/bible/NIV_bible.json');
    await insertBibleFromJson(nitJson, AppVersions.niv.name);

    String nkjvJson = await rootBundle.loadString(
      'assets/bible/NKJV_bible.json',
    );
    await insertBibleFromJson(nkjvJson, AppVersions.nkjv.name);

    String nltJson = await rootBundle.loadString('assets/bible/NLT_bible.json');
    await insertBibleFromJson(nltJson, AppVersions.nlt.name);
  }

  AppVersions? appVersion;
}
