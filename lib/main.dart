import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:youth_guide/screens/devotion/devotional_days.dart';
import 'package:youth_guide/screens/splash_screen/splash.dart';
import 'package:youth_guide/service/providers/bible_provider.dart';
import 'package:youth_guide/service/providers/font_provider.dart';
import 'package:youth_guide/service/providers/notification_provider.dart';
import 'package:youth_guide/service/providers/theme_provider.dart';
import 'package:youth_guide/service/providers/tts_provider.dart';
import 'package:youth_guide/utils/app_theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize dependencies
    await MobileAds.instance.initialize();
    await Firebase.initializeApp();

    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => TtsProvider()),
          ChangeNotifierProvider(create: (_) => FontSizeProvider()),
          ChangeNotifierProvider(create: (_) => LocalBibleProvider()),
          ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e, stackTrace) {
    // Log error (replace with your logging solution, e.g., Firebase Crashlytics)
    debugPrint('Initialization error: $e\n$stackTrace');
    // Optionally show an error screen or fallback UI
    runApp(const ErrorApp());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Navigator key for handling notification taps
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    // Initialize notifications after the app is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notificationProvider = Provider.of<NotificationProvider>(
        context,
        listen: false,
      );
      // Initialize the notification provider
      notificationProvider.initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Youth Guide',
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          navigatorKey: navigatorKey,
          home: const SplashScreen(),
          routes: {
            '/devotional_calendar': (context) => const DevotionalCalendarPage(),
          },
        );
      },
    );
  }
}

// Fallback UI for initialization errors
class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youth Guide - Error',
      home: Scaffold(
        body: Center(
          child: Text(
            'Failed to initialize the app. Please try again later.',
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
