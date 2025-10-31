class ReaderCategory {
  final String id;
  final String name;
  final String description;
  int lineCount;
  int paragraphCount;

  ReaderCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.lineCount,
    this.paragraphCount = 10, // Default paragraph count
  });

  static List<ReaderCategory> getDefaultCategories() {
    return [
      ReaderCategory(
        id: 'A',
        name: 'Category A',
        description: 'Reader who reads more than 100 lines',
        lineCount: 100,
        paragraphCount: 10,
      ),
      ReaderCategory(
        id: 'B',
        name: 'Category B',
        description: 'Reader who reads 60 - 80 lines',
        lineCount: 70,
        paragraphCount: 7,
      ),
      ReaderCategory(
        id: 'C',
        name: 'Category C',
        description: 'Reader who reads 40 - 60 lines',
        lineCount: 50,
        paragraphCount: 5,
      ),
      ReaderCategory(
        id: 'D',
        name: 'Category D',
        description: 'Reader who reads less than 40 lines',
        lineCount: 30,
        paragraphCount: 3,
      ),
    ];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'lineCount': lineCount,
      'paragraphCount': paragraphCount,
    };
  }

  factory ReaderCategory.fromJson(Map<String, dynamic> json) {
    return ReaderCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      lineCount: json['lineCount'],
      paragraphCount: json['paragraphCount'] ?? 10,
    );
  }
}
