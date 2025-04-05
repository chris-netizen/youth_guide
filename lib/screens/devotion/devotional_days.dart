import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:youth_guide/app_drawer.dart';
import 'package:youth_guide/service/api_service.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/utils.dart';
import 'package:youth_guide/utils/app_colors.dart';
import 'package:youth_guide/utils/app_theme/datepicker_theme.dart';
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
    final themeProvider = Provider.of<ThemeProvider>(context);

    final currentYear = DateTime.now().year;
    return Scaffold(
      drawer: AppDrawer(),
      appBar: AppBar(
        title: Text(
          'Select a Date',
          style: GoogleFonts.lora(
            textStyle: TextStyle(
              color:
                  themeProvider.isDarkMode
                      ? AppColors.appGreyColor
                      : AppColors.appBlackColor.withAlpha(200),
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color:
                themeProvider.isDarkMode
                    ? AppColors.appBlackColor.withAlpha(200)
                    : AppColors.appWhiteColor,
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
                color:
                    themeProvider.isDarkMode
                        ? AppColors.appBlackColor
                        : AppColors.appWhiteColor,
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TableCalendar(
                    firstDay: DateTime(currentYear, 1, 1),
                    lastDay: DateTime(currentYear, 12, 31),
                    focusedDay: _focusedDay,
                    calendarStyle:
                        themeProvider.isDarkMode
                            ? DatepickerTheme.calendarStyleDarkTheme
                            : DatepickerTheme.calendarStyleLightTheme,
                    headerStyle: HeaderStyle(
                      titleTextStyle: GoogleFonts.playfairDisplay(
                        textStyle: TextStyle(
                          color:
                              themeProvider.isDarkMode
                                  ? AppColors.appGreyColor
                                  : AppColors.appBlackColor.withAlpha(200),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      formatButtonVisible: false,
                      titleCentered: true,
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color:
                            themeProvider.isDarkMode
                                ? AppColors.appGreyColor
                                : AppColors.appBlackColor.withAlpha(200),
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color:
                            themeProvider.isDarkMode
                                ? AppColors.appGreyColor
                                : AppColors.appBlackColor.withAlpha(200),
                      ),
                    ),
                    daysOfWeekStyle: DaysOfWeekStyle(
                      weekdayStyle: TextStyle(color: AppColors.deepBlueColor),
                      weekendStyle: TextStyle(color: AppColors.appDarkRedColor),
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
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 24.0,
                      ),
                    ),
                    child: Text(
                      'View Devotional',
                      style: GoogleFonts.roboto(
                        textStyle: TextStyle(
                          color:
                              themeProvider.isDarkMode
                                  ? AppColors.appGreyColor
                                  : Colors.white,
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
