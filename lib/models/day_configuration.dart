import '../core/constants/app_constants.dart';

class DayConfiguration {
  final int dayNumber;
  int maxLines;
  int maxParagraphs;
  int maxChapters;

  DayConfiguration({
    required this.dayNumber,
    required this.maxLines,
    this.maxParagraphs = AppConstants.defaultMaxParagraphsPerDay,
    this.maxChapters = AppConstants.defaultMaxChaptersPerDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'dayNumber': dayNumber,
      'maxLines': maxLines,
      'maxParagraphs': maxParagraphs,
      'maxChapters': maxChapters,
    };
  }

  factory DayConfiguration.fromJson(Map<String, dynamic> json) {
    return DayConfiguration(
      dayNumber: json['dayNumber'],
      maxLines: json['maxLines'],
      maxParagraphs: json['maxParagraphs'] ?? AppConstants.defaultMaxParagraphsPerDay,
      maxChapters: json['maxChapters'] ?? AppConstants.defaultMaxChaptersPerDay,
    );
  }

  static List<DayConfiguration> getDefaultConfigurations(int totalDays) {
    return List.generate(
      totalDays,
      (index) => DayConfiguration(
        dayNumber: index + 1,
        maxLines: AppConstants.defaultMaxLinesPerDay,
        maxParagraphs: AppConstants.defaultMaxParagraphsPerDay,
        maxChapters: AppConstants.defaultMaxChaptersPerDay,
      ),
    );
  }
}
