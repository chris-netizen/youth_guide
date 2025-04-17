// verses_screen.dart
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _pageController = PageController(initialPage: _currentChapter - 1);
    _loadChapters();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadChapters() async {
    try {
      final db = await BibleDatabase.database;
      final results = await db.query(
        'verses',
        columns: ['chapter'],
        where: 'version = ? AND book = ?',
        whereArgs: [widget.version, widget.book],
        orderBy: 'chapter ASC',
        distinct: true,
      );
      setState(() {
        _chapters = results.map((e) => e['chapter'] as int).toList();
      });
      await fetchVerses(_currentChapter);
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load chapters: $e';
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchVerses(int chapter) async {
    final cacheKey = '${widget.version}-${widget.book}-$chapter';
    if (_verseCache.containsKey(cacheKey)) {
      return _verseCache[cacheKey]!;
    }

    try {
      final db = await BibleDatabase.database;
      final verses = await db.query(
        'verses',
        columns: ['version', 'book', 'chapter', 'verse', 'text'],
        where: 'version = ? AND book = ? AND chapter = ?',
        whereArgs: [widget.version, widget.book, chapter],
        orderBy: 'verse ASC',
        distinct: true,
      );
      _verseCache[cacheKey] = verses;
      if (_verseCache.length > 10) {
        _verseCache.remove(_verseCache.keys.first);
      }
      return verses;
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load verses: $e';
      });
      return [];
    }
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
              : _errorMessage != null
              ? Center(
                child: Text(
                  _errorMessage!,
                  style: GoogleFonts.lora(
                    fontSize: fontSize,
                    color:
                        themeProvider.isDarkMode
                            ? AppColors.appGreyColor
                            : AppColors.appBlackColor.withAlpha(200),
                  ),
                ),
              )
              : PageView.builder(
                controller: _pageController,
                onPageChanged: (page) {
                  setState(() {
                    _currentChapter = _chapters![page];
                  });
                  fetchVerses(_currentChapter);
                },
                itemCount: _chapters!.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<List<Map<String, dynamic>>>(
                    future: fetchVerses(_chapters![index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(
                            color:
                                themeProvider.isDarkMode
                                    ? AppColors.appGreyColor
                                    : AppColors.appBlackColor.withAlpha(200),
                          ),
                        );
                      }

                      if (snapshot.hasError || !snapshot.hasData) {
                        return Center(
                          child: Text(
                            'Failed to load verses.',
                            style: GoogleFonts.lora(
                              fontSize: fontSize,
                              color:
                                  themeProvider.isDarkMode
                                      ? AppColors.appGreyColor
                                      : AppColors.appBlackColor.withAlpha(200),
                            ),
                          ),
                        );
                      }

                      final verses = snapshot.data!;
                      if (verses.isEmpty) {
                        return Center(
                          child: Text(
                            'No verses found.',
                            style: GoogleFonts.lora(
                              fontSize: fontSize,
                              color:
                                  themeProvider.isDarkMode
                                      ? AppColors.appGreyColor
                                      : AppColors.appBlackColor.withAlpha(200),
                            ),
                          ),
                        );
                      }

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
