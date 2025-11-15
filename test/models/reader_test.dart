import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/reader.dart';

void main() {
  group('Reader Model Tests', () {
    test('Reader calculates totalLines correctly', () {
      final reader = Reader(
        id: 'test-1',
        name: 'Test Reader',
        categoryId: 'A',
        punchInTime: DateTime.now(),
        startLine: 1,
        endLine: 100,
        startParagraph: 1,
        endParagraph: 10,
        startChapter: 1,
        endChapter: 5,
        bookId: 'bhagavatam',
        dayNumber: 1,
      );

      expect(reader.totalLines, 100);
    });

    test('Reader calculates totalLines correctly with offset', () {
      final reader = Reader(
        id: 'test-2',
        name: 'Test Reader 2',
        categoryId: 'B',
        punchInTime: DateTime.now(),
        startLine: 50,
        endLine: 120,
        startParagraph: 5,
        endParagraph: 12,
        startChapter: 2,
        endChapter: 4,
        bookId: 'bhagavatam',
        dayNumber: 1,
      );

      expect(reader.totalLines, 71);
    });

    test('Reader calculates totalParagraphs correctly', () {
      final reader = Reader(
        id: 'test-3',
        name: 'Test Reader 3',
        categoryId: 'C',
        punchInTime: DateTime.now(),
        startLine: 1,
        endLine: 50,
        startParagraph: 1,
        endParagraph: 5,
        startChapter: 1,
        endChapter: 2,
        bookId: 'bhagavatam',
        dayNumber: 1,
      );

      expect(reader.totalParagraphs, 5);
    });

    test('Reader serializes to JSON correctly', () {
      final now = DateTime(2025, 11, 2, 10, 30, 0);
      final reader = Reader(
        id: 'test-4',
        name: 'Test Reader 4',
        categoryId: 'D',
        punchInTime: now,
        startLine: 10,
        endLine: 40,
        startParagraph: 2,
        endParagraph: 5,
        startChapter: 1,
        endChapter: 1,
        bookId: 'bhagavatam',
        dayNumber: 2,
      );

      final json = reader.toJson();

      expect(json['id'], 'test-4');
      expect(json['name'], 'Test Reader 4');
      expect(json['categoryId'], 'D');
      expect(json['punchInTime'], now.toIso8601String());
      expect(json['startLine'], 10);
      expect(json['endLine'], 40);
      expect(json['startParagraph'], 2);
      expect(json['endParagraph'], 5);
      expect(json['bookId'], 'bhagavatam');
      expect(json['dayNumber'], 2);
    });

    test('Reader deserializes from JSON correctly', () {
      final json = {
        'id': 'test-5',
        'name': 'Test Reader 5',
        'categoryId': 'A',
        'punchInTime': '2025-11-02T10:30:00.000',
        'startLine': 1,
        'endLine': 100,
        'startParagraph': 1,
        'endParagraph': 10,
        'bookId': 'bhagavatam',
        'dayNumber': 1,
      };

      final reader = Reader.fromJson(json);

      expect(reader.id, 'test-5');
      expect(reader.name, 'Test Reader 5');
      expect(reader.categoryId, 'A');
      expect(reader.startLine, 1);
      expect(reader.endLine, 100);
      expect(reader.startParagraph, 1);
      expect(reader.endParagraph, 10);
      expect(reader.bookId, 'bhagavatam');
      expect(reader.dayNumber, 1);
      expect(reader.totalLines, 100);
      expect(reader.totalParagraphs, 10);
    });

    test('Reader handles missing optional fields in JSON', () {
      final json = {
        'id': 'test-6',
        'name': 'Test Reader 6',
        'categoryId': 'B',
        'punchInTime': '2025-11-02T10:30:00.000',
        'startLine': 1,
        'endLine': 70,
        'bookId': 'bhagavatam',
        // Missing startParagraph, endParagraph, dayNumber
      };

      final reader = Reader.fromJson(json);

      expect(reader.startParagraph, 0);
      expect(reader.endParagraph, 0);
      expect(reader.dayNumber, 1);
    });

    test('Reader toJson and fromJson are inverse operations', () {
      final original = Reader(
        id: 'test-7',
        name: 'Test Reader 7',
        categoryId: 'C',
        punchInTime: DateTime.now(),
        startLine: 25,
        endLine: 75,
        startParagraph: 3,
        endParagraph: 8,
        startChapter: 2,
        endChapter: 3,
        bookId: 'ramayanam',
        dayNumber: 3,
      );

      final json = original.toJson();
      final restored = Reader.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.categoryId, original.categoryId);
      expect(restored.startLine, original.startLine);
      expect(restored.endLine, original.endLine);
      expect(restored.startParagraph, original.startParagraph);
      expect(restored.endParagraph, original.endParagraph);
      expect(restored.startChapter, original.startChapter);
      expect(restored.endChapter, original.endChapter);
      expect(restored.bookId, original.bookId);
      expect(restored.dayNumber, original.dayNumber);
      expect(restored.totalLines, original.totalLines);
      expect(restored.totalParagraphs, original.totalParagraphs);
      expect(restored.totalChapters, original.totalChapters);
    });
  });
}
