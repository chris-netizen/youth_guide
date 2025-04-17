// bible_screen.dart
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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final version =
          Provider.of<LocalBibleProvider>(
            context,
            listen: false,
          ).selectedVersion;
      final db = await BibleDatabase.database;
      final results = await db.query(
        'books',
        columns: ['book'],
        where: 'version = ?',
        whereArgs: [version],
        orderBy: 'book ASC',
        distinct: true,
      );
      setState(() {
        _allBooks = results.map((e) => e['book'] as String).toList();
        _filteredBooks = List.from(_allBooks);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load books: $e';
      });
    }
  }

  void _filterBooks(String query) {
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
