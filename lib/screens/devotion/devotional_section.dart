// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youth_guide/utils/app_colors.dart';

class DevotionalSection extends StatelessWidget {
  final String title;
  final String content;
  final String? reference;
  final double fontSize;
  final bool isQuote;
  final bool isPrayer;
  final VoidCallback? onTap;

  final bool isDarkMode;

  const DevotionalSection({
    super.key,
    required this.title,
    required this.content,
    this.reference,
    required this.fontSize,
    this.isQuote = false,
    this.isPrayer = false,
    this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    print(isDarkMode);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.lora(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold,
                color:
                    isDarkMode
                        ? AppColors.appGoldColor
                        : AppColors.appBlackColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: isQuote || isPrayer ? const EdgeInsets.all(16) : null,
              decoration:
                  isQuote || isPrayer
                      ? BoxDecoration(
                        color:
                            isQuote && isDarkMode
                                ? AppColors.appLightGreyColor.withOpacity(0.4)
                                : isQuote && !isDarkMode
                                ? AppColors.appLightGreyColor
                                : isPrayer && isDarkMode
                                ? AppColors.appGoldColor.withOpacity(0.1)
                                : AppColors.appGoldColor.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(8),
                      )
                      : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: GoogleFonts.merriweatherSans(
                      fontSize: fontSize,
                      height: 1.6,
                      color:
                          isDarkMode
                              ? AppColors.appGreyColor
                              : AppColors.appBlackColor.withOpacity(0.7),
                      fontStyle: isQuote ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  if (reference != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      reference!,
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        color: AppColors.appGreyColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
