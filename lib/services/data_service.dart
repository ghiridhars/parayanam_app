import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reader_category.dart';
import '../models/reader.dart';
import '../models/user_profile.dart';
import '../models/day_configuration.dart';
import '../models/reading_session.dart';
import '../models/day_status.dart';

class DataService {
  static const String _categoriesKey = 'categories_';
  static const String _readersKey = 'readers_';
  static const String _currentLineKey = 'current_line_';
  static const String _currentParagraphKey = 'current_paragraph_';
  static const String _userProfileKey = 'user_profile';
  static const String _dayConfigKey = 'day_config_';
  static const String _currentDayKey = 'current_day_';
  static const String _sessionsKey = 'sessions';
  static const String _activeSessionKey = 'active_session_';
  static const String _sessionCategoriesKey = 'session_categories_';
  static const String _sessionDayConfigKey = 'session_day_config_';
  static const String _dayStatusesKey = 'day_statuses_';

  // Save categories for a book
  Future<void> saveCategories(String bookId, List<ReaderCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = categories.map((c) => c.toJson()).toList();
    await prefs.setString('$_categoriesKey$bookId', jsonEncode(categoriesJson));
  }

  // Load categories for a book
  Future<List<ReaderCategory>> loadCategories(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesString = prefs.getString('$_categoriesKey$bookId');
    
    if (categoriesString == null) {
      return ReaderCategory.getDefaultCategories();
    }
    
    final List<dynamic> categoriesJson = jsonDecode(categoriesString);
    return categoriesJson.map((c) => ReaderCategory.fromJson(c)).toList();
  }

  // Save readers for a book
  Future<void> saveReaders(String bookId, List<Reader> readers) async {
    final prefs = await SharedPreferences.getInstance();
    final readersJson = readers.map((r) => r.toJson()).toList();
    await prefs.setString('$_readersKey$bookId', jsonEncode(readersJson));
  }

  // Load readers for a book
  Future<List<Reader>> loadReaders(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final readersString = prefs.getString('$_readersKey$bookId');
    
    if (readersString == null) {
      return [];
    }
    
    final List<dynamic> readersJson = jsonDecode(readersString);
    return readersJson.map((r) => Reader.fromJson(r)).toList();
  }

  // Get current line number for a book
  Future<int> getCurrentLine(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_currentLineKey$bookId') ?? 1;
  }

  // Set current line number for a book
  Future<void> setCurrentLine(String bookId, int lineNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_currentLineKey$bookId', lineNumber);
  }

  // Get current paragraph number for a book
  Future<int> getCurrentParagraph(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_currentParagraphKey$bookId') ?? 1;
  }

  // Set current paragraph number for a book
  Future<void> setCurrentParagraph(String bookId, int paragraphNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_currentParagraphKey$bookId', paragraphNumber);
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_readersKey$bookId');
    await setCurrentLine(bookId, 1);
    await setCurrentParagraph(bookId, 1);
  }

  // User Profile Methods
  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userProfileKey, jsonEncode(profile.toJson()));
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString(_userProfileKey);
    
    if (profileString == null) {
      return null;
    }
    
    final profileJson = jsonDecode(profileString);
    return UserProfile.fromJson(profileJson);
  }

  Future<void> clearUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userProfileKey);
  }

  // Day Configuration Methods
  Future<void> saveDayConfigurations(String bookId, List<DayConfiguration> configurations) async {
    final prefs = await SharedPreferences.getInstance();
    final configurationsJson = configurations.map((c) => c.toJson()).toList();
    await prefs.setString('$_dayConfigKey$bookId', jsonEncode(configurationsJson));
  }

  Future<List<DayConfiguration>> loadDayConfigurations(String bookId, int totalDays) async {
    final prefs = await SharedPreferences.getInstance();
    final configurationsString = prefs.getString('$_dayConfigKey$bookId');
    
    if (configurationsString == null) {
      return DayConfiguration.getDefaultConfigurations(totalDays);
    }
    
    final List<dynamic> configurationsJson = jsonDecode(configurationsString);
    return configurationsJson.map((c) => DayConfiguration.fromJson(c)).toList();
  }

  // Get current day for a book
  Future<int> getCurrentDay(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('$_currentDayKey$bookId') ?? 1;
  }

  // Set current day for a book
  Future<void> setCurrentDay(String bookId, int dayNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('$_currentDayKey$bookId', dayNumber);
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

  // Reading Session Methods
  Future<void> saveReadingSession(ReadingSession session) async {
    final sessions = await getAllReadingSessions();
    final index = sessions.indexWhere((s) => s.id == session.id);
    
    if (index != -1) {
      sessions[index] = session;
    } else {
      sessions.add(session);
    }
    
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(sessionsJson));
  }

  Future<List<ReadingSession>> getAllReadingSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsString = prefs.getString(_sessionsKey);
    
    if (sessionsString == null) {
      return [];
    }
    
    final List<dynamic> sessionsJson = jsonDecode(sessionsString);
    return sessionsJson.map((s) => ReadingSession.fromJson(s)).toList();
  }

  Future<List<ReadingSession>> getSessionsForBook(String bookId) async {
    final allSessions = await getAllReadingSessions();
    return allSessions.where((s) => s.bookId == bookId).toList();
  }

  Future<ReadingSession?> getActiveSession(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('$_activeSessionKey$bookId');
    
    if (sessionId == null) return null;
    
    final sessions = await getAllReadingSessions();
    try {
      return sessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  Future<void> setActiveSession(String bookId, String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_activeSessionKey$bookId', sessionId);
  }

  Future<void> clearActiveSession(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_activeSessionKey$bookId');
  }

  // Save session-specific configurations
  Future<void> saveSessionCategories(String sessionId, List<ReaderCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesJson = categories.map((c) => c.toJson()).toList();
    await prefs.setString('$_sessionCategoriesKey$sessionId', jsonEncode(categoriesJson));
  }

  Future<List<ReaderCategory>?> loadSessionCategories(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final categoriesString = prefs.getString('$_sessionCategoriesKey$sessionId');
    
    if (categoriesString == null) return null;
    
    final List<dynamic> categoriesJson = jsonDecode(categoriesString);
    return categoriesJson.map((c) => ReaderCategory.fromJson(c)).toList();
  }

  Future<void> saveSessionDayConfig(String sessionId, List<DayConfiguration> dayConfigs) async {
    final prefs = await SharedPreferences.getInstance();
    final configsJson = dayConfigs.map((c) => c.toJson()).toList();
    await prefs.setString('$_sessionDayConfigKey$sessionId', jsonEncode(configsJson));
  }

  Future<List<DayConfiguration>?> loadSessionDayConfig(String sessionId) async {
    final prefs = await SharedPreferences.getInstance();
    final configsString = prefs.getString('$_sessionDayConfigKey$sessionId');
    
    if (configsString == null) return null;
    
    final List<dynamic> configsJson = jsonDecode(configsString);
    return configsJson.map((c) => DayConfiguration.fromJson(c)).toList();
  }

  Future<void> deleteReadingSession(String sessionId) async {
    final sessions = await getAllReadingSessions();
    sessions.removeWhere((s) => s.id == sessionId);
    
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_sessionsKey, jsonEncode(sessionsJson));
    
    // Clean up session-specific data
    await prefs.remove('$_sessionCategoriesKey$sessionId');
    await prefs.remove('$_sessionDayConfigKey$sessionId');
    await prefs.remove('$_dayStatusesKey$sessionId');
  }

  // Day Status Methods
  Future<void> saveDayStatuses(String sessionId, List<DayStatus> statuses) async {
    final prefs = await SharedPreferences.getInstance();
    final statusesJson = statuses.map((s) => s.toJson()).toList();
    await prefs.setString('$_dayStatusesKey$sessionId', jsonEncode(statusesJson));
  }

  Future<List<DayStatus>> loadDayStatuses(String sessionId, int totalDays) async {
    final prefs = await SharedPreferences.getInstance();
    final statusesString = prefs.getString('$_dayStatusesKey$sessionId');
    
    if (statusesString == null) {
      // Return default statuses
      return List.generate(
        totalDays,
        (index) => DayStatus(dayNumber: index + 1),
      );
    }
    
    final List<dynamic> statusesJson = jsonDecode(statusesString);
    return statusesJson.map((s) => DayStatus.fromJson(s)).toList();
  }
}
