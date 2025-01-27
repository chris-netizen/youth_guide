// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:youth_guide/database/sqldb.dart';
import 'package:youth_guide/devotion/devotional_section.dart';
import 'package:youth_guide/journal/journal_screen.dart';
import 'package:youth_guide/model/journal.dart';
import 'package:youth_guide/utils.dart';

class DevotionalPage extends StatefulWidget {
  final Map<String, dynamic> dailyDevotional;
  const DevotionalPage({super.key, required this.dailyDevotional});

  @override
  State<DevotionalPage> createState() => _DevotionalPageState();
}

class _DevotionalPageState extends State<DevotionalPage> {
  bool isFavorite = false;
  double fontSize = 16.0;

  String? formattedDate;

  String? content;
  String? reference;

  final TextEditingController _journalController = TextEditingController();
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    final parsed = BibleVerseParser.parseVerse(
      widget.dailyDevotional['memory verse'],
    );

    setState(() {
      content = parsed['content'];
      reference = parsed['reference'];
    });
  }

  @override
  void dispose() {
    _journalController.dispose();
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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Daily Devotional',
                style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(color: Colors.white),
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                  ),
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
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 8),
                      Text(
                        formattedDate!.split(' ').last,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.share),
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
                icon: Icon(Icons.book),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JournalListScreen(),
                    ),
                  );
                },
              ),
              PopupMenuButton(
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        child: Text('Decrease font'),
                        onTap: () {
                          setState(() {
                            fontSize = fontSize - 2;
                          });
                        },
                      ),
                      PopupMenuItem(
                        child: Text('Increase font'),
                        onTap: () {
                          setState(() {
                            fontSize = fontSize + 2;
                          });
                        },
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
                  ),
                  DevotionalSection(
                    title: 'TEXT',
                    content: widget.dailyDevotional['text'],
                    fontSize: fontSize,
                    onTap: () {
                      // Open Bible reader with this reference
                    },
                  ),
                  DevotionalSection(
                    title: 'MEMORY VERSE',
                    content: content ?? '',
                    reference: reference ?? '',
                    fontSize: fontSize,
                  ),
                  DevotionalSection(
                    title: 'MESSAGE',
                    content: widget.dailyDevotional['message'] ?? '',
                    fontSize: fontSize,
                  ),
                  DevotionalSection(
                    title: 'WISDOM SHOT',
                    content: widget.dailyDevotional['wisdom shot'] ?? '',
                    fontSize: fontSize,
                    isQuote: true,
                  ),
                  DevotionalSection(
                    title: 'PRAYER',
                    content: widget.dailyDevotional['prayer'] ?? '',
                    fontSize: fontSize,
                    isPrayer: true,
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
