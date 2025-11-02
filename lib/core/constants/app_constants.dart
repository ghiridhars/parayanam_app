/// Application-wide constants.
/// 
/// Contains all magic numbers, default values, and configuration constants
/// used throughout the application.
class AppConstants {
  // Prevent instantiation
  AppConstants._();

  // === Day Configuration Defaults ===
  /// Default maximum lines that can be assigned per day
  static const int defaultMaxLinesPerDay = 1000;
  
  /// Default maximum paragraphs that can be assigned per day
  static const int defaultMaxParagraphsPerDay = 100;

  // === Reader Category Defaults ===
  /// Category A - High capacity readers
  static const int categoryALines = 100;
  static const int categoryAParagraphs = 10;
  
  /// Category B - Medium-high capacity readers
  static const int categoryBLines = 70;
  static const int categoryBParagraphs = 7;
  
  /// Category C - Medium capacity readers
  static const int categoryCLines = 50;
  static const int categoryCParagraphs = 5;
  
  /// Category D - Lower capacity readers
  static const int categoryDLines = 30;
  static const int categoryDParagraphs = 3;

  // === UI Opacity Values ===
  /// Light overlay opacity (~20%)
  static const int overlayOpacityLight = 51;
  
  /// Medium overlay opacity (~50%)
  static const int overlayOpacityMedium = 128;
  
  /// Heavy overlay opacity (~90%)
  static const int overlayOpacityHeavy = 230;
  
  /// Standard card overlay opacity
  static const int cardOverlayOpacity = 179; // ~70%

  // === Password Security ===
  /// Bcrypt work factor (rounds)
  static const int bcryptWorkFactor = 12;
  
  /// Minimum password length
  static const int minPasswordLength = 6;
  
  /// Maximum password length
  static const int maxPasswordLength = 128;

  // === Session Colors ===
  static const List<String> sessionColors = [
    '#FF6B6B', // Red
    '#4ECDC4', // Teal
    '#45B7D1', // Blue
    '#FFA07A', // Light Salmon
    '#98D8C8', // Mint
    '#F7DC6F', // Yellow
    '#BB8FCE', // Purple
    '#85C1E2', // Sky Blue
    '#F8B500', // Orange
    '#2ECC71', // Green
  ];

  // === Storage Limits ===
  /// Maximum number of sessions to display at once (for pagination)
  static const int maxSessionsPerPage = 50;
  
  /// Maximum number of readers to display at once
  static const int maxReadersPerPage = 100;

  // === Timeouts ===
  /// Network request timeout in seconds
  static const int networkTimeoutSeconds = 30;
  
  /// Data load timeout in seconds
  static const int dataLoadTimeoutSeconds = 10;

  // === UI Configuration ===
  /// Standard padding
  static const double standardPadding = 16.0;
  
  /// Card elevation
  static const double cardElevation = 2.0;
  
  /// Calendar marker max count
  static const int calendarMarkersMaxCount = 3;

  // === Validation ===
  /// Email regex pattern
  static const String emailPattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  
  /// Minimum reader name length
  static const int minReaderNameLength = 2;
  
  /// Maximum reader name length
  static const int maxReaderNameLength = 50;
  
  /// Minimum session name length
  static const int minSessionNameLength = 3;
  
  /// Maximum session name length
  static const int maxSessionNameLength = 100;
}
