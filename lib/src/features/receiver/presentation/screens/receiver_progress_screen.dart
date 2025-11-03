import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/src.dart';

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
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments from navigation
    if (_sessionId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _sessionId = args?['sessionId'] as String?;

      // Get platform-specific save directory
      if (_sessionId != null && _savePath == null && !_hasStartedTransfer) {
        _hasStartedTransfer = true;
        unawaited(Future.microtask(_initializeSavePathAndTransfer));
      }
    }
  }

  /// Initialize save path based on platform and start transfer
  Future<void> _initializeSavePathAndTransfer() async {
    try {
      final filePathService = ref.read(filePathServiceProvider);
      final directory = await filePathService.getDownloadDirectory();
      _savePath = directory.path;

      // Start transfer
      unawaited(Future.microtask(_startTransfer));
    } on Exception catch (e) {
      if (!mounted) return;

      UiHelpers.showErrorSnackbar(
        context,
        ErrorMapper.mapError(e, context),
      );
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

    // Haptic feedback for mobile
    if (!PlatformHelper.isDesktop) {
      await HapticFeedback.heavyImpact();
    }

    final confirmed = await UiHelpers.showConfirmDialog(
      // ignore: use_build_context_synchronously
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
