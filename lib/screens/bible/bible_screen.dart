import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youth_guide/screens/bible/chapter_screen.dart';
import 'package:youth_guide/service/database/bible_db.dart';
import 'package:youth_guide/service/providers/bible_provider.dart';
import 'package:youth_guide/service/providers/font_provider.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/utils/app_colors.dart';

class BibleScreen extends StatefulWidget {
  const BibleScreen({super.key});

  @override
  State<BibleScreen> createState() => _BibleScreenState();
}

class _BibleScreenState extends State<BibleScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _allBooks = [];
  List<String> _filteredBooks = [];
  bool _isLoading = true;
  Timer? _debounce;
  static final Map<String, List<String>> _bookCache = {};

  @override
  void initState() {
    super.initState();
    final version =
        Provider.of<LocalBibleProvider>(context, listen: false).selectedVersion;
    if (mounted) {
      fetchBooks(version);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchBooks(String version) async {
    if (_bookCache.containsKey(version)) {
      setState(() {
        _allBooks = _bookCache[version]!;
        _filteredBooks = List.from(_allBooks);
        _isLoading = false;
      });
      return;
    }

    final db = await BibleDatabase.database;
    final results = await db.rawQuery(
      'SELECT book FROM books WHERE version = ? ORDER BY book ASC',
      [version],
    );
    setState(() {
      _allBooks = results.map((e) => e['book'] as String).toList();
      _bookCache[version] = _allBooks;
      _filteredBooks = List.from(_allBooks);
      _isLoading = false;
    });
  }

  void _filterBooks(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        if (query.isEmpty) {
          _filteredBooks = List.from(_allBooks);
        } else {
          _filteredBooks =
              _allBooks
                  .where(
                    (book) => book.toLowerCase().contains(query.toLowerCase()),
                  )
                  .toList();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final version = Provider.of<LocalBibleProvider>(context).selectedVersion;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bible'),
        actions: [
          Text(
            '$version Version',
            style: GoogleFonts.lora(
              fontSize: fontSize,
              color:
                  themeProvider.isDarkMode
                      ? AppColors.appGreyColor
                      : AppColors.appBlackColor.withAlpha(200),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body:
          _isLoading
              ? Center(
                child: CircularProgressIndicator(
                  color:
                      themeProvider.isDarkMode
                          ? AppColors.appGreyColor
                          : AppColors.appBlackColor.withAlpha(200),
                ),
              )
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _filterBooks,
                      decoration: InputDecoration(
                        hintText: 'Search books...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                themeProvider.isDarkMode
                                    ? AppColors.appGreyColor
                                    : AppColors.appBlackColor.withAlpha(200),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredBooks.isEmpty
                            ? Center(
                              child: Text(
                                'No books found.',
                                style: GoogleFonts.lora(
                                  fontSize: fontSize,
                                  color:
                                      themeProvider.isDarkMode
                                          ? AppColors.appGreyColor
                                          : AppColors.appBlackColor.withAlpha(
                                            200,
                                          ),
                                ),
                              ),
                            )
                            : ListView.builder(
                              itemCount: _filteredBooks.length,
                              itemBuilder:
                                  (_, index) => ListTile(
                                    title: Text(
                                      _filteredBooks[index],
                                      style: GoogleFonts.lora(
                                        fontSize: fontSize,
                                        color:
                                            themeProvider.isDarkMode
                                                ? AppColors.appGreyColor
                                                : AppColors.appBlackColor
                                                    .withAlpha(200),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (_) => ChapterScreen(
                                                version: version,
                                                book: _filteredBooks[index],
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                            ),
                  ),
                ],
              ),
    );
  }
}
