import 'package:flutter/material.dart';

/// Reusable instruction/header text widget.
///
/// Provides consistent styling for instruction text
/// at the top of screens.
class InstructionText extends StatelessWidget {
  const InstructionText(this.text, {super.key});

  /// The instruction text to display
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium,
      textAlign: TextAlign.center,
    );
  }
}
