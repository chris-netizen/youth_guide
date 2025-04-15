// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:youth_guide/screens/devotion/devotional_content.dart';
import 'package:youth_guide/service/database/sqldb.dart';
import 'package:youth_guide/model/journal.dart';
import 'package:youth_guide/service/providers/font_provider.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/service/providers/tts_provider.dart';
import 'package:youth_guide/utils.dart';
import 'package:youth_guide/utils/app_colors.dart';

class DevotionalPage extends StatefulWidget {
  final List<Map<String, dynamic>> dailyDevotionals;
  final int initialIndex;
  const DevotionalPage({
    super.key,
    required this.initialIndex,
    required this.dailyDevotionals,
  });

  @override
  State<DevotionalPage> createState() => _DevotionalPageState();
}

class _DevotionalPageState extends State<DevotionalPage> {
  bool isFavorite = false;

  String? formattedDate;

  String? content;
  String? reference;

  late PageController _pageController;
  late int _currentIndex;

  final TextEditingController _journalController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);

    _scrollController.addListener(() {
      if (_scrollController.offset > 40 && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (_scrollController.offset <= 40 && _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    });
  }

  void _openJournalDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        final fontSize = Provider.of<FontSizeProvider>(context).fontSize;
        return AlertDialog(
          title: Text(
            'Personal Reflection',
            style: GoogleFonts.lora(
              fontSize: fontSize + 2,
              color:
                  themeProvider.isDarkMode
                      ? AppColors.appGoldColor
                      : AppColors.appBlackColor.withAlpha(200),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Topic: ${widget.dailyDevotionals[_currentIndex]['topic']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode
                            ? AppColors.appGreyColor
                            : AppColors.appBlackColor.withAlpha(200),
                    fontSize: fontSize - 2,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _journalController,
                  maxLines: 5,
                  cursorColor:
                      themeProvider.isDarkMode
                          ? AppColors.appGoldColor
                          : AppColors.appBlackColor.withAlpha(200),
                  decoration: InputDecoration(
                    hintText: 'Write your thoughts and reflections...',
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color:
                            themeProvider.isDarkMode
                                ? AppColors.appGoldColor
                                : AppColors.appBlackColor.withAlpha(200),
                      ),
                    ),
                    filled: true,
                    fillColor:
                        themeProvider.isDarkMode
                            ? AppColors.appGreyColor.withAlpha(50)
                            : AppColors.appWhiteColor,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color:
                      themeProvider.isDarkMode
                          ? AppColors.appGoldColor
                          : AppColors.appBlackColor.withAlpha(200),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_journalController.text.isNotEmpty) {
                  // Create a sanitized copy of the devotional content
                  final sanitizedDevotional = Map<String, dynamic>.from(
                    widget.dailyDevotionals[_currentIndex],
                  );

                  // Convert Timestamp to ISO string if it exists
                  if (sanitizedDevotional['date'] != null) {
                    RegExp regExp = RegExp(
                      r'seconds=(\d+),\s*nanoseconds=(\d+)',
                    );
                    Match? match = regExp.firstMatch(
                      '${sanitizedDevotional['date']}',
                    );

                    if (match != null) {
                      int seconds = int.parse(match.group(1)!);
                      int nanoseconds = int.parse(match.group(2)!);

                      int milliseconds =
                          (seconds * 1000) + (nanoseconds ~/ 1000000);
                      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
                        milliseconds,
                      );
                      sanitizedDevotional['date'] = dateTime.toIso8601String();
                    }
                  }

                  final entry = JournalEntry(
                    date: formattedDate ?? DateTime.now().toString(),
                    devotionalTopic:
                        widget.dailyDevotionals[_currentIndex]['topic'] ?? '',
                    reflection: _journalController.text,
                    devotionalContent: json.encode(
                      widget.dailyDevotionals[_currentIndex]['message'],
                    ),
                  );

                  await _databaseHelper.insertEntry(entry);
                  _journalController.clear();
                  if (!mounted) return;
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Reflection saved successfully!',
                        style: TextStyle(
                          color:
                              themeProvider.isDarkMode
                                  ? AppColors.appBlackColor
                                  : AppColors.appGreyColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      backgroundColor:
                          themeProvider.isDarkMode
                              ? AppColors.appGoldColor
                              : AppColors.appBlackColor,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<String> get devotionText => [
    formattedDate ?? "",
    "Topic",
    widget.dailyDevotionals[_currentIndex]['topic'] ?? '',
    "Text",
    widget.dailyDevotionals[_currentIndex]['text'] ?? '',
    "Memory Verse",
    widget.dailyDevotionals[_currentIndex]['memory verse'] ?? '',
    "Message",
    widget.dailyDevotionals[_currentIndex]['message'] ?? '',
    "Wisdom Shot",
    widget.dailyDevotionals[_currentIndex]['wisdom shot'] ?? '',
    "Prayer",
    widget.dailyDevotionals[_currentIndex]['prayer'] ?? '',
  ];

  @override
  Widget build(BuildContext context) {
    RegExp regExp = RegExp(r'seconds=(\d+),\s*nanoseconds=(\d+)');
    Match? match = regExp.firstMatch(
      '${widget.dailyDevotionals[_currentIndex]['date']}',
    );

    if (match != null) {
      int seconds = int.parse(match.group(1)!);
      int nanoseconds = int.parse(match.group(2)!);

      int milliseconds = (seconds * 1000) + (nanoseconds ~/ 1000000);
      DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(milliseconds);

      String ordinalDay = getOrdinal(dateTime.day);
      formattedDate =
          '${DateFormat('EEEE').format(dateTime)}, $ordinalDay ${DateFormat('MMMM yyyy').format(dateTime)}';

      log(formattedDate ?? '');
    }

    final themeProvider = Provider.of<ThemeProvider>(context);
    final ttsProvider = Provider.of<TtsProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            ttsProvider.stop();
          });
        },
        itemCount: widget.dailyDevotionals.length,
        itemBuilder: (context, index) {
          final devotional = widget.dailyDevotionals[index];
          final parsed = BibleVerseParser.parseVerse(
            widget.dailyDevotionals[_currentIndex]['memory verse'],
          );

          content = parsed['content'];
          reference = parsed['reference'];
          return DevotionalContent(
            scrollController: _scrollController,
            themeProvider: themeProvider,
            isCollapsed: _isCollapsed,
            formattedDate: formattedDate,
            ttsProvider: ttsProvider,
            devotionText: devotionText,
            fontSize: fontSize,
            fontSizeProvider: fontSizeProvider,
            content: content,
            reference: reference,
            dailyDevotional: devotional,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openJournalDialog,
        child: Icon(Icons.edit_note),
      ),
    );
  }
}
