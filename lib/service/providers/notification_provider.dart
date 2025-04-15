import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/notifications_service.dart';

class NotificationProvider extends ChangeNotifier {
  bool _isNotificationEnabled = true;

  bool get isNotificationEnabled => _isNotificationEnabled;

  /// Initialize Notification System
  Future<void> initialize() async {
    try {
      await NotificationService.init();
      await _loadNotificationPreference();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  /// Load notification preference from storage
  Future<void> _loadNotificationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isNotificationEnabled =
        prefs.getBool('daily_notification_enabled') ?? true;

    if (_isNotificationEnabled) {
      await _scheduleDailyNotification();
    } else {
      await NotificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  /// Set the notification preference and schedule or cancel accordingly
  Future<void> setNotificationEnabled(bool enabled) async {
    _isNotificationEnabled = enabled;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_notification_enabled', enabled);

    if (enabled) {
      await _scheduleDailyNotification();
    } else {
      await NotificationService.cancelAllNotifications();
    }

    notifyListeners();
  }

  /// Schedules a daily notification (customize time here)
  Future<void> _scheduleDailyNotification() async {
    try {
      // Customize default time here (e.g., 8:00 AM)
      const int defaultHour = 3;
      const int defaultMinute = 30;

      await NotificationService.scheduleDailyNotification(
        hour: defaultHour,
        minute: defaultMinute,
        title: 'Daily Devotion Reminder',
        body: 'Take a moment to reflect with today\'s devotion.',
      );
    } catch (e) {
      debugPrint('Failed to schedule daily notification: $e');
    }
  }
}
