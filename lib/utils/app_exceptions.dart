// Custom exceptions for the app

/// Base exception for all app-specific errors
class AppException implements Exception {
  final String message;
  final String? details;
  final dynamic originalError;

  const AppException(this.message, {this.details, this.originalError});

  @override
  String toString() => 'AppException: $message${details != null ? ' ($details)' : ''}';
}

/// Exception for database-related errors
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.details, super.originalError});

  factory DatabaseException.initFailed([dynamic error]) => DatabaseException(
    'Failed to initialize database',
    details: error?.toString(),
    originalError: error,
  );

  factory DatabaseException.readFailed(String entity, [dynamic error]) => DatabaseException(
    'Failed to read $entity',
    details: error?.toString(),
    originalError: error,
  );

  factory DatabaseException.writeFailed(String entity, [dynamic error]) => DatabaseException(
    'Failed to save $entity',
    details: error?.toString(),
    originalError: error,
  );

  factory DatabaseException.deleteFailed(String entity, [dynamic error]) => DatabaseException(
    'Failed to delete $entity',
    details: error?.toString(),
    originalError: error,
  );
}

/// Exception for import/export operations
class BackupException extends AppException {
  const BackupException(super.message, {super.details, super.originalError});

  factory BackupException.exportFailed([dynamic error]) => BackupException(
    'Failed to export data',
    details: error?.toString(),
    originalError: error,
  );

  factory BackupException.importFailed([dynamic error]) => BackupException(
    'Failed to import data',
    details: error?.toString(),
    originalError: error,
  );

  factory BackupException.invalidFormat([String? details]) => BackupException(
    'Invalid backup file format',
    details: details,
  );

  factory BackupException.versionMismatch(String version) => BackupException(
    'Unsupported backup version',
    details: 'Version: $version',
  );
}

/// Exception for validation errors
class ValidationException extends AppException {
  const ValidationException(super.message, {super.details});

  factory ValidationException.required(String field) => ValidationException(
    '$field is required',
  );

  factory ValidationException.invalidAmount() => ValidationException(
    'Please enter a valid amount',
  );

  factory ValidationException.invalidDate() => ValidationException(
    'Please select a valid date',
  );

  factory ValidationException.categoryRequired() => ValidationException(
    'Please select a category',
  );
}
