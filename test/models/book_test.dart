import 'package:flutter_test/flutter_test.dart';
import 'package:reader_app/models/book.dart';

void main() {
  group('Book Model Tests', () {
    test('Book availableBooks contains correct books', () {
      expect(Book.availableBooks.length, 3);
      expect(Book.availableBooks[0].id, 'bhagavatam');
      expect(Book.availableBooks[1].id, 'ramayanam');
      expect(Book.availableBooks[2].id, 'sivapuranam');
    });

    test('Book Bhagavatam has correct properties', () {
      final bhagavatam = Book.availableBooks.firstWhere((b) => b.id == 'bhagavatam');

      expect(bhagavatam.name, 'bhagavatam');
      expect(bhagavatam.displayName, 'Bhagavatam');
      expect(bhagavatam.totalDays, 7);
      expect(bhagavatam.isActive, true);
      expect(bhagavatam.backgroundImage, 'web/bagawatham.jpg');
    });

    test('Book Ramayanam has correct properties', () {
      final ramayanam = Book.availableBooks.firstWhere((b) => b.id == 'ramayanam');

      expect(ramayanam.name, 'ramayanam');
      expect(ramayanam.displayName, 'Ramayanam');
      expect(ramayanam.totalDays, 9);
      expect(ramayanam.isActive, false);
      expect(ramayanam.backgroundImage, isNull);
    });

    test('Book Sivapuranam has correct properties', () {
      final sivapuranam = Book.availableBooks.firstWhere((b) => b.id == 'sivapuranam');

      expect(sivapuranam.name, 'sivapuranam');
      expect(sivapuranam.displayName, 'Sivapuranam');
      expect(sivapuranam.totalDays, 11);
      expect(sivapuranam.isActive, false);
      expect(sivapuranam.backgroundImage, isNull);
    });

    test('Book getActiveBooks returns only active books', () {
      final activeBooks = Book.getActiveBooks();

      expect(activeBooks.length, 1);
      expect(activeBooks[0].id, 'bhagavatam');
      expect(activeBooks[0].isActive, true);
    });

    test('Book getActiveBooks excludes inactive books', () {
      final activeBooks = Book.getActiveBooks();

      final ramayanamInActive = activeBooks.any((b) => b.id == 'ramayanam');
      final sivapuranamInActive = activeBooks.any((b) => b.id == 'sivapuranam');

      expect(ramayanamInActive, false);
      expect(sivapuranamInActive, false);
    });

    test('Book can be created with custom values', () {
      final customBook = Book(
        id: 'test-book',
        name: 'testbook',
        displayName: 'Test Book',
        totalDays: 5,
        isActive: true,
        backgroundImage: 'path/to/image.jpg',
      );

      expect(customBook.id, 'test-book');
      expect(customBook.name, 'testbook');
      expect(customBook.displayName, 'Test Book');
      expect(customBook.totalDays, 5);
      expect(customBook.isActive, true);
      expect(customBook.backgroundImage, 'path/to/image.jpg');
    });

    test('Book defaults isActive to true when not specified', () {
      final book = Book(
        id: 'default-test',
        name: 'default',
        displayName: 'Default Test',
        totalDays: 3,
      );

      expect(book.isActive, true);
      expect(book.backgroundImage, isNull);
    });

    test('Book backgroundImage is optional', () {
      final book = Book(
        id: 'no-image',
        name: 'noimage',
        displayName: 'No Image Book',
        totalDays: 4,
        isActive: false,
      );

      expect(book.backgroundImage, isNull);
    });
  });
}
