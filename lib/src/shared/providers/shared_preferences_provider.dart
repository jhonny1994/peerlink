import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// Global SharedPreferences provider
/// This provider throws UnimplementedError by default
/// Override in main.dart with actual SharedPreferences instance
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'SharedPreferences must be overridden in main.dart with actual instance',
  );
}
