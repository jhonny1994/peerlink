import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/src.dart';

/// Receiver code entry screen.
///
/// Allows user to enter 6-digit code manually or scan QR code.
/// Validates code and navigates to accept screen on success.
class ReceiverCodeEntryScreen extends ConsumerStatefulWidget {
  const ReceiverCodeEntryScreen({super.key});

  @override
  ConsumerState<ReceiverCodeEntryScreen> createState() =>
      _ReceiverCodeEntryScreenState();
}

class _ReceiverCodeEntryScreenState
    extends ConsumerState<ReceiverCodeEntryScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isJoining = false;

  final _permissionService = PermissionService();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleCodeSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final code = _codeController.text.trim();
    await _joinConnection(code);
  }

  Future<void> _joinConnection(String sessionId) async {
    setState(() => _isJoining = true);

    try {
      // Join connection
      await ref
          .read(connectionJoinerProvider.notifier)
          .joinConnection(
            sessionId,
          );

      final connectionState = ref.read(connectionJoinerProvider);

      if (!mounted) return;

      await connectionState.when(
        data: (connection) async {
          if (connection != null) {
            // Navigate to accept screen
            await AppNavigator.pushNamed<void>(
              context,
              AppRoutes.receiverAccept,
              arguments: {'sessionId': sessionId},
            );
          } else {
            throw Exception('Failed to join connection');
          }
        },
        loading: () async {},
        error: (error, stack) async {
          throw error as Exception;
        },
      );
    } on Exception catch (e) {
      if (!mounted) return;

      UiHelpers.showErrorSnackbar(
        context,
        ErrorMapper.mapError(e, context),
      );
    } finally {
      if (mounted) {
        setState(() => _isJoining = false);
      }
    }
  }

  Future<void> _openQrScanner() async {
    // Check camera permission
    final permissionResult = await _permissionService.requestCameraPermission();

    if (!mounted) return;

    if (permissionResult == PermissionResult.denied) {
      UiHelpers.showErrorSnackbar(
        context,
        S.of(context).errorCameraPermissionDenied,
      );
      return;
    }

    if (permissionResult == PermissionResult.permanentlyDenied) {
      UiHelpers.showErrorSnackbar(
        context,
        S.of(context).errorCameraPermissionPermanentlyDenied,
      );
      return;
    }

    // Open QR scanner
    if (!mounted) return;

    final scannedCode = await AppNavigator.pushNamed<String>(
      context,
      AppRoutes.qrScanner,
    );

    if (scannedCode != null && mounted) {
      _codeController.text = scannedCode;
      await _joinConnection(scannedCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.enterCode),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Instructions
                InstructionText(l10n.enterCodePrompt),
                const SizedBox(height: AppSpacing.xxl),

                // Code input field
                TextFormField(
                  controller: _codeController,
                  decoration: InputDecoration(
                    labelText: l10n.enterCode,
                    hintText: '123456',
                    prefixIcon: const Icon(Icons.dialpad_rounded),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.borderRadiusMd,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    letterSpacing: AppDimensions.codeLetterSpacing,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.errorCodeRequired;
                    }
                    if (value.length != 6) {
                      return l10n.errorCodeInvalid;
                    }
                    return null;
                  },
                  enabled: !_isJoining,
                  onFieldSubmitted: (_) => _handleCodeSubmit(),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Join button
                FilledButton.icon(
                  onPressed: _isJoining ? null : _handleCodeSubmit,
                  icon: _isJoining
                      ? const LoadingButtonIcon()
                      : const Icon(Icons.check_rounded),
                  label: Text(l10n.confirm),
                  style: FilledButton.styleFrom(
                    padding: AppSpacing.buttonPaddingVertical,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Divider with "OR"
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        l10n.or,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // QR scanner button
                OutlinedButton.icon(
                  onPressed: _isJoining ? null : _openQrScanner,
                  icon: const Icon(Icons.qr_code_scanner_rounded),
                  label: Text(l10n.scanQrCode),
                  style: OutlinedButton.styleFrom(
                    padding: AppSpacing.buttonPaddingVertical,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Info card
                InfoCard(text: l10n.homeInfoText),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
