import 'package:flutter/material.dart';
import 'package:youth_guide/utils/app_colors.dart';

class BottomNavBarTheme {
  BottomNavBarTheme._();

  static BottomNavigationBarThemeData bottomNavBarLightTheme =
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.appWhiteColor,
        selectedItemColor: AppColors.appBlackColor.withAlpha(200),
        unselectedItemColor: AppColors.appGreyColor,
      );

  static BottomNavigationBarThemeData bottomNavBarDarkTheme =
      BottomNavigationBarThemeData(
        backgroundColor: AppColors.appBlackColor,
        selectedItemColor: AppColors.appGoldColor,
        unselectedItemColor: AppColors.appGreyColor,
      );
}
