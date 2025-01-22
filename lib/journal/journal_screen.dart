// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youth_guide/database/sqldb.dart';
import 'package:youth_guide/model/journal.dart';

class JournalListScreen extends StatelessWidget {
  const JournalListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Journal Entries', style: GoogleFonts.playfairDisplay()),
      ),
      body: FutureBuilder<List<JournalEntry>>(
        future: DatabaseHelper().getEntries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No journal entries yet'));
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
                              Navigator.pop(context);
                              _editEntry(context, entry);
                            },
                          ),
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(Icons.delete, color: Colors.red),
                              title: Text('Delete'),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              _deleteEntry(context, entry.id!);
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
                  // Refresh the list
                  // You might want to use a state management solution here
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteEntry(BuildContext context, int id) async {
    bool confirm = await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Delete Entry'),
            content: Text('Are you sure you want to delete this entry?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete'),
              ),
            ],
          ),
    );

    if (confirm) {
      await DatabaseHelper().deleteEntry(id);
      // Refresh the list
      // You might want to use a state management solution here
    }
  }
}
