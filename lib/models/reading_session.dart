import '../core/constants/app_constants.dart';

class ReadingSession {
  final String id;
  final String name;
  final String bookId;
  final DateTime startDate;
  final DateTime endDate;
  final String userProfileId;
  final List<String> readerIds; // IDs of readers in this session
  final String colorCode; // For calendar display

  ReadingSession({
    required this.id,
    required this.name,
    required this.bookId,
    required this.startDate,
    required this.endDate,
    required this.userProfileId,
    required this.readerIds,
    required this.colorCode,
  });

  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate.add(const Duration(days: 1)));
  }

  bool isUpcoming() {
    final now = DateTime.now();
    return now.isBefore(startDate);
  }

  bool isCompleted() {
    final now = DateTime.now();
    return now.isAfter(endDate.add(const Duration(days: 1)));
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bookId': bookId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'userProfileId': userProfileId,
      'readerIds': readerIds,
      'colorCode': colorCode,
    };
  }

  factory ReadingSession.fromJson(Map<String, dynamic> json) {
    return ReadingSession(
      id: json['id'],
      name: json['name'],
      bookId: json['bookId'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      userProfileId: json['userProfileId'],
      readerIds: List<String>.from(json['readerIds']),
      colorCode: json['colorCode'],
    );
  }

  /// Available colors for session visualization on calendar
  static List<String> get availableColors => AppConstants.sessionColors;
}
