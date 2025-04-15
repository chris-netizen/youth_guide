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
  required String link,
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

*Get the Methodist young mind devotional at:* $link
''';
}

class BibleVerseParser {
  static Map<String, String> parseVerse(String verse) {
    // Trim any extra whitespace
    verse = verse.trim();

    // Initialize variables for storing parts
    String reference = '';
    String content = '';

    // Regular expression to match Bible references
    final referenceRegex = RegExp(
      r'^(?:\d*\s*[A-Za-z]+(?:\s*[A-Za-z]+|\.)*)\s*\d+\s*:\s*\d+(?:[-,;]\d+)*',
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
          r'$1 ',
        ); // Ensure proper spacing around separators
  }
}

class TextToSpeech {
  static const String textToSpeech =
      """Dearly beloved in the Lord, count it all joy that we made it to this year amidst numerous environmental challenges of the end time. If the Lord had not been on our side, we would have been consumed. The several challenges of our nation in the last one year were such that only God can save His church and His people. We bless God for His mercies upon us all. \n\nThe Directorate of Evangelism is the body that is constitutionally empowered to promote the spiritual development of the Church. The production of Publications like Discipleship Guide, Sunday Tonic, Young Mind Reflection, etcetera, is part of the strategies for accomplishing the core mandates of the Directorate. I bless God that over the years, the Department have not failed in rolling out instructional materials for the edification of the body of Christ. \n\nThe best description of the world now is topsy-turvy and the Church is no better. It is almost that the devil is rejoicing that he has the world and the Church in his pocket but that is a lie from the pit of hell, because there would be order in the world again and the Church would rise again. \n\nThe theme of this year's Conference: "He will Rise Again" (John 11:23) speaks to the current situation of the Church and the society in many respects. Lazarus was sick and he eventually died. Although he was a friend to Jesus, he died all the same. It was a painful experience to all that are related to Lazarus by blood or by firendship. The circumstances of the death provoked emotions, so much so that Jesus wept (John 11:35). Figuratively, Jesus still cries for the situation of the world and the Church but all hope is not lost because 'he will rise again'. \n\nBeloved, the major connexional discussions of the Church will center on the theme in 2025. Let us prayerfully use all our publications that are developed alongside the theme, to the intent that we shall pray down the resurrection power of God to come on the Church, the world and individual circumstances of life. \n\nIn conclusion, I wish to use this avenue to express my gratitude to His Eminence Dr. Oliver Ali Aba, JP, Prelate, Methodist Church Nigeria, for his unquantifiable support and encouragement which has made the journey so far eventful. \n\nI sincerely appreciate our contributions, editorial team, resource persons and users of our publications for their supports and prayerful devotion to duty. I especially remark the contributions of the Directorate staff for their commitment and devotion to duty. May the Lord Almighty bountifully reward you all in Jesus name.""";
}
