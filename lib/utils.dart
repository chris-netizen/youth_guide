int getDayOfYear(DateTime date) {
  final startOfYear = DateTime(date.year, 1, 1);
  return date.difference(startOfYear).inDays + 1;
}

String getOrdinal(int day) {
  if (day >= 11 && day <= 13) {
    return '${day}th';
  }
  switch (day % 10) {
    case 1:
      return '${day}st';
    case 2:
      return '${day}nd';
    case 3:
      return '${day}rd';
    default:
      return '${day}th';
  }
}

String shareDevotion({
  required String date,
  required String topic,
  required String text,
  required String memoryVerse,
  required String message,
  required String wisdomShot,
  required String prayer,
}) {
  return '''
*METHODIST CHURCH NIGERIA*
*2025 YOUNG MIND REFLECTION*
*$date*

*TOPIC:* $topic

*TEXT:* $text

*MEMORY VERSE:* $memoryVerse

*MESSAGE:* $message

*WISDOM SHOT:* $wisdomShot

*PRAYER:* $prayer
''';
}

class BibleVerseParser {
  static Map<String, String> parseVerse(String verse) {
    // Trim any extra whitespace
    verse = verse.trim();

    // Initialize variables for storing parts
    String reference = '';
    String content = '';

    // Regular expression to match bible references
    final referenceRegex = RegExp(
      r'^(?:\d*\s*[A-Za-z]+\s*\d+:\d+(?:[-,;]\d+)*)',
      caseSensitive: true,
    );

    // Find the reference match
    final referenceMatch = referenceRegex.firstMatch(verse);

    if (referenceMatch != null) {
      reference = referenceMatch.group(0)!.trim();

      // Get the content by removing the reference and any leading separators
      content =
          verse
              .substring(referenceMatch.end)
              .trim()
              .replaceFirst(RegExp(r'^[;:\s]+'), '')
              .trim();
    } else {
      // If no match found, return empty reference and full text as content
      content = verse;
    }

    return {'reference': reference, 'content': content};
  }

  // Helper method to clean up the verse text
  static String cleanVerseText(String verse) {
    return verse
        .trim()
        .replaceAll(
          RegExp(r'\s+'),
          ' ',
        ) // Replace multiple spaces with single space
        .replaceAll(
          RegExp(r'\s*([;:])\s*'),
          r'\1 ',
        ); // Ensure proper spacing around separators
  }
}
