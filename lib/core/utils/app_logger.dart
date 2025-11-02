import 'package:flutter/foundation.dart';

/// Centralized logging utility for the application.
/// 
/// Provides different log levels and formatted output for debugging.
/// In production, logs are disabled unless explicitly enabled.
class AppLogger {
  static const String _prefix = '[Parayanam]';
  
  /// Enable/disable logging (disabled in production by default)
  static bool isEnabled = kDebugMode;

  /// Log debug information
  static void debug(String message, [Object? data]) {
    if (!isEnabled) return;
    if (data != null) {
      debugPrint('$_prefix [DEBUG] $message: $data');
    } else {
      debugPrint('$_prefix [DEBUG] $message');
    }
  }

  /// Log informational messages
  static void info(String message, [Object? data]) {
    if (!isEnabled) return;
    if (data != null) {
      debugPrint('$_prefix [INFO] $message: $data');
    } else {
      debugPrint('$_prefix [INFO] $message');
    }
  }

  /// Log warning messages
  static void warning(String message, [Object? data]) {
    if (!isEnabled) return;
    if (data != null) {
      debugPrint('$_prefix [WARNING] $message: $data');
    } else {
      debugPrint('$_prefix [WARNING] $message');
    }
  }

  /// Log error messages with optional stack trace
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (!isEnabled) return;
    
    debugPrint('$_prefix [ERROR] $message');
    if (error != null) {
      debugPrint('$_prefix [ERROR] Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('$_prefix [ERROR] Stack trace:\n$stackTrace');
    }
  }

  /// Log data operations (load, save, delete)
  static void data(String operation, String entity, [Object? details]) {
    if (!isEnabled) return;
    if (details != null) {
      debugPrint('$_prefix [DATA] $operation $entity: $details');
    } else {
      debugPrint('$_prefix [DATA] $operation $entity');
    }
  }
}
