// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:youth_guide/utils/app_colors.dart';
import 'package:youth_guide/utils/app_theme/app_bar_theme.dart';
import 'package:youth_guide/utils/app_theme/bottom_nav_bar_theme.dart';
import 'package:youth_guide/utils/app_theme/button_theme.dart';
import 'package:youth_guide/utils/app_theme/datepicker_theme.dart';
import 'package:youth_guide/utils/app_theme/floating_action_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.appWhiteColor,
    datePickerTheme: DatepickerTheme.datePickerTheme,
    scaffoldBackgroundColor: AppColors.appWhiteColor,
    appBarTheme: AppBarStyleTheme.appBarLightTheme,
    floatingActionButtonTheme: FloatingActionTheme.lightFloatingActionTheme,
    bottomNavigationBarTheme: BottomNavBarTheme.bottomNavBarLightTheme,
    elevatedButtonTheme: AppButtonTheme.elevatedButtonLightTheme,
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppColors.appBlackColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.appBlackColor),
      trackColor: MaterialStateProperty.all(
        AppColors.appBlackColor.withAlpha(150),
      ),
    ),
    indicatorColor: AppColors.appBlackColor.withAlpha(200),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.deepBlueColor,
    datePickerTheme: DatepickerTheme.datePickerTheme,
    scaffoldBackgroundColor: AppColors.appBlackColor,
    appBarTheme: AppBarStyleTheme.appBarDarkTheme,
    floatingActionButtonTheme: FloatingActionTheme.darkFloatingActionTheme,
    bottomNavigationBarTheme: BottomNavBarTheme.bottomNavBarDarkTheme,
    elevatedButtonTheme: AppButtonTheme.elevatedButtonDarkTheme,
    drawerTheme: const DrawerThemeData(backgroundColor: AppColors.appGreyColor),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.appGoldColor),
      trackColor: MaterialStateProperty.all(
        AppColors.appGoldColor.withAlpha(200),
      ),
    ),
    indicatorColor: AppColors.appGoldColor,
  );
}
