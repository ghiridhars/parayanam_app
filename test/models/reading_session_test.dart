import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/reading_session.dart';
import 'package:reader_app/core/constants/app_constants.dart';

void main() {
  group('ReadingSession Model Tests', () {
    test('ReadingSession isActive returns true for current session', () {
      final now = DateTime.now();
      final session = ReadingSession(
        id: 'test-1',
        name: 'Test Session',
        bookId: 'bhagavatam',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 5)),
        userProfileId: 'test@example.com',
        readerIds: [],
        colorCode: AppConstants.sessionColors[0],
      );

      expect(session.isActive(), true);
    });

    test('ReadingSession isActive returns false for past session', () {
      final now = DateTime.now();
      final session = ReadingSession(
        id: 'test-2',
        name: 'Past Session',
        bookId: 'bhagavatam',
        startDate: now.subtract(const Duration(days: 10)),
        endDate: now.subtract(const Duration(days: 3)),
        userProfileId: 'test@example.com',
        readerIds: [],
        colorCode: AppConstants.sessionColors[1],
      );

      expect(session.isActive(), false);
    });

    test('ReadingSession isUpcoming returns true for future session', () {
      final now = DateTime.now();
      final session = ReadingSession(
        id: 'test-3',
        name: 'Future Session',
        bookId: 'bhagavatam',
        startDate: now.add(const Duration(days: 5)),
        endDate: now.add(const Duration(days: 12)),
        userProfileId: 'test@example.com',
        readerIds: [],
        colorCode: AppConstants.sessionColors[2],
      );

      expect(session.isUpcoming(), true);
      expect(session.isActive(), false);
      expect(session.isCompleted(), false);
    });

    test('ReadingSession isCompleted returns true for past session', () {
      final now = DateTime.now();
      final session = ReadingSession(
        id: 'test-4',
        name: 'Completed Session',
        bookId: 'bhagavatam',
        startDate: now.subtract(const Duration(days: 14)),
        endDate: now.subtract(const Duration(days: 8)),
        userProfileId: 'test@example.com',
        readerIds: [],
        colorCode: AppConstants.sessionColors[3],
      );

      expect(session.isCompleted(), true);
      expect(session.isActive(), false);
      expect(session.isUpcoming(), false);
    });

    test('ReadingSession serializes to JSON correctly', () {
      final startDate = DateTime(2025, 11, 1, 0, 0, 0);
      final endDate = DateTime(2025, 11, 7, 23, 59, 59);
      final session = ReadingSession(
        id: 'test-5',
        name: 'Test Session 5',
        bookId: 'bhagavatam',
        startDate: startDate,
        endDate: endDate,
        userProfileId: 'user@test.com',
        readerIds: ['reader1', 'reader2', 'reader3'],
        colorCode: '#FF6B6B',
      );

      final json = session.toJson();

      expect(json['id'], 'test-5');
      expect(json['name'], 'Test Session 5');
      expect(json['bookId'], 'bhagavatam');
      expect(json['startDate'], startDate.toIso8601String());
      expect(json['endDate'], endDate.toIso8601String());
      expect(json['userProfileId'], 'user@test.com');
      expect(json['readerIds'], ['reader1', 'reader2', 'reader3']);
      expect(json['colorCode'], '#FF6B6B');
    });

    test('ReadingSession deserializes from JSON correctly', () {
      final json = {
        'id': 'test-6',
        'name': 'Test Session 6',
        'bookId': 'ramayanam',
        'startDate': '2025-11-01T00:00:00.000',
        'endDate': '2025-11-09T23:59:59.999',
        'userProfileId': 'admin@test.com',
        'readerIds': ['r1', 'r2'],
        'colorCode': '#4ECDC4',
      };

      final session = ReadingSession.fromJson(json);

      expect(session.id, 'test-6');
      expect(session.name, 'Test Session 6');
      expect(session.bookId, 'ramayanam');
      expect(session.userProfileId, 'admin@test.com');
      expect(session.readerIds, ['r1', 'r2']);
      expect(session.colorCode, '#4ECDC4');
    });

    test('ReadingSession toJson and fromJson are inverse operations', () {
      final original = ReadingSession(
        id: 'test-7',
        name: 'Round Trip Test',
        bookId: 'sivapuranam',
        startDate: DateTime(2025, 12, 1),
        endDate: DateTime(2025, 12, 11),
        userProfileId: 'test@roundtrip.com',
        readerIds: ['a', 'b', 'c', 'd'],
        colorCode: '#45B7D1',
      );

      final json = original.toJson();
      final restored = ReadingSession.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.bookId, original.bookId);
      expect(restored.startDate, original.startDate);
      expect(restored.endDate, original.endDate);
      expect(restored.userProfileId, original.userProfileId);
      expect(restored.readerIds, original.readerIds);
      expect(restored.colorCode, original.colorCode);
    });

    test('ReadingSession availableColors returns correct list', () {
      final colors = ReadingSession.availableColors;

      expect(colors.length, 10);
      expect(colors, AppConstants.sessionColors);
      expect(colors[0], '#FF6B6B'); // Red
      expect(colors[9], '#2ECC71'); // Green
    });
  });
}
