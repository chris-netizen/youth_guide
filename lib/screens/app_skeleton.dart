import 'package:flutter/material.dart';
import 'package:youth_guide/screens/bible/bible_screen.dart';
import 'package:youth_guide/screens/devotion/devotional_days.dart';
import 'package:youth_guide/screens/journal/journal_screen.dart';
import 'package:youth_guide/screens/settings/settings.dart';

class AppSkeleton extends StatefulWidget {
  const AppSkeleton({super.key});

  @override
  State<AppSkeleton> createState() => _AppSkeletonState();
}

class _AppSkeletonState extends State<AppSkeleton> {
  final List<Widget> _pages = [
    DevotionalCalendarPage(),
    BibleScreen(),
    JournalListScreen(),
    SettingsPage(),
  ];

  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Bible',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
