import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:youth_guide/service/api_service.dart';
import 'package:youth_guide/service/database/versions.dart';

class LocalBibleProvider with ChangeNotifier {
  bool isLoading = false;
  List<String> verses = [];
  static const String _versionKey = 'selectedBibleVersion';
  String _selectedVersion = AppVersions.kjv.name;

  String get selectedVersion => _selectedVersion;

  LocalBibleProvider() {
    _loadVersionFromPrefs();
  }

  void setVersion(String version) async {
    _selectedVersion = version;
    notifyListeners();
    await _saveVersionToPrefs();
  }

  Future<void> _loadVersionFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedVersion = prefs.getString(_versionKey) ?? AppVersions.kjv.name;
    notifyListeners();
  }

  Future<void> _saveVersionToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_versionKey, _selectedVersion);
  }

  Future<void> loadChapter(String book, int chapter) async {
    isLoading = true;
    notifyListeners();

    final results = await BibleService().getChapter(
      _selectedVersion,
      book,
      chapter,
    );
    verses = results.map((v) => '${v['verse']}. ${v['text']}').toList();

    isLoading = false;
    notifyListeners();
  }
}
