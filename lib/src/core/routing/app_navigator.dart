import 'package:flutter/material.dart';
import 'package:peerlink/src/core/routing/app_routes.dart';

/// Navigation helper utilities for common navigation patterns.
///
/// Provides type-safe navigation methods and reduces boilerplate.
class AppNavigator {
  AppNavigator._();

  // Home navigation
  static Future<void> toHome(BuildContext context) async {
    await Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  // Settings navigation
  static Future<void> toSettings(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.settings);
  }

  // Sender flow navigation
  static Future<void> toSenderFilePicker(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.senderFilePicker);
  }

  static Future<void> toSenderCode(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.senderCode);
  }

  static Future<void> toSenderProgress(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.senderProgress);
  }

  static Future<void> toSenderComplete(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.senderComplete);
  }

  // Receiver flow navigation
  static Future<void> toReceiverCodeEntry(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.receiverCodeEntry);
  }

  static Future<void> toReceiverAccept(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.receiverAccept);
  }

  static Future<void> toReceiverProgress(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.receiverProgress);
  }

  static Future<void> toReceiverComplete(BuildContext context) async {
    await Navigator.of(context).pushNamed(AppRoutes.receiverComplete);
  }

  // Common navigation patterns
  static void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  static bool canPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  static void popUntilHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  // Future-proof: Support for passing arguments
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.of(context).pushReplacementNamed<T, TO>(
      routeName,
      result: result,
      arguments: arguments,
    );
  }
}
