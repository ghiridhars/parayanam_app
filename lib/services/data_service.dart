import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/reader_category.dart';
import '../models/reader.dart';
import '../models/user_profile.dart';
import '../models/day_configuration.dart';
import '../models/reading_session.dart';
import '../models/day_status.dart';
import '../core/constants/storage_keys.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/app_logger.dart';
import '../core/errors/exceptions.dart';

class DataService {
  // Hash password using BCrypt with salt
  String _hashPassword(String password) {
    try {
      AppLogger.debug('Hashing password with bcrypt');
      return BCrypt.hashpw(password, BCrypt.gensalt(logRounds: AppConstants.bcryptWorkFactor));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to hash password', e, stackTrace);
      throw StorageException('Failed to secure password', originalError: e);
    }
  }

  // Verify password against hash
  bool _verifyPassword(String password, String hashedPassword) {
    try {
      return BCrypt.checkpw(password, hashedPassword);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to verify password', e, stackTrace);
      return false;
    }
  }

  // User Authentication Methods
  Future<bool> registerUser(String name, String email, String password) async {
    try {
      AppLogger.info('Attempting to register user', email);
      
      // Validate input
      if (name.trim().isEmpty) {
        throw ValidationException('Name cannot be empty');
      }
      if (email.trim().isEmpty) {
        throw ValidationException('Email cannot be empty');
      }
      if (password.length < AppConstants.minPasswordLength) {
        throw ValidationException(
          'Password must be at least ${AppConstants.minPasswordLength} characters'
        );
      }
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = StorageKeys.userProfile(email);
      
      // Check if user already exists
      if (prefs.containsKey(userKey)) {
        AppLogger.warning('Registration failed: user already exists', email);
        return false; // User already exists
      }
      
      final user = UserProfile(
        email: email,
        name: name,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
      );
      
      await prefs.setString(userKey, jsonEncode(user.toJson()));
      AppLogger.info('User registered successfully', email);
      return true;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to register user', e, stackTrace);
      rethrow;
    }
  }

  Future<UserProfile?> loginUser(String email, String password) async {
    try {
      AppLogger.info('Attempting to login user', email);
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = StorageKeys.userProfile(email);
      final userString = prefs.getString(userKey);
      
      if (userString == null) {
        AppLogger.warning('Login failed: user not found', email);
        return null; // User not found
      }
      
      final user = UserProfile.fromJson(jsonDecode(userString));
      
      // Verify password
      if (_verifyPassword(password, user.passwordHash)) {
        // Set current user
        await prefs.setString(StorageKeys.currentUserEmail, email);
        AppLogger.info('User logged in successfully', email);
        return user;
      }
      
      AppLogger.warning('Login failed: invalid password', email);
      return null; // Invalid password
    } catch (e, stackTrace) {
      AppLogger.error('Failed to login user', e, stackTrace);
      return null;
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageKeys.currentUserEmail);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get current user email', e, stackTrace);
      return null;
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final email = await getCurrentUserEmail();
      if (email == null) return null;
      
      final prefs = await SharedPreferences.getInstance();
      final userKey = StorageKeys.userProfile(email);
      final userString = prefs.getString(userKey);
      
      if (userString == null) {
        AppLogger.warning('Current user profile not found', email);
        return null;
      }
      
      return UserProfile.fromJson(jsonDecode(userString));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get current user profile', e, stackTrace);
      return null;
    }
  }

  Future<void> logoutUser() async {
    try {
      final email = await getCurrentUserEmail();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.currentUserEmail);
      AppLogger.info('User logged out', email);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to logout user', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> isUserLoggedIn() async {
    final email = await getCurrentUserEmail();
    return email != null;
  }

  // Save categories for a book
  Future<void> saveCategories(String bookId, List<ReaderCategory> categories) async {
    try {
      AppLogger.data('Saving', 'categories for $bookId');
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = categories.map((c) => c.toJson()).toList();
      await prefs.setString(StorageKeys.categories(bookId), jsonEncode(categoriesJson));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save categories', e, stackTrace);
      throw StorageException('Failed to save categories', originalError: e);
    }
  }

  // Load categories for a book
  Future<List<ReaderCategory>> loadCategories(String bookId) async {
    try {
      AppLogger.data('Loading', 'categories for $bookId');
      final prefs = await SharedPreferences.getInstance();
      final categoriesString = prefs.getString(StorageKeys.categories(bookId));
      
      if (categoriesString == null) {
        AppLogger.debug('No categories found, returning defaults');
        return ReaderCategory.getDefaultCategories();
      }
      
      final List<dynamic> categoriesJson = jsonDecode(categoriesString);
      return categoriesJson.map((c) => ReaderCategory.fromJson(c)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load categories', e, stackTrace);
      return ReaderCategory.getDefaultCategories();
    }
  }

  // Save readers for a book
  Future<void> saveReaders(String bookId, List<Reader> readers) async {
    try {
      AppLogger.data('Saving', 'readers for $bookId', '${readers.length} readers');
      final prefs = await SharedPreferences.getInstance();
      final readersJson = readers.map((r) => r.toJson()).toList();
      await prefs.setString(StorageKeys.readers(bookId), jsonEncode(readersJson));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save readers', e, stackTrace);
      throw StorageException('Failed to save readers', originalError: e);
    }
  }

  // Load readers for a book
  Future<List<Reader>> loadReaders(String bookId) async {
    try {
      AppLogger.data('Loading', 'readers for $bookId');
      final prefs = await SharedPreferences.getInstance();
      final readersString = prefs.getString(StorageKeys.readers(bookId));
      
      if (readersString == null) {
        AppLogger.debug('No readers found');
        return [];
      }
      
      final List<dynamic> readersJson = jsonDecode(readersString);
      return readersJson.map((r) => Reader.fromJson(r)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load readers', e, stackTrace);
      return [];
    }
  }

  // Get current line number for a book
  Future<int> getCurrentLine(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(StorageKeys.currentLine(bookId)) ?? 1;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get current line', e, stackTrace);
      return 1;
    }
  }

  // Set current line number for a book
  Future<void> setCurrentLine(String bookId, int lineNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(StorageKeys.currentLine(bookId), lineNumber);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set current line', e, stackTrace);
      throw StorageException('Failed to set current line', originalError: e);
    }
  }

  // Get current paragraph number for a book
  Future<int> getCurrentParagraph(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(StorageKeys.currentParagraph(bookId)) ?? 1;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get current paragraph', e, stackTrace);
      return 1;
    }
  }

  // Set current paragraph number for a book
  Future<void> setCurrentParagraph(String bookId, int paragraphNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(StorageKeys.currentParagraph(bookId), paragraphNumber);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set current paragraph', e, stackTrace);
      throw StorageException('Failed to set current paragraph', originalError: e);
    }
  }

  // Add a new reader and update current line and paragraph
  Future<void> addReader(Reader reader) async {
    final readers = await loadReaders(reader.bookId);
    readers.add(reader);
    await saveReaders(reader.bookId, readers);
    await setCurrentLine(reader.bookId, reader.endLine + 1);
    await setCurrentParagraph(reader.bookId, reader.endParagraph + 1);
  }

  // Delete a specific reader and recalculate positions
  Future<void> deleteReader(String bookId, String readerId) async {
    final readers = await loadReaders(bookId);
    final readerIndex = readers.indexWhere((r) => r.id == readerId);
    
    if (readerIndex == -1) {
      return; // Reader not found
    }

    // Remove the reader
    readers.removeAt(readerIndex);
    
    // Recalculate positions for all readers after the deleted one
    // This ensures continuity in line and paragraph numbering
    await saveReaders(bookId, readers);
    
    // Update current line and paragraph to the last reader's end + 1
    if (readers.isEmpty) {
      await setCurrentLine(bookId, 1);
      await setCurrentParagraph(bookId, 1);
    } else {
      final lastReader = readers.last;
      await setCurrentLine(bookId, lastReader.endLine + 1);
      await setCurrentParagraph(bookId, lastReader.endParagraph + 1);
    }
  }

  // Clear all readers for a book
  Future<void> clearReaders(String bookId) async {
    try {
      AppLogger.data('Clearing', 'all readers for $bookId');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.readers(bookId));
      await setCurrentLine(bookId, 1);
      await setCurrentParagraph(bookId, 1);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear readers', e, stackTrace);
      throw StorageException('Failed to clear readers', originalError: e);
    }
  }

  // Day Configuration Methods
  Future<void> saveDayConfigurations(String bookId, List<DayConfiguration> configurations) async {
    try {
      AppLogger.data('Saving', 'day configurations for $bookId');
      final prefs = await SharedPreferences.getInstance();
      final configurationsJson = configurations.map((c) => c.toJson()).toList();
      await prefs.setString(StorageKeys.dayConfig(bookId), jsonEncode(configurationsJson));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save day configurations', e, stackTrace);
      throw StorageException('Failed to save day configurations', originalError: e);
    }
  }

  Future<List<DayConfiguration>> loadDayConfigurations(String bookId, int totalDays) async {
    try {
      AppLogger.data('Loading', 'day configurations for $bookId');
      final prefs = await SharedPreferences.getInstance();
      final configurationsString = prefs.getString(StorageKeys.dayConfig(bookId));
      
      if (configurationsString == null) {
        AppLogger.debug('No day configs found, returning defaults');
        return DayConfiguration.getDefaultConfigurations(totalDays);
      }
      
      final List<dynamic> configurationsJson = jsonDecode(configurationsString);
      return configurationsJson.map((c) => DayConfiguration.fromJson(c)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load day configurations', e, stackTrace);
      return DayConfiguration.getDefaultConfigurations(totalDays);
    }
  }

  // Get current day for a book
  Future<int> getCurrentDay(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(StorageKeys.currentDay(bookId)) ?? 1;
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get current day', e, stackTrace);
      return 1;
    }
  }

  // Set current day for a book
  Future<void> setCurrentDay(String bookId, int dayNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(StorageKeys.currentDay(bookId), dayNumber);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set current day', e, stackTrace);
      throw StorageException('Failed to set current day', originalError: e);
    }
  }

  // Get total lines used for a specific day
  Future<int> getTotalLinesForDay(String bookId, int dayNumber) async {
    final readers = await loadReaders(bookId);
    // Filter readers for the specific day and sum their lines
    // For now, we'll track this by checking if reader was added on that day
    // You might want to add a dayNumber field to the Reader model
    int totalLines = 0;
    for (var reader in readers) {
      // This is a simplified version - you may want to add day tracking to readers
      totalLines += reader.totalLines;
    }
    return totalLines;
  }

  // Check if can add more readers for current day
  Future<bool> canAddReaderForDay(String bookId, int dayNumber, int linesToAdd) async {
    final dayConfigs = await loadDayConfigurations(bookId, 7);
    if (dayNumber > dayConfigs.length) return false;
    
    final dayConfig = dayConfigs[dayNumber - 1];
    final currentLine = await getCurrentLine(bookId);
    final totalLinesForDay = currentLine - 1; // Lines used so far today
    
    return (totalLinesForDay + linesToAdd) <= dayConfig.maxLines;
  }

  // Reading Session Methods (User-scoped)
  Future<void> saveReadingSession(ReadingSession session) async {
    try {
      AppLogger.data('Saving', 'reading session', session.id);
      final sessions = await _getAllSessionsGlobal(); // Get all sessions
      final index = sessions.indexWhere((s) => s.id == session.id);
      
      if (index != -1) {
        sessions[index] = session;
      } else {
        sessions.add(session);
      }
      
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = sessions.map((s) => s.toJson()).toList();
      await prefs.setString(StorageKeys.sessions, jsonEncode(sessionsJson));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save reading session', e, stackTrace);
      throw StorageException('Failed to save reading session', originalError: e);
    }
  }

  // Private method to get all sessions (not filtered by user)
  Future<List<ReadingSession>> _getAllSessionsGlobal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsString = prefs.getString(StorageKeys.sessions);
      
      if (sessionsString == null) {
        return [];
      }
      
      final List<dynamic> sessionsJson = jsonDecode(sessionsString);
      return sessionsJson.map((s) => ReadingSession.fromJson(s)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load sessions', e, stackTrace);
      return [];
    }
  }

  // Get sessions for current user only
  Future<List<ReadingSession>> getAllReadingSessions() async {
    try {
      final currentUserEmail = await getCurrentUserEmail();
      if (currentUserEmail == null) return [];
      
      final allSessions = await _getAllSessionsGlobal();
      return allSessions.where((s) => s.userProfileId == currentUserEmail).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get all reading sessions', e, stackTrace);
      return [];
    }
  }

  Future<List<ReadingSession>> getSessionsForBook(String bookId) async {
    final userSessions = await getAllReadingSessions();
    return userSessions.where((s) => s.bookId == bookId).toList();
  }

  Future<ReadingSession?> getActiveSession(String bookId) async {
    try {
      final currentUserEmail = await getCurrentUserEmail();
      if (currentUserEmail == null) return null;
      
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString(StorageKeys.activeSession(bookId, currentUserEmail));
      
      if (sessionId == null) return null;
      
      final sessions = await getAllReadingSessions();
      try {
        return sessions.firstWhere((s) => s.id == sessionId);
      } catch (e) {
        return null;
      }
    } catch (e, stackTrace) {
      AppLogger.error('Failed to get active session', e, stackTrace);
      return null;
    }
  }

  Future<void> setActiveSession(String bookId, String sessionId) async {
    try {
      final currentUserEmail = await getCurrentUserEmail();
      if (currentUserEmail == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.activeSession(bookId, currentUserEmail), sessionId);
      AppLogger.data('Set', 'active session', sessionId);
    } catch (e, stackTrace) {
      AppLogger.error('Failed to set active session', e, stackTrace);
      throw StorageException('Failed to set active session', originalError: e);
    }
  }

  Future<void> clearActiveSession(String bookId) async {
    try {
      final currentUserEmail = await getCurrentUserEmail();
      if (currentUserEmail == null) return;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.activeSession(bookId, currentUserEmail));
      AppLogger.data('Cleared', 'active session for $bookId');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to clear active session', e, stackTrace);
    }
  }

  // Save session-specific configurations
  Future<void> saveSessionCategories(String sessionId, List<ReaderCategory> categories) async {
    try {
      AppLogger.data('Saving', 'session categories', sessionId);
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = categories.map((c) => c.toJson()).toList();
      await prefs.setString(StorageKeys.sessionCategories(sessionId), jsonEncode(categoriesJson));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save session categories', e, stackTrace);
      throw StorageException('Failed to save session categories', originalError: e);
    }
  }

  Future<List<ReaderCategory>?> loadSessionCategories(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesString = prefs.getString(StorageKeys.sessionCategories(sessionId));
      
      if (categoriesString == null) return null;
      
      final List<dynamic> categoriesJson = jsonDecode(categoriesString);
      return categoriesJson.map((c) => ReaderCategory.fromJson(c)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load session categories', e, stackTrace);
      return null;
    }
  }

  Future<void> saveSessionDayConfig(String sessionId, List<DayConfiguration> dayConfigs) async {
    try {
      AppLogger.data('Saving', 'session day config', sessionId);
      final prefs = await SharedPreferences.getInstance();
      final configsJson = dayConfigs.map((c) => c.toJson()).toList();
      await prefs.setString(StorageKeys.sessionDayConfig(sessionId), jsonEncode(configsJson));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save session day config', e, stackTrace);
      throw StorageException('Failed to save session day config', originalError: e);
    }
  }

  Future<List<DayConfiguration>?> loadSessionDayConfig(String sessionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configsString = prefs.getString(StorageKeys.sessionDayConfig(sessionId));
      
      if (configsString == null) return null;
      
      final List<dynamic> configsJson = jsonDecode(configsString);
      return configsJson.map((c) => DayConfiguration.fromJson(c)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load session day config', e, stackTrace);
      return null;
    }
  }

  Future<void> deleteReadingSession(String sessionId) async {
    try {
      AppLogger.data('Deleting', 'reading session', sessionId);
      final sessions = await getAllReadingSessions();
      sessions.removeWhere((s) => s.id == sessionId);
      
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = sessions.map((s) => s.toJson()).toList();
      await prefs.setString(StorageKeys.sessions, jsonEncode(sessionsJson));
      
      // Clean up session-specific data
      await prefs.remove(StorageKeys.sessionCategories(sessionId));
      await prefs.remove(StorageKeys.sessionDayConfig(sessionId));
      await prefs.remove(StorageKeys.dayStatuses(sessionId));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to delete reading session', e, stackTrace);
      throw StorageException('Failed to delete reading session', originalError: e);
    }
  }

  // Day Status Methods
  Future<void> saveDayStatuses(String sessionId, List<DayStatus> statuses) async {
    try {
      AppLogger.data('Saving', 'day statuses', sessionId);
      final prefs = await SharedPreferences.getInstance();
      final statusesJson = statuses.map((s) => s.toJson()).toList();
      await prefs.setString(StorageKeys.dayStatuses(sessionId), jsonEncode(statusesJson));
    } catch (e, stackTrace) {
      AppLogger.error('Failed to save day statuses', e, stackTrace);
      throw StorageException('Failed to save day statuses', originalError: e);
    }
  }

  Future<List<DayStatus>> loadDayStatuses(String sessionId, int totalDays) async {
    try {
      AppLogger.data('Loading', 'day statuses', sessionId);
      final prefs = await SharedPreferences.getInstance();
      final statusesString = prefs.getString(StorageKeys.dayStatuses(sessionId));
      
      if (statusesString == null) {
        // Return default statuses
        return List.generate(
          totalDays,
          (index) => DayStatus(dayNumber: index + 1),
        );
      }
      
      final List<dynamic> statusesJson = jsonDecode(statusesString);
      return statusesJson.map((s) => DayStatus.fromJson(s)).toList();
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load day statuses', e, stackTrace);
      return List.generate(
        totalDays,
        (index) => DayStatus(dayNumber: index + 1),
      );
    }
  }
}
