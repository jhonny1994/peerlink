import 'package:flutter/material.dart';
import 'package:peerlink/src/src.dart';

/// Receiver completion screen.
///
/// Shows success message after file is received successfully.
class ReceiverCompleteScreen extends StatelessWidget {
  const ReceiverCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return SuccessScreen(
      title: l10n.transferComplete,
      message: l10n.fileReceivedSuccessfully,
      buttonLabel: l10n.done,
      onButtonPressed: () => AppNavigator.popUntilHome(context),
    );
  }
}
