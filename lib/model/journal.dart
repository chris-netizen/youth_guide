class JournalEntry {
  final int? id;
  final String date;
  final String devotionalTopic;
  final String reflection;
  final String devotionalContent;

  JournalEntry({
    this.id,
    required this.date,
    required this.devotionalTopic,
    required this.reflection,
    required this.devotionalContent,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'devotionalTopic': devotionalTopic,
      'reflection': reflection,
      'devotionalContent': devotionalContent,
    };
  }

  factory JournalEntry.fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      id: map['id'],
      date: map['date'],
      devotionalTopic: map['devotionalTopic'],
      reflection: map['reflection'],
      devotionalContent: map['devotionalContent'],
    );
  }
}
