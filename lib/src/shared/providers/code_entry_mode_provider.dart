import 'package:peerlink/src/shared/providers/shared_preferences_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'code_entry_mode_provider.g.dart';

const String _codeEntryModeKey = 'code_entry_mode';

/// Enum for code entry mode preference
enum CodeEntryMode {
  qr,
  manual,
}

/// Provider for managing code entry mode preference
/// Defaults to QR, can be toggled to manual entry
@riverpod
class CodeEntryModeNotifier extends _$CodeEntryModeNotifier {
  @override
  CodeEntryMode build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final stored = prefs.getString(_codeEntryModeKey);

    if (stored == null) {
      return CodeEntryMode.qr;
    }

    return CodeEntryMode.values.firstWhere(
      (mode) => mode.name == stored,
      orElse: () => CodeEntryMode.qr,
    );
  }

  /// Toggle between QR and manual entry modes
  Future<void> toggle() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final newMode = state == CodeEntryMode.qr
        ? CodeEntryMode.manual
        : CodeEntryMode.qr;
    await prefs.setString(_codeEntryModeKey, newMode.name);
    state = newMode;
  }

  /// Set mode explicitly
  Future<void> setMode(CodeEntryMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_codeEntryModeKey, mode.name);
    state = mode;
  }
}

/// Selector to check if QR mode is active
@riverpod
bool isQrModeActive(Ref ref) {
  return ref.watch(codeEntryModeProvider) == CodeEntryMode.qr;
}
