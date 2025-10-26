import 'package:flutter/material.dart';

/// Placeholder screen for settings.
///
/// Phase 7: Will include theme switcher and language selector.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text('Settings - Coming in Phase 7'),
      ),
    );
  }
}
