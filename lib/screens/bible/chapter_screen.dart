// chapter_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youth_guide/screens/bible/verses_screen.dart';
import 'package:youth_guide/service/database/bible_db.dart';
import 'package:youth_guide/service/providers/font_provider.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/utils/app_colors.dart';

class ChapterScreen extends StatefulWidget {
  final String version;
  final String book;

  const ChapterScreen({super.key, required this.version, required this.book});

  @override
  State<ChapterScreen> createState() => _ChapterScreenState();
}

class _ChapterScreenState extends State<ChapterScreen> {
  late final ScrollController _scrollController;
  static final Map<String, List<int>> _chapterCache = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<int>> fetchChapters() async {
    final cacheKey = '${widget.version}-${widget.book}';
    if (_chapterCache.containsKey(cacheKey)) {
      return _chapterCache[cacheKey]!;
    }

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
      final chapters = results.map((e) => e['chapter'] as int).toList();
      _chapterCache[cacheKey] = chapters;
      return chapters;
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load chapters: $e';
      });
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      appBar: AppBar(title: Text('${widget.book} - Chapters')),
      body: FutureBuilder<List<int>>(
        future: fetchChapters(),
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

          if (snapshot.hasError || _errorMessage != null) {
            return Center(
              child: Text(
                _errorMessage ?? 'An error occurred.',
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

          final chapters = snapshot.data ?? [];
          if (chapters.isEmpty) {
            return Center(
              child: Text(
                'No chapters found.',
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

          return Scrollbar(
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(8),
            controller: _scrollController,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chapters.length,
              itemBuilder:
                  (_, index) => ListTile(
                    title: Text(
                      'Chapter ${chapters[index]}',
                      style: GoogleFonts.lora(
                        fontSize: fontSize,
                        color:
                            themeProvider.isDarkMode
                                ? AppColors.appGreyColor
                                : AppColors.appBlackColor.withAlpha(200),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => VersesScreen(
                                version: widget.version,
                                book: widget.book,
                                chapter: chapters[index],
                              ),
                        ),
                      );
                    },
                  ),
            ),
          );
        },
      ),
    );
  }
}
