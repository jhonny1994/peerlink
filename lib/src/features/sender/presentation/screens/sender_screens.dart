import 'package:flutter/material.dart';

/// Placeholder screen for sender file picker.
///
/// This will be replaced with the full implementation.
class SenderFilePickerScreen extends StatelessWidget {
  const SenderFilePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select File'),
      ),
      body: const Center(
        child: Text('Sender File Picker - Coming Soon'),
      ),
    );
  }
}

/// Placeholder screen for sender code display.
class SenderCodeScreen extends StatelessWidget {
  const SenderCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Code'),
      ),
      body: const Center(
        child: Text('Sender Code Display - Coming Soon'),
      ),
    );
  }
}

/// Placeholder screen for sender progress.
class SenderProgressScreen extends StatelessWidget {
  const SenderProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sending File'),
      ),
      body: const Center(
        child: Text('Sender Progress - Coming Soon'),
      ),
    );
  }
}

/// Placeholder screen for sender completion.
class SenderCompleteScreen extends StatelessWidget {
  const SenderCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Complete'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 80, color: Colors.green),
            const SizedBox(height: 16),
            const Text('File sent successfully!'),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }
}
