import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
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

    final scannedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (context) => const _QrScannerScreen(),
      ),
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
                Text(
                  l10n.enterCodePrompt,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
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
                      ? const SizedBox(
                          width: AppDimensions.loadingIndicatorSmall,
                          height: AppDimensions.loadingIndicatorSmall,
                          child: CircularProgressIndicator(
                            strokeWidth:
                                AppDimensions.loadingIndicatorStrokeWidth,
                          ),
                        )
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
                Card(
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Text(
                            l10n.homeInfoText,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// QR scanner screen for scanning sender's QR code.
class _QrScannerScreen extends StatefulWidget {
  const _QrScannerScreen();

  @override
  State<_QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<_QrScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _hasScanned = false;

  @override
  void dispose() {
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodeCapture) {
    if (_hasScanned) return;

    final barcode = barcodeCapture.barcodes.firstOrNull;
    if (barcode?.rawValue != null) {
      _hasScanned = true;
      Navigator.of(context).pop(barcode!.rawValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanQrCode),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Scanner view
          MobileScanner(
            controller: _scannerController,
            onDetect: _handleBarcode,
          ),

          // Overlay with instructions
          SafeArea(
            child: Column(
              children: [
                const Spacer(),
                Container(
                  width: double.infinity,
                  padding: AppSpacing.cardPaddingLarge,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                  ),
                  child: Text(
                    l10n.scanQrCodePrompt,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Receiver accept/decline screen.
///
/// Displays file metadata and sender information.
/// User can accept to start transfer or decline to reject.
class ReceiverAcceptScreen extends ConsumerStatefulWidget {
  const ReceiverAcceptScreen({super.key});

  @override
  ConsumerState<ReceiverAcceptScreen> createState() =>
      _ReceiverAcceptScreenState();
}

class _ReceiverAcceptScreenState extends ConsumerState<ReceiverAcceptScreen> {
  String? _sessionId;
  bool _isWaitingForMetadata = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get session ID from navigation arguments
    if (_sessionId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _sessionId = args?['sessionId'] as String?;

      // Start listening to connection to wait for metadata
      if (_sessionId != null) {
        // In a real implementation, metadata would come through data channel
        // For now, we'll simulate this by waiting a moment
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            setState(() => _isWaitingForMetadata = false);
          }
        });
      }
    }
  }

  Future<void> _handleAccept() async {
    if (_sessionId == null) return;

    // Navigate to progress screen to start receiving
    await AppNavigator.pushReplacementNamed<void, void>(
      context,
      AppRoutes.receiverProgress,
      arguments: {'sessionId': _sessionId},
    );
  }

  Future<void> _handleDecline() async {
    final l10n = S.of(context);

    // Show confirmation dialog
    final confirmed = await UiHelpers.showConfirmDialog(
      context,
      title: l10n.cancelTransfer,
      message: S.of(context).acceptFilePrompt,
    );

    if (confirmed && mounted) {
      // Close connection
      await ref.read(connectionJoinerProvider.notifier).closeConnection();

      // Return to home
      if (mounted) {
        AppNavigator.popUntilHome(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // In a real implementation, metadata would come from data channel
    // For now, we'll use placeholder values
    const fileName = 'document.pdf';
    const fileSize = 5242880; // 5 MB

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.acceptFile),
          automaticallyImplyLeading: false,
        ),
        body: _isWaitingForMetadata
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Instructions
                      Text(
                        l10n.acceptFilePrompt,
                        style: theme.textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // File info card
                      Card(
                        child: Padding(
                          padding: AppSpacing.cardPaddingLarge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // File icon and name
                              Row(
                                children: [
                                  Icon(
                                    Icons.insert_drive_file_rounded,
                                    size: AppIconSize.xxl,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.lg),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          fileName,
                                          style: theme.textTheme.titleLarge
                                              ?.copyWith(
                                                fontWeight: FontWeight.w600,
                                              ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: AppSpacing.xs),
                                        Text(
                                          UiHelpers.formatFileSize(
                                            context,
                                            fileSize,
                                          ),
                                          style: theme.textTheme.bodyLarge
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onSurfaceVariant,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xl),

                              // File size warning if near limit
                              if (fileSize > 80 * 1024 * 1024) ...[
                                // 80 MB
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: AppRadius.borderRadiusSm,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.warning_rounded,
                                        size: AppIconSize.sm,
                                        color: colorScheme.onErrorContainer,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          l10n.errorFileTooLarge,
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                                color: colorScheme
                                                    .onErrorContainer,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                              ],

                              // Connection info
                              Divider(color: colorScheme.outlineVariant),
                              const SizedBox(height: AppSpacing.lg),
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: AppIconSize.sm,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      l10n.homeInfoText,
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),

                      // Accept button
                      FilledButton.icon(
                        onPressed: _handleAccept,
                        icon: const Icon(Icons.download_rounded),
                        label: Text(l10n.acceptFile),
                        style: FilledButton.styleFrom(
                          padding: AppSpacing.buttonPaddingVertical,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Decline button
                      OutlinedButton.icon(
                        onPressed: _handleDecline,
                        icon: const Icon(Icons.close_rounded),
                        label: Text(l10n.cancel),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.error,
                          side: BorderSide(color: colorScheme.error),
                          padding: AppSpacing.buttonPaddingVertical,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Receiver progress screen.
///
/// Shows real-time file transfer progress with percentage and speed.
/// Uses TransferProgressWidget for consistent UI with sender.
class ReceiverProgressScreen extends ConsumerStatefulWidget {
  const ReceiverProgressScreen({super.key});

  @override
  ConsumerState<ReceiverProgressScreen> createState() =>
      _ReceiverProgressScreenState();
}

class _ReceiverProgressScreenState
    extends ConsumerState<ReceiverProgressScreen> {
  String? _sessionId;
  String? _savePath;
  bool _hasStartedTransfer = false;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    // Get arguments from navigation
    if (_sessionId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _sessionId = args?['sessionId'] as String?;

      // For now, use Downloads directory (platform-specific logic needed)
      // In production, this would use path_provider or file picker
      _savePath = 'Downloads/received_file';

      // Start transfer
      if (_sessionId != null && _savePath != null && !_hasStartedTransfer) {
        _hasStartedTransfer = true;
        await _startTransfer();
      }
    }
  }

  Future<void> _startTransfer() async {
    if (_sessionId == null || _savePath == null) return;

    try {
      await ref
          .read(fileReceiverProvider.notifier)
          .receiveFile(
            _sessionId!,
            _savePath!,
          );
    } on Exception catch (e) {
      if (!mounted) return;

      UiHelpers.showErrorSnackbar(
        context,
        ErrorMapper.mapError(e, context),
      );
    }
  }

  Future<void> _handleCancel() async {
    final l10n = S.of(context);

    final confirmed = await UiHelpers.showConfirmDialog(
      context,
      title: l10n.cancelTransfer,
      message: l10n.cancelTransfer,
      isDangerousAction: true,
    );

    if (confirmed && mounted) {
      await ref.read(fileReceiverProvider.notifier).cancelTransfer();

      if (mounted) {
        AppNavigator.popUntilHome(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final transferState = ref.watch(fileReceiverProvider)
      // Handle transfer completion
      ..whenData((transfer) {
        if (transfer != null &&
            transfer.state == TransferState.completed &&
            mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await AppNavigator.pushReplacementNamed<void, void>(
              context,
              AppRoutes.receiverComplete,
            );
          });
        }
      })
      // Handle transfer errors
      ..whenOrNull(
        error: (error, stackTrace) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            if (context.mounted) {
              await UiHelpers.showErrorDialog(
                context,
                title: l10n.errorUnexpected,
                message: ErrorMapper.mapError(error, context),
              ).then((_) {
                if (context.mounted) {
                  AppNavigator.popUntilHome(context);
                }
              });
            }
          });
        },
      );

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.receivingFileTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_sessionId != null && _savePath != null)
                  transferState.when(
                    data: (transfer) {
                      if (transfer == null || transfer.progress == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return TransferProgressWidget(
                        fileName: transfer.metadata.name,
                        progressPercentage: transfer.progress!.percentage / 100,
                        transferSpeedMbps: transfer.progress!.speedMBps,
                        onCancel: _handleCancel,
                        isSending: false,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Center(
                      child: Icon(Icons.error_outline, size: AppIconSize.xxl),
                    ),
                  )
                else
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  size: AppIconSize.huge,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.fileReceivedSuccessfully,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xxxl),
                FilledButton.icon(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(l10n.done),
                  style: FilledButton.styleFrom(
                    padding: AppSpacing.buttonPaddingVertical,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
