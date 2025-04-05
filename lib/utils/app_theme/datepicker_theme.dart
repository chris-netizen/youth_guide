import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:youth_guide/utils/app_colors.dart';

class DatepickerTheme {
  DatepickerTheme._();

  static const DatePickerThemeData datePickerTheme = DatePickerThemeData(
    backgroundColor: Colors.white,
    headerBackgroundColor: AppColors.deepBlueColor,
  );

  static CalendarStyle calendarStyleLightTheme = CalendarStyle(
    todayDecoration: BoxDecoration(
      color: AppColors.appGreyColor,
      shape: BoxShape.circle,
    ),

    selectedDecoration: BoxDecoration(
      color: AppColors.appBlackColor.withAlpha(200),
      shape: BoxShape.circle,
    ),
    weekendTextStyle: TextStyle(color: AppColors.appDarkRedColor),
    defaultTextStyle: TextStyle(color: AppColors.appBlackColor.withAlpha(200)),
  );

  static CalendarStyle calendarStyleDarkTheme = CalendarStyle(
    todayDecoration: BoxDecoration(
      color: AppColors.appGreyColor,
      shape: BoxShape.circle,
    ),

    selectedDecoration: BoxDecoration(
      color: AppColors.appGoldColor,
      shape: BoxShape.circle,
    ),
    weekendTextStyle: TextStyle(color: AppColors.appDarkRedColor),
    defaultTextStyle: TextStyle(color: AppColors.appGoldColor),
  );
}
