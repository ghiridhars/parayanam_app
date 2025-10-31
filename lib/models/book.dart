class Book {
  final String id;
  final String name;
  final String displayName;
  final int totalDays;
  final bool isActive;
  final String? backgroundImage;

  const Book({
    required this.id,
    required this.name,
    required this.displayName,
    required this.totalDays,
    this.isActive = true,
    this.backgroundImage,
  });

  static const List<Book> availableBooks = [
    Book(
      id: 'bhagavatam',
      name: 'bhagavatam',
      displayName: 'Bhagavatam',
      totalDays: 7,
      isActive: true,
      backgroundImage: 'web/bagawatham.jpg',
    ),
    Book(
      id: 'ramayanam',
      name: 'ramayanam',
      displayName: 'Ramayanam',
      totalDays: 9,
      isActive: false,
    ),
    Book(
      id: 'sivapuranam',
      name: 'sivapuranam',
      displayName: 'Sivapuranam',
      totalDays: 11,
      isActive: false,
    ),
  ];

  static List<Book> getActiveBooks() {
    return availableBooks.where((book) => book.isActive).toList();
  }
}
