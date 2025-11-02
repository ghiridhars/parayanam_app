/// Base exception class for application-specific errors.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() {
    if (code != null) {
      return 'AppException [$code]: $message';
    }
    return 'AppException: $message';
  }
}

/// Exception thrown when data validation fails.
class ValidationException extends AppException {
  const ValidationException(super.message, {super.code});
}

/// Exception thrown when authentication fails.
class AuthenticationException extends AppException {
  const AuthenticationException(super.message, {super.code});
}

/// Exception thrown when data storage/retrieval fails.
class StorageException extends AppException {
  const StorageException(super.message, {super.code, super.originalError});
}

/// Exception thrown when data parsing/serialization fails.
class DataParsingException extends AppException {
  const DataParsingException(super.message, {super.code, super.originalError});
}

/// Exception thrown when a resource is not found.
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

/// Exception thrown when an operation is not permitted.
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

/// Exception thrown when business rules are violated.
class BusinessRuleException extends AppException {
  const BusinessRuleException(super.message, {super.code});
}
