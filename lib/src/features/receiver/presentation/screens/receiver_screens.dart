import 'package:flutter/material.dart';

/// Placeholder screen for receiver code entry.
class ReceiverCodeEntryScreen extends StatelessWidget {
  const ReceiverCodeEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Code'),
      ),
      body: const Center(
        child: Text('Receiver Code Entry - Coming Soon'),
      ),
    );
  }
}

/// Placeholder screen for receiver accept/decline.
class ReceiverAcceptScreen extends StatelessWidget {
  const ReceiverAcceptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept File'),
      ),
      body: const Center(
        child: Text('Receiver Accept/Decline - Coming Soon'),
      ),
    );
  }
}

/// Placeholder screen for receiver progress.
class ReceiverProgressScreen extends StatelessWidget {
  const ReceiverProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receiving File'),
      ),
      body: const Center(
        child: Text('Receiver Progress - Coming Soon'),
      ),
    );
  }
}

/// Placeholder screen for receiver completion.
class ReceiverCompleteScreen extends StatelessWidget {
  const ReceiverCompleteScreen({super.key});

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
            const Text('File received successfully!'),
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
