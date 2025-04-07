import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youth_guide/service/database/sqldb.dart';
import 'package:youth_guide/screens/devotion/devotional_page.dart';
import 'package:youth_guide/model/favourite.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper databaseHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favorite Devotionals',
          style: GoogleFonts.playfairDisplay(),
        ),
      ),
      body: FutureBuilder<List<FavoriteDevotional>>(
        future: databaseHelper.getFavorites(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final favorites = snapshot.data!;
          if (favorites.isEmpty) {
            return Center(child: Text('No favorite devotionals yet'));
          }

          return ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final favorite = favorites[index];
              final devotionalContent = json.decode(favorite.devotionalContent);

              // Convert stored ISO date string back to DateTime if needed
              DateTime? devotionalDate;
              if (devotionalContent['date'] != null) {
                devotionalDate = DateTime.parse(devotionalContent['date']);
              }

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    devotionalContent['topic'],
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(favorite.date),
                  onTap: () {
                    // Convert the date back to Timestamp format if needed by your DevotionalPage
                    if (devotionalDate != null) {
                      devotionalContent['date'] = {
                        'seconds':
                            devotionalDate.millisecondsSinceEpoch ~/ 1000,
                        'nanoseconds':
                            (devotionalDate.millisecondsSinceEpoch % 1000) *
                            1000000,
                      };
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => DevotionalPage(
                              initialIndex: index,
                              dailyDevotionals: [devotionalContent],
                            ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
