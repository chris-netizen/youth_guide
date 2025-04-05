// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youth_guide/service/database/sqldb.dart';
import 'package:youth_guide/screens/devotion/devotional_section.dart';
import 'package:youth_guide/screens/journal/journal_screen.dart';
import 'package:youth_guide/model/journal.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/utils.dart';
import 'package:youth_guide/utils/app_colors.dart';

class DevotionalPage extends StatefulWidget {
  final Map<String, dynamic> dailyDevotional;
  const DevotionalPage({super.key, required this.dailyDevotional});

  @override
  State<DevotionalPage> createState() => _DevotionalPageState();
}

class _DevotionalPageState extends State<DevotionalPage> {
  bool isFavorite = false;
  double fontSize = 18.0;

  String? formattedDate;

  String? content;
  String? reference;

  final TextEditingController _journalController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  @override
  void initState() {
    super.initState();
    final parsed = BibleVerseParser.parseVerse(
      widget.dailyDevotional['memory verse'],
    );

    content = parsed['content'];
    reference = parsed['reference'];

    _scrollController.addListener(() {
      if (_scrollController.offset > 50 && !_isCollapsed) {
        setState(() {
          _isCollapsed = true;
        });
      } else if (_scrollController.offset <= 50 && _isCollapsed) {
        setState(() {
          _isCollapsed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _journalController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _openJournalDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Personal Reflection',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Topic: ${widget.dailyDevotional['topic']}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _journalController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Write your thoughts and reflections...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_journalController.text.isNotEmpty) {
                    // Create a sanitized copy of the devotional content
                    final sanitizedDevotional = Map<String, dynamic>.from(
                      widget.dailyDevotional,
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
                        sanitizedDevotional['date'] =
                            dateTime.toIso8601String();
                      }
                    }

                    final entry = JournalEntry(
                      date: formattedDate ?? DateTime.now().toString(),
                      devotionalTopic: widget.dailyDevotional['topic'],
                      reflection: _journalController.text,
                      devotionalContent: json.encode(
                        sanitizedDevotional,
                      ), // Now using sanitized content
                    );

                    await _databaseHelper.insertEntry(entry);
                    _journalController.clear();
                    if (!mounted) return;
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Reflection saved successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    RegExp regExp = RegExp(r'seconds=(\d+),\s*nanoseconds=(\d+)');
    Match? match = regExp.firstMatch('${widget.dailyDevotional['date']}');

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
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor:
                themeProvider.isDarkMode
                    ? AppColors.appBlackColor
                    : AppColors.appWhiteColor,

            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Daily Devotional',
                style: GoogleFonts.lora(
                  textStyle: TextStyle(
                    color:
                        !themeProvider.isDarkMode && _isCollapsed
                            ? AppColors.appBlackColor
                            : !themeProvider.isDarkMode && !_isCollapsed
                            ? AppColors.appWhiteColor
                            : themeProvider.isDarkMode && !_isCollapsed
                            ? AppColors.appBlackColor
                            : AppColors.appWhiteColor,
                  ),
                ),
              ),

              background: Container(
                decoration: BoxDecoration(
                  color:
                      themeProvider.isDarkMode
                          ? AppColors.appGoldColor
                          : AppColors.appGreyColor,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formattedDate!
                            .split(' ')
                            .sublist(0, formattedDate!.split(' ').length - 1)
                            .join(' '),
                        style: TextStyle(
                          color:
                              themeProvider.isDarkMode
                                  ? AppColors.appBlackColor.withAlpha(150)
                                  : AppColors.appLighterGreyColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        formattedDate!.split(' ').last,
                        style: TextStyle(
                          color:
                              themeProvider.isDarkMode
                                  ? AppColors.appBlackColor
                                  : AppColors.appWhiteColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon:
                  !themeProvider.isDarkMode
                      ? Icon(
                        Icons.arrow_back,
                        color:
                            _isCollapsed
                                ? AppColors.appBlackColor
                                : AppColors.appWhiteColor,
                      )
                      : Icon(
                        Icons.arrow_back,
                        color:
                            _isCollapsed
                                ? AppColors.appWhiteColor
                                : AppColors.appBlackColor,
                      ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon:
                    !themeProvider.isDarkMode
                        ? Icon(
                          Icons.share,
                          color:
                              _isCollapsed
                                  ? AppColors.appBlackColor
                                  : AppColors.appWhiteColor,
                        )
                        : Icon(
                          Icons.share,
                          color:
                              _isCollapsed
                                  ? AppColors.appWhiteColor
                                  : AppColors.appBlackColor,
                        ),
                onPressed: () {
                  Share.share(
                    shareDevotion(
                      date: formattedDate ?? "",
                      topic: widget.dailyDevotional['topic'],
                      text: widget.dailyDevotional['text'],
                      memoryVerse: widget.dailyDevotional['memory verse'],
                      message: widget.dailyDevotional['message'],
                      wisdomShot: widget.dailyDevotional['wisdom shot'],
                      prayer: widget.dailyDevotional['prayer'],
                    ),
                  );
                },
              ),
              IconButton(
                icon:
                    !themeProvider.isDarkMode
                        ? Icon(
                          Icons.book,
                          color:
                              _isCollapsed
                                  ? AppColors.appBlackColor
                                  : AppColors.appWhiteColor,
                        )
                        : Icon(
                          Icons.book,
                          color:
                              _isCollapsed
                                  ? AppColors.appWhiteColor
                                  : AppColors.appBlackColor,
                        ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JournalListScreen(),
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                iconColor:
                    _isCollapsed && themeProvider.isDarkMode
                        ? AppColors.appWhiteColor
                        : !_isCollapsed && themeProvider.isDarkMode
                        ? AppColors.appBlackColor
                        : _isCollapsed && !themeProvider.isDarkMode
                        ? AppColors.appBlackColor
                        : AppColors.appWhiteColor,
                onSelected: (value) {
                  setState(() {
                    if (value == 'Increase') {
                      fontSize += 2;
                    } else if (value == 'Decrease') {
                      fontSize -= 2;
                    }
                  });
                },
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: 'Decrease',
                        child: Text('Decrease font'),
                      ),
                      PopupMenuItem(
                        value: 'Increase',
                        child: Text('Increase font'),
                      ),
                    ],
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DevotionalSection(
                    title: 'TOPIC',
                    content: widget.dailyDevotional['topic'],
                    fontSize: fontSize,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  DevotionalSection(
                    title: 'TEXT',
                    content: widget.dailyDevotional['text'],
                    fontSize: fontSize,
                    onTap: () {
                      // Open Bible reader with this reference
                    },
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  DevotionalSection(
                    title: 'MEMORY VERSE',
                    content: content ?? '',
                    reference: reference ?? '',
                    fontSize: fontSize,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  DevotionalSection(
                    title: 'MESSAGE',
                    content: widget.dailyDevotional['message'] ?? '',
                    fontSize: fontSize,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  DevotionalSection(
                    title: 'WISDOM SHOT',
                    content: widget.dailyDevotional['wisdom shot'] ?? '',
                    fontSize: fontSize,
                    isQuote: true,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                  DevotionalSection(
                    title: 'PRAYER',
                    content: widget.dailyDevotional['prayer'] ?? '',
                    fontSize: fontSize,
                    isPrayer: true,
                    isDarkMode: themeProvider.isDarkMode,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openJournalDialog,
        child: Icon(Icons.edit_note),
      ),
    );
  }
}
