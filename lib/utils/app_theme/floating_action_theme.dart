// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:youth_guide/utils/app_colors.dart';

class FloatingActionTheme {
  FloatingActionTheme._();

  static FloatingActionButtonThemeData lightFloatingActionTheme =
      FloatingActionButtonThemeData(
        backgroundColor: AppColors.appLightGreyColor,
        foregroundColor: AppColors.appBlackColor.withOpacity(0.8),
      );

  static FloatingActionButtonThemeData darkFloatingActionTheme =
      const FloatingActionButtonThemeData(
        backgroundColor: AppColors.appGoldColor,
        foregroundColor: AppColors.appGreyColor,
      );
}
