import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youth_guide/devotion/devotional_days.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade800, Colors.blue.shade500],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.menu_book, size: 40, color: Colors.blue),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Young Mind',
                    style: GoogleFonts.playfairDisplay(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.blue),
              title: Text(
                'Daily Devotional',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DevotionalCalendarPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.book, color: Colors.blue),
              title: Text(
                'Bible Study',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () {
                // Navigate to Bible Study page
                Navigator.pop(context);
                // Add navigation to Bible Study page when created
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.blue),
              title: Text(
                'Prayer Groups',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () {
                // Navigate to Prayer Groups page
                Navigator.pop(context);
                // Add navigation to Prayer Groups page when created
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.blue),
              title: Text(
                'Events',
                style: GoogleFonts.roboto(
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              onTap: () {
                // Navigate to Events page
                Navigator.pop(context);
                // Add navigation to Events page when created
              },
            ),
          ],
        ),
      ),
    );
  }
}
