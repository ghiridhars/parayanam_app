import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/day_status.dart';

void main() {
  group('DayStatus Model Tests', () {
    test('DayStatus defaults to not done with 0 readers', () {
      final status = DayStatus(dayNumber: 1);

      expect(status.dayNumber, 1);
      expect(status.isDone, false);
      expect(status.readersCount, 0);
    });

    test('DayStatus can be created with all parameters', () {
      final status = DayStatus(
        dayNumber: 2,
        isDone: true,
        readersCount: 15,
      );

      expect(status.dayNumber, 2);
      expect(status.isDone, true);
      expect(status.readersCount, 15);
    });

    test('DayStatus serializes to JSON correctly', () {
      final status = DayStatus(
        dayNumber: 3,
        isDone: true,
        readersCount: 20,
      );

      final json = status.toJson();

      expect(json['dayNumber'], 3);
      expect(json['isDone'], true);
      expect(json['readersCount'], 20);
    });

    test('DayStatus deserializes from JSON correctly', () {
      final json = {
        'dayNumber': 4,
        'isDone': false,
        'readersCount': 10,
      };

      final status = DayStatus.fromJson(json);

      expect(status.dayNumber, 4);
      expect(status.isDone, false);
      expect(status.readersCount, 10);
    });

    test('DayStatus uses default values for missing JSON fields', () {
      final json = {
        'dayNumber': 5,
      };

      final status = DayStatus.fromJson(json);

      expect(status.dayNumber, 5);
      expect(status.isDone, false);
      expect(status.readersCount, 0);
    });

    test('DayStatus copyWith creates new instance with updated values', () {
      final original = DayStatus(
        dayNumber: 6,
        isDone: false,
        readersCount: 5,
      );

      final updated = original.copyWith(isDone: true, readersCount: 10);

      expect(updated.dayNumber, 6);
      expect(updated.isDone, true);
      expect(updated.readersCount, 10);
      
      // Original unchanged
      expect(original.isDone, false);
      expect(original.readersCount, 5);
    });

    test('DayStatus copyWith preserves original values when not specified', () {
      final original = DayStatus(
        dayNumber: 7,
        isDone: true,
        readersCount: 25,
      );

      final updated = original.copyWith(isDone: false);

      expect(updated.dayNumber, 7);
      expect(updated.isDone, false);
      expect(updated.readersCount, 25); // Preserved
    });

    test('DayStatus toJson and fromJson are inverse operations', () {
      final original = DayStatus(
        dayNumber: 8,
        isDone: true,
        readersCount: 30,
      );

      final json = original.toJson();
      final restored = DayStatus.fromJson(json);

      expect(restored.dayNumber, original.dayNumber);
      expect(restored.isDone, original.isDone);
      expect(restored.readersCount, original.readersCount);
    });
  });
}
