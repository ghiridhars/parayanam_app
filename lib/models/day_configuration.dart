import '../core/constants/app_constants.dart';

class DayConfiguration {
  final int dayNumber;
  int maxLines;
  int maxParagraphs;

  DayConfiguration({
    required this.dayNumber,
    required this.maxLines,
    this.maxParagraphs = AppConstants.defaultMaxParagraphsPerDay,
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
      maxParagraphs: json['maxParagraphs'] ?? AppConstants.defaultMaxParagraphsPerDay,
    );
  }

  static List<DayConfiguration> getDefaultConfigurations(int totalDays) {
    return List.generate(
      totalDays,
      (index) => DayConfiguration(
        dayNumber: index + 1,
        maxLines: AppConstants.defaultMaxLinesPerDay,
        maxParagraphs: AppConstants.defaultMaxParagraphsPerDay,
      ),
    );
  }
}
