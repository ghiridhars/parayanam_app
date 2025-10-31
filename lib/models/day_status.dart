class DayStatus {
  final int dayNumber;
  final bool isDone;
  final int readersCount;

  DayStatus({
    required this.dayNumber,
    this.isDone = false,
    this.readersCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'isDone': isDone,
      'readersCount': readersCount,
    };
  }

  factory DayStatus.fromJson(Map<String, dynamic> json) {
    return DayStatus(
      dayNumber: json['dayNumber'],
      isDone: json['isDone'] ?? false,
      readersCount: json['readersCount'] ?? 0,
    );
  }

  DayStatus copyWith({
    int? dayNumber,
    bool? isDone,
    int? readersCount,
  }) {
    return DayStatus(
      dayNumber: dayNumber ?? this.dayNumber,
      isDone: isDone ?? this.isDone,
      readersCount: readersCount ?? this.readersCount,
    );
  }
}
