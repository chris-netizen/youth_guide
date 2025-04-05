import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youth_guide/utils/app_colors.dart';

class AppBarStyleTheme {
  AppBarStyleTheme._();

  static AppBarTheme appBarLightTheme = AppBarTheme(
    backgroundColor: AppColors.appWhiteColor,
    iconTheme: IconThemeData(color: AppColors.appBlackColor),
    titleTextStyle: GoogleFonts.lora(
      color: AppColors.appBlackColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  static AppBarTheme appBarDarkTheme = AppBarTheme(
    backgroundColor: AppColors.appBlackColor,
    iconTheme: IconThemeData(color: AppColors.appWhiteColor),
    titleTextStyle: GoogleFonts.lora(
      color: AppColors.appGreyColor,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );
}
