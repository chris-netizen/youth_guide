// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:youth_guide/service/database/sqldb.dart';
import 'package:youth_guide/model/journal.dart';
import 'package:youth_guide/service/providers/font_provider.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/utils/app_colors.dart';

class JournalListScreen extends StatefulWidget {
  const JournalListScreen({super.key});

  @override
  State<JournalListScreen> createState() => _JournalListScreenState();
}

class _JournalListScreenState extends State<JournalListScreen> {
  late Future<List<JournalEntry>> _entriesFuture;

  @override
  void initState() {
    super.initState();
    _entriesFuture = DatabaseHelper().getEntries();
  }

  void _refreshEntries() {
    setState(() {
      _entriesFuture = DatabaseHelper().getEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      appBar: AppBar(title: const Text('My Journal Entries')),
      body: FutureBuilder<List<JournalEntry>>(
        future: _entriesFuture,
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
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No journal entries yet',
                style: GoogleFonts.lora(fontSize: fontSize),
              ),
            );
          }
          final entries = snapshot.data!;
          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    entry.devotionalTopic,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    entry.date,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () => _showEntryDetails(context, entry),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: const ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: AppColors.appDarkRedColor,
                              ),
                              title: const Text('Delete'),
                            ),
                          ),
                        ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editEntry(context, entry);
                      } else if (value == 'delete') {
                        _deleteEntry(context, entry.id!, themeProvider);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEntryDetails(BuildContext context, JournalEntry entry) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(entry.devotionalTopic),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Date: ${entry.date}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text('Reflection:'),
                  const SizedBox(height: 8),
                  Text(entry.reflection),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  void _editEntry(BuildContext context, JournalEntry entry) {
    final TextEditingController controller = TextEditingController(
      text: entry.reflection,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Reflection'),
            content: TextField(
              controller: controller,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await DatabaseHelper().updateEntry(
                    JournalEntry(
                      id: entry.id,
                      date: entry.date,
                      devotionalTopic: entry.devotionalTopic,
                      reflection: controller.text,
                      devotionalContent: entry.devotionalContent,
                    ),
                  );
                  Navigator.pop(context);
                  _refreshEntries();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteEntry(
    BuildContext context,
    int id,
    ThemeProvider themeProvider,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Entry'),
            content: const Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color:
                        themeProvider.isDarkMode
                            ? AppColors.appWhiteColor
                            : AppColors.appBlackColor,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.isDarkMode
                          ? AppColors.appWhiteColor
                          : AppColors.appDarkRedColor,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await DatabaseHelper().deleteEntry(id);
      _refreshEntries();
    }
  }
}
