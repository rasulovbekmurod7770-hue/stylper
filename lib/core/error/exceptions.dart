/// Thrown by remote data sources when the server rejects a request.
///
/// [code] is the machine-readable error code from the API response body
/// (e.g. `invalid_credentials`); repositories map it to a domain failure.
class ServerException implements Exception {
  const ServerException({required this.statusCode, required this.code});

  final int statusCode;
  final String code;

  @override
  String toString() => 'ServerException($statusCode, $code)';
}

/// Thrown when the server can't be reached (offline, timeout, DNS…).
class NetworkException implements Exception {
  const NetworkException();
}

/// Error codes shared by the app and the backend contract.
abstract final class ApiErrorCodes {
  static const invalidCredentials = 'invalid_credentials';
  static const emailNotConfirmed = 'email_not_confirmed';
  static const emailTaken = 'email_taken';
  static const weakPassword = 'weak_password';
  static const userDisabled = 'user_disabled';
  static const tooManyRequests = 'too_many_requests';
  static const unauthorized = 'unauthorized';
  static const usernameTaken = 'username_taken';
  static const providerUnavailable = 'provider_unavailable';
  static const validation = 'validation_failed';
  static const notFound = 'not_found';
  static const forbidden = 'forbidden';

  /// Uploads (create-upload / finalize-upload): over 2 MB; a file not in
  /// storage yet; files that aren't WebP or are too large (deleted).
  static const fileTooLarge = 'file_too_large';
  static const uploadIncomplete = 'upload_incomplete';
  static const uploadRejected = 'upload_rejected';
}
