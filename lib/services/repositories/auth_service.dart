import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:reader_app/core/utils/app_logger.dart';
import 'package:reader_app/core/constants/app_constants.dart';
import 'package:reader_app/core/constants/storage_keys.dart';
import 'package:reader_app/core/errors/exceptions.dart';
import 'package:reader_app/models/user_profile.dart';
import 'dart:convert';

/// Service responsible for user authentication and profile management
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _logSource = 'AuthService';

  /// Validates email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Hashes a password using BCrypt with salt
  String _hashPassword(String password) {
    try {
      AppLogger.debug('$_logSource: Hashing password with BCrypt');
      final hash = BCrypt.hashpw(password, BCrypt.gensalt(logRounds: AppConstants.bcryptWorkFactor));
      AppLogger.debug('$_logSource: Password hashed successfully');
      return hash;
    } catch (e) {
      AppLogger.error('$_logSource: Failed to hash password', e);
      throw AuthenticationException('Failed to hash password: $e');
    }
  }

  /// Verifies a password against a BCrypt hash
  bool _verifyPassword(String password, String hash) {
    try {
      AppLogger.debug('$_logSource: Verifying password with BCrypt');
      return BCrypt.checkpw(password, hash);
    } catch (e) {
      AppLogger.error('$_logSource: Failed to verify password', e);
      throw AuthenticationException('Failed to verify password: $e');
    }
  }

  /// Registers a new user
  Future<UserProfile> registerUser(String email, String name, String password) async {
    try {
      AppLogger.info('$_logSource: Attempting to register user: $email');

      // Validation
      if (name.trim().isEmpty) {
        throw ValidationException('Name cannot be empty');
      }

      if (!_isValidEmail(email)) {
        throw ValidationException('Invalid email format');
      }

      if (password.length < AppConstants.minPasswordLength) {
        throw ValidationException('Password must be at least ${AppConstants.minPasswordLength} characters');
      }

      final prefs = await SharedPreferences.getInstance();
      final userKey = StorageKeys.userProfile(email);

      // Check if user already exists
      if (prefs.containsKey(userKey)) {
        AppLogger.warning('$_logSource: User already exists: $email');
        throw AuthenticationException('User already exists');
      }

      // Create user profile
      final passwordHash = _hashPassword(password);
      final userProfile = UserProfile(
        email: email,
        name: name,
        passwordHash: passwordHash,
        createdAt: DateTime.now(),
      );

      // Save to storage
      await prefs.setString(userKey, json.encode(userProfile.toJson()));
      AppLogger.info('$_logSource: User registered successfully: $email');

      return userProfile;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      AppLogger.error('$_logSource: Failed to register user', e);
      throw StorageException('Failed to register user: $e');
    }
  }

  /// Logs in a user
  Future<UserProfile> loginUser(String email, String password) async {
    try {
      AppLogger.info('$_logSource: Attempting to login user: $email');

      if (!_isValidEmail(email)) {
        throw ValidationException('Invalid email format');
      }

      final prefs = await SharedPreferences.getInstance();
      final userKey = StorageKeys.userProfile(email);

      // Retrieve user profile
      final userJson = prefs.getString(userKey);
      if (userJson == null) {
        AppLogger.warning('$_logSource: User not found: $email');
        throw AuthenticationException('Invalid credentials');
      }

      final userProfile = UserProfile.fromJson(json.decode(userJson));

      // Verify password
      if (!_verifyPassword(password, userProfile.passwordHash)) {
        AppLogger.warning('$_logSource: Invalid password for user: $email');
        throw AuthenticationException('Invalid credentials');
      }

      AppLogger.info('$_logSource: User logged in successfully: $email');
      return userProfile;
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      AppLogger.error('$_logSource: Failed to login user', e);
      throw StorageException('Failed to login user: $e');
    }
  }

  /// Gets a user profile by email
  Future<UserProfile?> getUserProfile(String email) async {
    try {
      AppLogger.debug('$_logSource: Fetching user profile: $email');
      final prefs = await SharedPreferences.getInstance();
      final userKey = StorageKeys.userProfile(email);
      final userJson = prefs.getString(userKey);

      if (userJson == null) {
        AppLogger.debug('$_logSource: User profile not found: $email');
        return null;
      }

      return UserProfile.fromJson(json.decode(userJson));
    } catch (e) {
      AppLogger.error('$_logSource: Failed to get user profile', e);
      throw StorageException('Failed to get user profile: $e');
    }
  }

  /// Updates a user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    try {
      AppLogger.info('$_logSource: Updating user profile: ${profile.email}');
      final prefs = await SharedPreferences.getInstance();
      final userKey = StorageKeys.userProfile(profile.email);
      await prefs.setString(userKey, json.encode(profile.toJson()));
      AppLogger.info('$_logSource: User profile updated successfully');
    } catch (e) {
      AppLogger.error('$_logSource: Failed to update user profile', e);
      throw StorageException('Failed to update user profile: $e');
    }
  }

  /// Changes a user's password
  Future<void> changePassword(String email, String oldPassword, String newPassword) async {
    try {
      AppLogger.info('$_logSource: Attempting to change password for: $email');

      if (newPassword.length < AppConstants.minPasswordLength) {
        throw ValidationException('Password must be at least ${AppConstants.minPasswordLength} characters');
      }

      // Verify old password
      final profile = await loginUser(email, oldPassword);

      // Update with new password
      final newHash = _hashPassword(newPassword);
      final updatedProfile = UserProfile(
        email: profile.email,
        name: profile.name,
        passwordHash: newHash,
        createdAt: profile.createdAt,
      );

      await updateUserProfile(updatedProfile);
      AppLogger.info('$_logSource: Password changed successfully');
    } catch (e) {
      if (e is AppException) {
        rethrow;
      }
      AppLogger.error('$_logSource: Failed to change password', e);
      throw StorageException('Failed to change password: $e');
    }
  }
}
