import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DevotionalSection extends StatelessWidget {
  final String title;
  final String content;
  final String? reference;
  final double fontSize;
  final bool isQuote;
  final bool isPrayer;
  final VoidCallback? onTap;

  const DevotionalSection({
    super.key,
    required this.title,
    required this.content,
    this.reference,
    required this.fontSize,
    this.isQuote = false,
    this.isPrayer = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: fontSize + 2,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: isQuote || isPrayer ? EdgeInsets.all(16) : null,
              decoration:
                  isQuote || isPrayer
                      ? BoxDecoration(
                        color:
                            isQuote
                                ? Colors.blue.shade50
                                : Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      )
                      : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: fontSize,
                      height: 1.6,
                      fontStyle: isQuote ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                  if (reference != null) ...[
                    SizedBox(height: 8),
                    Text(
                      reference!,
                      style: TextStyle(
                        fontSize: fontSize - 2,
                        color: Colors.grey.shade600,
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
