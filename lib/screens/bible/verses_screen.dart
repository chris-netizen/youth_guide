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

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;
    _pageController = PageController(initialPage: _currentChapter);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchVerses(int chapter) async {
    final db = await BibleDatabase.database;
    final verses = await db.query(
      'verses',
      where: 'version = ? AND book = ? AND chapter = ?',
      whereArgs: [widget.version, widget.book, chapter],
      orderBy: 'verse ASC',
    );

    final seen = <int>{};
    final uniqueVerses = <Map<String, dynamic>>[];

    for (var verse in verses) {
      final verseNumber = verse['verse'] as int;
      if (!seen.contains(verseNumber)) {
        seen.add(verseNumber);
        uniqueVerses.add(verse);
      }
    }

    return uniqueVerses;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.book} $_currentChapter')),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentChapter = page;
          });
        },
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
                                : AppColors.appBlackColor.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
        // Optional: Set a reasonable limit (e.g., 150 chapters max).
        itemCount: 150,
      ),
    );
  }
}
