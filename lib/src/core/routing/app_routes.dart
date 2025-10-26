/// Route names for the application.
///
/// Centralized route definitions for easy navigation and maintenance.
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Root routes
  static const String home = '/';
  static const String settings = '/settings';

  // Sender flow
  static const String senderFilePicker = '/sender/file-picker';
  static const String senderCode = '/sender/code';
  static const String senderProgress = '/sender/progress';
  static const String senderComplete = '/sender/complete';

  // Receiver flow
  static const String receiverCodeEntry = '/receiver/code-entry';
  static const String receiverAccept = '/receiver/accept';
  static const String receiverProgress = '/receiver/progress';
  static const String receiverComplete = '/receiver/complete';
}
