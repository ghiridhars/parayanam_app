/// Storage keys used for SharedPreferences.
/// 
/// Centralized management of all storage keys to prevent typos and
/// make it easier to migrate to a database in the future.
class StorageKeys {
  // Prevent instantiation
  StorageKeys._();

  // === User Authentication ===
  static const String currentUserEmail = 'current_user_email';
  
  /// User profile data: 'users_{email}'
  static String userProfile(String email) => 'users_$email';

  // === Book Data ===
  /// Reader categories for a book: 'categories_{bookId}'
  static String categories(String bookId) => 'categories_$bookId';
  
  /// Readers for a book: 'readers_{bookId}'
  static String readers(String bookId) => 'readers_$bookId';
  
  /// Current line number for a book: 'current_line_{bookId}'
  static String currentLine(String bookId) => 'current_line_$bookId';
  
  /// Current paragraph number for a book: 'current_paragraph_{bookId}'
  static String currentParagraph(String bookId) => 'current_paragraph_$bookId';
  
  /// Current day for a book: 'current_day_{bookId}'
  static String currentDay(String bookId) => 'current_day_$bookId';
  
  /// Day configurations for a book: 'day_config_{bookId}'
  static String dayConfig(String bookId) => 'day_config_$bookId';

  // === Sessions ===
  /// All reading sessions (global)
  static const String sessions = 'sessions';
  
  /// Active session for a book and user: 'active_session_{bookId}_{userEmail}'
  static String activeSession(String bookId, String userEmail) => 
      'active_session_${bookId}_$userEmail';
  
  /// Session-specific categories: 'session_categories_{sessionId}'
  static String sessionCategories(String sessionId) => 
      'session_categories_$sessionId';
  
  /// Session-specific day config: 'session_day_config_{sessionId}'
  static String sessionDayConfig(String sessionId) => 
      'session_day_config_$sessionId';
  
  /// Day statuses for a session: 'day_statuses_{sessionId}'
  static String dayStatuses(String sessionId) => 
      'day_statuses_$sessionId';

  // === App Settings ===
  static const String appVersion = 'app_version';
  static const String lastSyncTime = 'last_sync_time';
  static const String isDarkMode = 'is_dark_mode';
  static const String isFirstLaunch = 'is_first_launch';
}
