class FavoriteDevotional {
  final int? id;
  final String date;
  final String devotionalContent;
  final DateTime dateAdded;

  FavoriteDevotional({
    this.id,
    required this.date,
    required this.devotionalContent,
    required this.dateAdded,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'devotional_content': devotionalContent,
      'date_added': dateAdded.toIso8601String(),
    };
  }

  factory FavoriteDevotional.fromMap(Map<String, dynamic> map) {
    return FavoriteDevotional(
      id: map['id'],
      date: map['date'],
      devotionalContent: map['devotional_content'],
      dateAdded: DateTime.parse(map['date_added']),
    );
  }
}
