import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:youth_guide/service/api_service.dart';
import 'package:youth_guide/service/database/ad_helper.dart';
import 'package:youth_guide/service/database/versions.dart';
import 'package:youth_guide/service/providers/notification_provider.dart';
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

  BannerAd? _bannerAd;

  List<Map<String, dynamic>>? devotional;

  @override
  void initState() {
    super.initState();
    _logCurrentTimes();
    _loadAppBible();
    _bannerAd = BannerAd(
      adUnitId: AdHelper.getAdUnitId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (ad) => log('Banner ad loaded: ${ad.adUnitId}'),
        onAdFailedToLoad: (ad, error) {
          log('Banner ad failed to load: ${ad.adUnitId}, error: $error');
          ad.dispose();
        },
      ),
    )..load();
    _fetchDevotionalData();
  }

  void _logCurrentTimes() async {
    final rawNow = DateTime.now();
    tz.initializeTimeZones();
    final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));
    final tzNow = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      rawNow.year,
      rawNow.month,
      rawNow.day,
      rawNow.hour,
      6,
    );
    debugPrint('→ DateTime.now():     $rawNow');
    debugPrint('→ tz.TZDateTime.now:  $tzNow');
    debugPrint('→ scheduled:         $scheduled');
  }

  Future<void> _loadAppBible() async {
    await Versions.instance.loadBibleVersions();
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

    final notificationProvider = Provider.of<NotificationProvider>(context);

    log('${notificationProvider.isNotificationEnabled}');

    final currentYear = DateTime.now().year;
    return Scaffold(
      appBar: AppBar(
        title: Text('Select a Date'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color:
                themeProvider.isDarkMode
                    ? AppColors.appBlackColor.withAlpha(200)
                    : AppColors.appWhiteColor,
          ),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: FirestoreService().getCollection('devotional'),
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
                          titleTextStyle: GoogleFonts.lora(
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
                          weekdayStyle: TextStyle(
                            color:
                                themeProvider.isDarkMode
                                    ? AppColors.appGoldColor
                                    : AppColors.deepBlueColor,
                          ),
                          weekendStyle: TextStyle(
                            color:
                                themeProvider.isDarkMode
                                    ? AppColors.appGreyColor
                                    : AppColors.appDarkRedColor,
                          ),
                        ),
                        selectedDayPredicate:
                            (day) => isSameDay(_selectedDay, day),
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
                                      initialIndex: dayOfToday - 1,
                                      dailyDevotionals: devotional!,
                                    ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => DevotionalPage(
                                      initialIndex: dayOfYear - 1,
                                      dailyDevotionals: devotional!,
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
                                          initialIndex: dayOfYear - 1,
                                          dailyDevotionals: devotional!,
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
          if (_bannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: _bannerAd!.size.height.toDouble(),
                width: _bannerAd!.size.width.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
            ),
        ],
      ),
    );
  }
}
