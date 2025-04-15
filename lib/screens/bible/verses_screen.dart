import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youth_guide/service/database/bible_db.dart';
import 'package:youth_guide/service/providers/font_provider.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/utils/app_colors.dart';

class VersesScreen extends StatefulWidget {
  final String version;
  final String book;
  final int chapter;

  const VersesScreen({
    super.key,
    required this.version,
    required this.book,
    required this.chapter,
  });

  @override
  State<VersesScreen> createState() => _VersesScreenState();
}

class _VersesScreenState extends State<VersesScreen> {
  late PageController _pageController;
  late int _currentChapter;
  static final Map<String, List<Map<String, dynamic>>> _verseCache = {};
  List<int>? _chapters;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _pageController = PageController(initialPage: _currentChapter);
    _preloadChapters();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadChapters() async {
    final db = await BibleDatabase.database;
    final results = await db.transaction((txn) async {
      return await txn.rawQuery(
        'SELECT DISTINCT chapter FROM verses WHERE version = ? AND book = ? ORDER BY chapter ASC',
        [widget.version, widget.book],
      );
    });
    setState(() {
      _chapters = results.map((e) => e['chapter'] as int).toList();
    });

    // Preload current and adjacent chapters
    final chaptersToLoad = [
      _currentChapter,
      if (_currentChapter > 1) _currentChapter - 1,
      if (_chapters != null && _currentChapter < _chapters!.last)
        _currentChapter + 1,
    ];
    for (var chapter in chaptersToLoad) {
      await fetchVerses(chapter);
    }
  }

  Future<List<Map<String, dynamic>>> fetchVerses(int chapter) async {
    final cacheKey = '${widget.version}-${widget.book}-$chapter';
    if (_verseCache.containsKey(cacheKey)) {
      return _verseCache[cacheKey]!;
    }

    final db = await BibleDatabase.database;
    final verses = await db.transaction((txn) async {
      return await txn.query(
        'verses',
        columns: ['version', 'book', 'chapter', 'verse', 'text'],
        where: 'version = ? AND book = ? AND chapter = ?',
        whereArgs: [widget.version, widget.book, chapter],
        orderBy: 'verse ASC',
        distinct: true,
      );
    });

    _verseCache[cacheKey] = verses;
    // Limit cache size to prevent memory issues
    if (_verseCache.length > 10) {
      _verseCache.remove(_verseCache.keys.first);
    }
    return verses;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.book} $_currentChapter')),
      body:
          _chapters == null
              ? Center(
                child: CircularProgressIndicator(
                  color:
                      themeProvider.isDarkMode
                          ? AppColors.appGreyColor
                          : AppColors.appBlackColor.withAlpha(200),
                ),
              )
              : PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentChapter = page;
                  });
                  // Preload adjacent chapters
                  if (_chapters != null) {
                    final chaptersToLoad = [
                      if (page > 1) page - 1,
                      if (page < _chapters!.last) page + 1,
                    ];
                    for (var chapter in chaptersToLoad) {
                      fetchVerses(chapter);
                    }
                  }
                },
                itemCount: _chapters!.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchVerses(index),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(
                          child: CircularProgressIndicator(
                            color:
                                themeProvider.isDarkMode
                                    ? AppColors.appGreyColor
                                    : AppColors.appBlackColor.withAlpha(200),
                          ),
                        );
                      }

                      final verses = snapshot.data!;
                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: verses.length,
                        itemBuilder: (_, i) {
                          return ListTile(
                            title: Text(
                              '${verses[i]['verse']}. ${verses[i]['text']}',
                              style: GoogleFonts.lora(
                                fontSize: fontSize,
                                color:
                                    themeProvider.isDarkMode
                                        ? AppColors.appGreyColor
                                        : AppColors.appBlackColor.withAlpha(
                                          200,
                                        ),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
    );
  }
}
