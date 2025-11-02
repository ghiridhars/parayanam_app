import '../core/constants/app_constants.dart';

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
    this.paragraphCount = AppConstants.categoryAParagraphs, // Default paragraph count
  });

  static List<ReaderCategory> getDefaultCategories() {
    return [
      ReaderCategory(
        id: 'A',
        name: 'Category A',
        description: 'Reader who reads more than 100 lines',
        lineCount: AppConstants.categoryALines,
        paragraphCount: AppConstants.categoryAParagraphs,
      ),
      ReaderCategory(
        id: 'B',
        name: 'Category B',
        description: 'Reader who reads 60 - 80 lines',
        lineCount: AppConstants.categoryBLines,
        paragraphCount: AppConstants.categoryBParagraphs,
      ),
      ReaderCategory(
        id: 'C',
        name: 'Category C',
        description: 'Reader who reads 40 - 60 lines',
        lineCount: AppConstants.categoryCLines,
        paragraphCount: AppConstants.categoryCParagraphs,
      ),
      ReaderCategory(
        id: 'D',
        name: 'Category D',
        description: 'Reader who reads less than 40 lines',
        lineCount: AppConstants.categoryDLines,
        paragraphCount: AppConstants.categoryDParagraphs,
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
      paragraphCount: json['paragraphCount'] ?? AppConstants.categoryAParagraphs,
    );
  }
}
