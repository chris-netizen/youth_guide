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
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final fontSize = Provider.of<FontSizeProvider>(context).fontSize;

    return Scaffold(
      appBar: AppBar(title: Text('My Journal Entries')),
      body: FutureBuilder<List<JournalEntry>>(
        future: DatabaseHelper().getEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'No journal entries yet',
                style: GoogleFonts.lora(fontSize: fontSize),
              ),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final entry = snapshot.data![index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    entry.devotionalTopic,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    entry.date,
                    style: TextStyle(color: Colors.grey),
                  ),
                  onTap: () => _showEntryDetails(context, entry),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.edit),
                              title: Text('Edit'),
                            ),
                            onTap: () {
                              _editEntry(context, entry);
                            },
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(
                                Icons.delete,
                                color: AppColors.appDarkRedColor,
                              ),
                              title: Text('Delete'),
                            ),
                            onTap: () {
                              _deleteEntry(context, entry.id!, themeProvider);
                            },
                          ),
                        ],
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
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Text('Reflection:'),
                  SizedBox(height: 8),
                  Text(entry.reflection),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
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
            title: Text('Edit Reflection'),
            content: TextField(
              controller: controller,
              maxLines: 5,
              decoration: InputDecoration(border: OutlineInputBorder()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
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
                },
                child: Text('Save'),
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
    bool confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Entry'),
            content: Text('Are you sure you want to delete this entry?'),
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
                onPressed: () {
                  Navigator.pop(context, true);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      themeProvider.isDarkMode
                          ? AppColors.appWhiteColor
                          : AppColors.appDarkRedColor,
                ),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm) {
      await DatabaseHelper().deleteEntry(id);
    }
  }
}
