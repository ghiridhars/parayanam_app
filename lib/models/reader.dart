class Reader {
  final String id;
  final String name;
  final String categoryId;
  final DateTime punchInTime;
  final int startLine;
  final int endLine;
  final int startParagraph;
  final int endParagraph;
  final String bookId;
  final int dayNumber;

  Reader({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.punchInTime,
    required this.startLine,
    required this.endLine,
    required this.startParagraph,
    required this.endParagraph,
    required this.bookId,
    this.dayNumber = 1,
  });

  int get totalLines => endLine - startLine + 1;
  int get totalParagraphs => endParagraph - startParagraph + 1;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'punchInTime': punchInTime.toIso8601String(),
      'startLine': startLine,
      'endLine': endLine,
      'startParagraph': startParagraph,
      'endParagraph': endParagraph,
      'bookId': bookId,
      'dayNumber': dayNumber,
    };
  }

  factory Reader.fromJson(Map<String, dynamic> json) {
    return Reader(
      id: json['id'],
      name: json['name'],
      categoryId: json['categoryId'],
      punchInTime: DateTime.parse(json['punchInTime']),
      startLine: json['startLine'],
      endLine: json['endLine'],
      startParagraph: json['startParagraph'] ?? 0,
      endParagraph: json['endParagraph'] ?? 0,
      bookId: json['bookId'],
      dayNumber: json['dayNumber'] ?? 1,
    );
  }
}
