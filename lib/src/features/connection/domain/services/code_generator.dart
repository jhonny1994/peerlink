import 'dart:math';

/// Generates a random 6-digit code for session identification
class CodeGenerator {
  CodeGenerator._();

  static final _random = Random.secure();

  /// Generate a 6-digit numeric code
  /// Returns a string like "123456"
  static String generate() {
    final code = _random.nextInt(900000) + 100000; // 100000 to 999999
    return code.toString();
  }

  /// Validate a session code
  /// Returns true if code is exactly 6 digits
  static bool isValid(String code) {
    if (code.length != 6) return false;
    return int.tryParse(code) != null;
  }
}
