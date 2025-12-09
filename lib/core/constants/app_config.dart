/// Application configuration constants
class AppConfig {
  /// Enable demo mode to bypass authentication
  /// Set to true for client demonstrations
  /// Set to false for production use
  static const bool isDemoMode = true;
  
  /// Demo user profile used when demo mode is enabled
  static const String demoUserEmail = 'demo@example.com';
  static const String demoUserName = 'Demo User';
}
