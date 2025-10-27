import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Placeholder screen for receiver code entry.
class ReceiverCodeEntryScreen extends StatelessWidget {
  const ReceiverCodeEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.enterCode),
      ),
      body: Center(
        child: Text(l10n.receiverCodeEntryPlaceholder),
      ),
    );
  }
}

/// Placeholder screen for receiver accept/decline.
class ReceiverAcceptScreen extends StatelessWidget {
  const ReceiverAcceptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.acceptFile),
      ),
      body: Center(
        child: Text(l10n.receiverAcceptPlaceholder),
      ),
    );
  }
}

/// Placeholder screen for receiver progress.
class ReceiverProgressScreen extends StatelessWidget {
  const ReceiverProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.receivingFileTitle),
      ),
      body: Center(
        child: Text(l10n.receiverProgressPlaceholder),
      ),
    );
  }
}

/// Placeholder screen for receiver completion.
class ReceiverCompleteScreen extends StatelessWidget {
  const ReceiverCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.transferComplete),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: AppIconSize.huge,
              color: colorScheme.primary,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.fileReceivedSuccessfully),
            const SizedBox(height: AppSpacing.xxl),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}
