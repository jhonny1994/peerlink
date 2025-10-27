import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/features/connection/domain/entities/peer_connection.dart'
    as connection_entities;
import 'package:peerlink/src/src.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Sender file picker screen.
///
/// Allows user to select a file to send. Validates file size (100MB limit),
/// requests necessary permissions, and navigates to code screen on success.
class SenderFilePickerScreen extends ConsumerStatefulWidget {
  const SenderFilePickerScreen({super.key});

  @override
  ConsumerState<SenderFilePickerScreen> createState() =>
      _SenderFilePickerScreenState();
}

class _SenderFilePickerScreenState
    extends ConsumerState<SenderFilePickerScreen> {
  File? _selectedFile;
  bool _isLoading = false;

  final _filePickerService = FilePickerService();
  final _permissionService = PermissionService();

  Future<void> _pickFile() async {
    setState(() => _isLoading = true);

    try {
      // Check storage permission (Android only)
      final permissionResult = await _permissionService
          .requestStoragePermission();

      if (!mounted) return;

      if (permissionResult == PermissionResult.denied ||
          permissionResult == PermissionResult.permanentlyDenied) {
        UiHelpers.showErrorSnackbar(
          context,
          ErrorMapper.mapError(Exception('storage permission'), context),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Pick file
      final file = await _filePickerService.pickFile();

      if (!mounted) return;

      if (file != null) {
        setState(() => _selectedFile = file);
      }
    } on FilePickerException catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorSnackbar(
        context,
        ErrorMapper.mapError(e, context),
      );
    } on Exception catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorSnackbar(
        context,
        ErrorMapper.mapError(e, context),
      );
    } finally {
      if (context.mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _proceedToCodeScreen() async {
    if (_selectedFile == null) return;

    // Navigate to code screen with selected file
    await AppNavigator.pushNamed<void>(
      context,
      AppRoutes.senderCode,
      arguments: {'file': _selectedFile},
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.selectFile),
      ),
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: AppSpacing.xxl),

              // Selected file display
              if (_selectedFile != null) ...[
                Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.insert_drive_file_rounded,
                              color: colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                _selectedFile!.uri.pathSegments.last,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        FutureBuilder<int>(
                          future: _selectedFile!.length(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Text(
                                UiHelpers.formatFileSize(
                                  context,
                                  snapshot.data!,
                                ),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onPrimaryContainer
                                      .withValues(alpha: 0.8),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              const Spacer(),

              // Pick file button
              FilledButton.icon(
                onPressed: _isLoading ? null : _pickFile,
                icon: _isLoading
                    ? const SizedBox(
                        width: AppDimensions.loadingIndicatorSmall,
                        height: AppDimensions.loadingIndicatorSmall,
                        child: CircularProgressIndicator(
                          strokeWidth:
                              AppDimensions.loadingIndicatorStrokeWidth,
                        ),
                      )
                    : const Icon(Icons.folder_open_rounded),
                label: Text(
                  _selectedFile == null ? l10n.selectFile : l10n.selectFile,
                ),
                style: FilledButton.styleFrom(
                  padding: AppSpacing.buttonPaddingVertical,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Continue button (only shown when file selected)
              if (_selectedFile != null)
                FilledButton.tonalIcon(
                  onPressed: _proceedToCodeScreen,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(l10n.confirm),
                  style: FilledButton.styleFrom(
                    padding: AppSpacing.buttonPaddingVertical,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sender code display screen.
///
/// Displays 6-digit code and QR code for receiver to scan.
/// Initiates WebRTC connection and waits for receiver to join.
class SenderCodeScreen extends ConsumerStatefulWidget {
  const SenderCodeScreen({super.key});

  @override
  ConsumerState<SenderCodeScreen> createState() => _SenderCodeScreenState();
}

class _SenderCodeScreenState extends ConsumerState<SenderCodeScreen> {
  File? _file;
  String? _sessionId;
  bool _isInitializing = true;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    // Get file from navigation arguments
    if (_file == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _file = args?['file'] as File?;

      if (_file != null && _sessionId == null) {
        await _initializeConnection();
      }
    }
  }

  Future<void> _initializeConnection() async {
    try {
      // Create connection and get session ID
      await ref.read(connectionCreatorProvider.notifier).createConnection();

      final connection = ref.read(connectionCreatorProvider).value;

      if (!mounted) return;

      if (connection != null) {
        setState(() {
          _sessionId = connection.sessionId;
          _isInitializing = false;
        });
      } else {
        throw Exception('Failed to create connection');
      }
    } on Exception catch (e) {
      if (!mounted) return;

      UiHelpers.showErrorSnackbar(
        context,
        ErrorMapper.mapError(e, context),
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> _copyCodeToClipboard() async {
    if (_sessionId == null) return;

    await Clipboard.setData(ClipboardData(text: _sessionId!));

    if (!mounted) return;

    UiHelpers.showSuccessSnackbar(
      context,
      S.of(context).codeCopied,
    );
  }

  @override
  void dispose() {
    // Connection will be cleaned up when transfer completes or is cancelled
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Listen to connection state changes
    final connectionState = _sessionId != null
        ? ref.watch(connectionStreamProvider(_sessionId!))
        : null;

    // Navigate to progress screen when receiver connects
    connectionState?.whenData((connection) {
      if (connection.state == connection_entities.ConnectionState.connected &&
          mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await AppNavigator.pushReplacementNamed<void, void>(
            context,
            AppRoutes.senderProgress,
            arguments: {
              'file': _file,
              'sessionId': _sessionId,
            },
          );
        });
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shareCode),
      ),
      body: _isInitializing
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Instructions
                    Text(
                      l10n.shareThisCode,
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // 6-digit code display
                    Container(
                      padding: AppSpacing.cardPaddingLarge,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: AppRadius.borderRadiusLg,
                      ),
                      child: Column(
                        children: [
                          Text(
                            _sessionId ?? '',
                            style: theme.textTheme.displayLarge?.copyWith(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              letterSpacing: AppDimensions.codeLetterSpacing,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          FilledButton.tonalIcon(
                            onPressed: _copyCodeToClipboard,
                            icon: const Icon(Icons.copy_rounded),
                            label: Text(l10n.copyCode),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),

                    // QR Code
                    if (_sessionId != null) ...[
                      Container(
                        padding: AppSpacing.cardPadding,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: AppRadius.borderRadiusLg,
                        ),
                        child: QrImageView(
                          data: _sessionId!,
                          size: AppDimensions.qrCodeSize,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],

                    // Waiting status
                    Card(
                      child: Padding(
                        padding: AppSpacing.cardPadding,
                        child: Row(
                          children: [
                            SizedBox(
                              width: AppDimensions.loadingIndicatorSmall,
                              height: AppDimensions.loadingIndicatorSmall,
                              child: CircularProgressIndicator(
                                strokeWidth:
                                    AppDimensions.loadingIndicatorStrokeWidth,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Text(
                                l10n.waitingForReceiver,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // File info
                    if (_file != null)
                      Card(
                        child: Padding(
                          padding: AppSpacing.cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.insert_drive_file_rounded,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: Text(
                                      _file!.uri.pathSegments.last,
                                      style: theme.textTheme.titleSmall,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              FutureBuilder<int>(
                                future: _file!.length(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return Text(
                                      UiHelpers.formatFileSize(
                                        context,
                                        snapshot.data!,
                                      ),
                                      style: theme.textTheme.bodySmall,
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Sender progress screen.
///
/// Shows real-time file transfer progress with percentage and speed.
/// Uses TransferProgressWidget for consistent UI across sender/receiver.
class SenderProgressScreen extends ConsumerStatefulWidget {
  const SenderProgressScreen({super.key});

  @override
  ConsumerState<SenderProgressScreen> createState() =>
      _SenderProgressScreenState();
}

class _SenderProgressScreenState extends ConsumerState<SenderProgressScreen> {
  File? _file;
  String? _sessionId;
  bool _hasStartedTransfer = false;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    // Get arguments from navigation
    if (_file == null || _sessionId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _file = args?['file'] as File?;
      _sessionId = args?['sessionId'] as String?;

      // Start transfer
      if (_file != null && _sessionId != null && !_hasStartedTransfer) {
        _hasStartedTransfer = true;
        await _startTransfer();
      }
    }
  }

  Future<void> _startTransfer() async {
    if (_file == null || _sessionId == null) return;

    try {
      await ref
          .read(fileSenderProvider.notifier)
          .sendFile(
            _sessionId!,
            _file!.path,
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
      await ref.read(fileSenderProvider.notifier).cancelTransfer();

      if (mounted) {
        AppNavigator.popUntilHome(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final transferState = ref.watch(fileSenderProvider)
      // Handle transfer completion
      ..whenData((transfer) {
        if (transfer != null &&
            transfer.state == TransferState.completed &&
            mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await AppNavigator.pushReplacementNamed<void, void>(
              context,
              AppRoutes.senderComplete,
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
          title: Text(l10n.sendingFileTitle),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_file != null && _sessionId != null)
                  transferState.when(
                    data: (transfer) {
                      if (transfer == null || transfer.progress == null) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return TransferProgressWidget(
                        fileName: _file!.uri.pathSegments.last,
                        progressPercentage: transfer.progress!.percentage / 100,
                        transferSpeedMbps: transfer.progress!.speedMBps,
                        onCancel: _handleCancel,
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (_, _) => const Center(
                      child: Icon(Icons.error_outline, size: 48),
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

/// Placeholder screen for sender completion.
class SenderCompleteScreen extends StatelessWidget {
  const SenderCompleteScreen({super.key});

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
            Text(l10n.fileSentSuccessfully),
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
