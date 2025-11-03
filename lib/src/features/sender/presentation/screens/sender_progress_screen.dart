import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/src.dart';

/// Sender progress screen.
///
/// Shows real-time file transfer progress with percentage and speed.
/// Uses TransferProgressWidget for consistent UI with receiver.
class SenderProgressScreen extends ConsumerStatefulWidget {
  const SenderProgressScreen({super.key});

  @override
  ConsumerState<SenderProgressScreen> createState() =>
      _SenderProgressScreenState();
}

class _SenderProgressScreenState extends ConsumerState<SenderProgressScreen> {
  String? _sessionId;
  String? _filePath;
  bool _hasStartedTransfer = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get arguments from navigation
    if (_sessionId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _sessionId = args?['sessionId'] as String?;
      _filePath = args?['filePath'] as String?;

      // Start transfer
      if (_sessionId != null &&
          _filePath != null &&
          !_hasStartedTransfer &&
          mounted) {
        _hasStartedTransfer = true;
        unawaited(Future.microtask(_startTransfer));
      }
    }
  }

  Future<void> _startTransfer() async {
    if (_sessionId == null || _filePath == null) return;

    try {
      await ref
          .read(fileSenderProvider.notifier)
          .sendFile(
            _sessionId!,
            _filePath!,
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
                if (_sessionId != null && _filePath != null)
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
