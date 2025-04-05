import 'package:flutter/material.dart';
import 'package:youth_guide/utils/app_colors.dart';

class AppButtonTheme {
  AppButtonTheme._();

  static ElevatedButtonThemeData elevatedButtonLightTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appBlackColor.withAlpha(200),
          foregroundColor: AppColors.appWhiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      );

  static ElevatedButtonThemeData elevatedButtonDarkTheme =
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.appGoldColor,
          foregroundColor: AppColors.appBlackColor.withAlpha(200),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
      );
}
