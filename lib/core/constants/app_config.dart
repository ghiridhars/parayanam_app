/// Application configuration constants
class AppConfig {
  /// Enable/disable authentication and login screen
  ///
  /// When set to true:
  /// - Login screen is completely bypassed
  /// - App starts directly at BookSelectionScreen
  /// - Demo user is automatically created and logged in
  ///
  /// When set to false:
  /// - Normal authentication flow is enabled
  /// - Users must login/register to access the app
  ///
  /// Use cases:
  /// - Set to true for demos, testing, or development
  /// - Set to false for production with authentication required
  static const bool isDemoMode = true;

  /// Demo user profile used when demo mode is enabled
  static const String demoUserEmail = 'demo@example.com';
  static const String demoUserName = 'Demo User';
}
