import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Sender completion screen.
///
/// Shows success message after file is sent successfully.
class SenderCompleteScreen extends StatelessWidget {
  const SenderCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return SuccessScreen(
      title: l10n.transferComplete,
      message: l10n.fileSentSuccessfully,
      buttonLabel: l10n.done,
      onButtonPressed: () => AppNavigator.popUntilHome(context),
    );
  }
}
