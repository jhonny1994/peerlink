import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/src.dart';

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
                      InstructionText(l10n.acceptFilePrompt),
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
