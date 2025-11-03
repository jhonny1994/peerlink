/// Base exception class for all PeerLink application exceptions.
///
/// All custom exceptions should extend this class for consistent error handling.
/// The [code] property maps to localized error messages via ErrorMapper.
abstract class AppException implements Exception {
  const AppException(this.code, [this.technicalDetails]);

  /// Error code for mapping to localized user-facing messages.
  final String code;

  /// Optional technical details for debugging (not shown to users).
  final String? technicalDetails;

  @override
  String toString() =>
      '$runtimeType: $code${technicalDetails != null ? ' - $technicalDetails' : ''}';
}
