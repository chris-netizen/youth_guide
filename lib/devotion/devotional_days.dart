import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:youth_guide/app_drawer.dart';
import 'package:youth_guide/service/api_service.dart';
import 'package:youth_guide/utils.dart';
import 'devotional_page.dart';

class DevotionalCalendarPage extends StatefulWidget {
  const DevotionalCalendarPage({super.key});

  @override
  State<DevotionalCalendarPage> createState() => _DevotionalCalendarPageState();
}

class _DevotionalCalendarPageState extends State<DevotionalCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  List<Map<String, dynamic>>? devotional;

  @override
  void initState() {
    super.initState();
    _fetchDevotionalData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchDevotionalData();
  }

  Future<void> _fetchDevotionalData() async {
    try {
      devotional = await FirestoreService().getCollection('devotional');
      log('${devotional?[0]['date']}');
    } catch (e) {
      log('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Select a Date',
          style: GoogleFonts.playfairDisplay(
            textStyle: const TextStyle(color: Colors.white),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.blue.shade500],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: FirestoreService().getCollection('devotional'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No devotionals available.'));
          } else {
            devotional = snapshot.data;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade100, Colors.blue.shade50],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime(2025, 1, 1),
                    lastDay: DateTime(2025, 12, 31),
                    focusedDay: _focusedDay,
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Colors.blue.shade300,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                      ),
                      weekendTextStyle: TextStyle(color: Colors.red),
                      defaultTextStyle: TextStyle(color: Colors.black),
                    ),
                    headerStyle: HeaderStyle(
                      titleTextStyle: GoogleFonts.playfairDisplay(
                        textStyle: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.blue,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.blue,
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: Colors.blue.shade800),
                      weekendStyle: TextStyle(color: Colors.red),
                    ),
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      final dayOfYear = getDayOfYear(
                        _selectedDay ?? DateTime.now(),
                      );
                      final dayOfToday = getDayOfYear(DateTime.now());

                      log('${devotional!.length}');
                      log('$dayOfYear');

                      if (devotional!.length < (dayOfYear)) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DevotionalPage(
                                  dailyDevotional: devotional![dayOfToday - 1],
                                ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DevotionalPage(
                                  dailyDevotional: devotional![dayOfYear - 1],
                                ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed:
                        _selectedDay == null
                            ? null
                            : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    final dayOfYear = getDayOfYear(
                                      _selectedDay ?? DateTime.now(),
                                    );
                                    return DevotionalPage(
                                      dailyDevotional:
                                          devotional![dayOfYear - 1],
                                    );
                                  },
                                ),
                              );
                            },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selectedDay != null
                              ? Colors.blue.shade700
                              : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
                    ),
                    child: Text(
                      'View Devotional',
                      style: GoogleFonts.roboto(
                        textStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
