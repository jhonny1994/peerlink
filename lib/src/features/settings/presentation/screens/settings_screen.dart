import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Placeholder screen for settings.
///
/// Phase 7: Will include theme switcher and language selector.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: Center(
        child: Text(l10n.settingsComingSoon),
      ),
    );
  }
}
