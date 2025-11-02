import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/day_configuration.dart';
import 'package:reader_app/core/constants/app_constants.dart';

void main() {
  group('DayConfiguration Model Tests', () {
    test('DayConfiguration uses default maxParagraphs from AppConstants', () {
      final config = DayConfiguration(
        dayNumber: 1,
        maxLines: 1000,
      );

      expect(config.maxParagraphs, AppConstants.defaultMaxParagraphsPerDay);
      expect(config.maxParagraphs, 100);
    });

    test('DayConfiguration can override maxParagraphs', () {
      final config = DayConfiguration(
        dayNumber: 2,
        maxLines: 800,
        maxParagraphs: 80,
      );

      expect(config.maxParagraphs, 80);
    });

    test('DayConfiguration getDefaultConfigurations creates correct number of days', () {
      final configs = DayConfiguration.getDefaultConfigurations(7);

      expect(configs.length, 7);
      expect(configs[0].dayNumber, 1);
      expect(configs[6].dayNumber, 7);
    });

    test('DayConfiguration default configurations use AppConstants', () {
      final configs = DayConfiguration.getDefaultConfigurations(5);

      for (var config in configs) {
        expect(config.maxLines, AppConstants.defaultMaxLinesPerDay);
        expect(config.maxParagraphs, AppConstants.defaultMaxParagraphsPerDay);
        expect(config.maxLines, 1000);
        expect(config.maxParagraphs, 100);
      }
    });

    test('DayConfiguration serializes to JSON correctly', () {
      final config = DayConfiguration(
        dayNumber: 3,
        maxLines: 1200,
        maxParagraphs: 120,
      );

      final json = config.toJson();

      expect(json['dayNumber'], 3);
      expect(json['maxLines'], 1200);
      expect(json['maxParagraphs'], 120);
    });

    test('DayConfiguration deserializes from JSON correctly', () {
      final json = {
        'dayNumber': 4,
        'maxLines': 950,
        'maxParagraphs': 95,
      };

      final config = DayConfiguration.fromJson(json);

      expect(config.dayNumber, 4);
      expect(config.maxLines, 950);
      expect(config.maxParagraphs, 95);
    });

    test('DayConfiguration uses default maxParagraphs if missing in JSON', () {
      final json = {
        'dayNumber': 5,
        'maxLines': 1100,
      };

      final config = DayConfiguration.fromJson(json);

      expect(config.maxParagraphs, AppConstants.defaultMaxParagraphsPerDay);
    });

    test('DayConfiguration toJson and fromJson are inverse operations', () {
      final original = DayConfiguration(
        dayNumber: 6,
        maxLines: 1050,
        maxParagraphs: 105,
      );

      final json = original.toJson();
      final restored = DayConfiguration.fromJson(json);

      expect(restored.dayNumber, original.dayNumber);
      expect(restored.maxLines, original.maxLines);
      expect(restored.maxParagraphs, original.maxParagraphs);
    });

    test('DayConfiguration maxLines and maxParagraphs are mutable', () {
      final config = DayConfiguration(
        dayNumber: 7,
        maxLines: 1000,
        maxParagraphs: 100,
      );

      expect(config.maxLines, 1000);
      expect(config.maxParagraphs, 100);

      config.maxLines = 1500;
      config.maxParagraphs = 150;

      expect(config.maxLines, 1500);
      expect(config.maxParagraphs, 150);
    });
  });
}
