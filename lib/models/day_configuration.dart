class DayConfiguration {
  final int dayNumber;
  int maxLines;
  int maxParagraphs;

  DayConfiguration({
    required this.dayNumber,
    required this.maxLines,
    this.maxParagraphs = 100, // Default max paragraphs per day
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'maxLines': maxLines,
      'maxParagraphs': maxParagraphs,
    };
  }

  factory DayConfiguration.fromJson(Map<String, dynamic> json) {
    return DayConfiguration(
      dayNumber: json['dayNumber'],
      maxLines: json['maxLines'],
      maxParagraphs: json['maxParagraphs'] ?? 100,
    );
  }

  static List<DayConfiguration> getDefaultConfigurations(int totalDays) {
    return List.generate(
      totalDays,
      (index) => DayConfiguration(
        dayNumber: index + 1,
        maxLines: 1000, // Default max lines per day
        maxParagraphs: 100, // Default max paragraphs per day
      ),
    );
  }
}
