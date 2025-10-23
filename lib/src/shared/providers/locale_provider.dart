import 'dart:ui';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'shared_preferences_provider.dart';

part 'locale_provider.g.dart';

const String _localeKey = 'locale';

/// Locale provider that reads from SharedPreferences
/// Defaults to system locale if no preference is stored
@riverpod
class LocaleNotifier extends _$LocaleNotifier {
  @override
  Locale? build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final localeString = prefs.getString(_localeKey);

    if (localeString == null) {
      return null; // Use system locale
    }

    final parts = localeString.split('_');
    return Locale(parts[0], parts.length > 1 ? parts[1] : null);
  }

  /// Set locale and persist to SharedPreferences
  Future<void> setLocale(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);

    if (locale == null) {
      await prefs.remove(_localeKey);
    } else {
      final localeString = locale.countryCode != null
          ? '${locale.languageCode}_${locale.countryCode}'
          : locale.languageCode;
      await prefs.setString(_localeKey, localeString);
    }

    state = locale;
  }
}
