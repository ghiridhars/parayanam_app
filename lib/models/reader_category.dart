import '../core/constants/app_constants.dart';

class ReaderCategory {
  final String id;
  final String name;
  final String description;
  int lineCount;
  int paragraphCount;
  int chapterCount;

  ReaderCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.lineCount,
    this.paragraphCount = AppConstants.categoryAParagraphs, // Default paragraph count
    this.chapterCount = AppConstants.categoryAChapters, // Default chapter count
  });

  static List<ReaderCategory> getDefaultCategories() {
    return [
      ReaderCategory(
        id: 'A',
        name: 'Category A',
        description: 'Reader who reads more than 100 lines',
        lineCount: AppConstants.categoryALines,
        paragraphCount: AppConstants.categoryAParagraphs,
        chapterCount: AppConstants.categoryAChapters,
      ),
      ReaderCategory(
        id: 'B',
        name: 'Category B',
        description: 'Reader who reads 60 - 80 lines',
        lineCount: AppConstants.categoryBLines,
        paragraphCount: AppConstants.categoryBParagraphs,
        chapterCount: AppConstants.categoryBChapters,
      ),
      ReaderCategory(
        id: 'C',
        name: 'Category C',
        description: 'Reader who reads 40 - 60 lines',
        lineCount: AppConstants.categoryCLines,
        paragraphCount: AppConstants.categoryCParagraphs,
        chapterCount: AppConstants.categoryCChapters,
      ),
      ReaderCategory(
        id: 'D',
        name: 'Category D',
        description: 'Reader who reads less than 40 lines',
        lineCount: AppConstants.categoryDLines,
        paragraphCount: AppConstants.categoryDParagraphs,
        chapterCount: AppConstants.categoryDChapters,
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
      'chapterCount': chapterCount,
    };
  }

  factory ReaderCategory.fromJson(Map<String, dynamic> json) {
    return ReaderCategory(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      lineCount: json['lineCount'],
      paragraphCount: json['paragraphCount'] ?? AppConstants.categoryAParagraphs,
      chapterCount: json['chapterCount'] ?? AppConstants.categoryAChapters,
    );
  }
}
