import 'dart:async';
import 'dart:convert';

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
  FileMetadata? _fileMetadata;
  bool _isWaitingForMetadata = true;
  StreamSubscription<dynamic>? _dataSubscription;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();

    // Get session ID from navigation arguments
    if (_sessionId == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _sessionId = args?['sessionId'] as String?;

      // Start listening for metadata from data channel
      if (_sessionId != null) {
        await _listenForMetadata();
      }
    }
  }

  @override
  void dispose() {
    // ignore: discarded_futures
    _dataSubscription?.cancel();
    super.dispose();
  }

  Future<void> _listenForMetadata() async {
    try {
      final dataChannelService = ref.read(dataChannelServiceProvider);

      // Wait for data channel to be ready
      await dataChannelService.waitForDataChannel(_sessionId!);

      // Listen for the first message (metadata)
      final dataStream = await dataChannelService.onDataReceived(_sessionId!);

      _dataSubscription = dataStream.listen(
        (data) async {
          if (_fileMetadata != null) return; // Already received metadata

          final metadataString = utf8.decode(data);
          final metadataJson =
              json.decode(metadataString) as Map<String, dynamic>;

          // Check if it's a metadata message
          if (metadataJson['type'] == 'metadata') {
            final metadata = FileMetadata(
              name: metadataJson['name'] as String,
              size: metadataJson['size'] as int,
              mimeType: metadataJson['mimeType'] as String,
              hash: metadataJson['hash'] as String,
            );

            if (mounted) {
              setState(() {
                _fileMetadata = metadata;
                _isWaitingForMetadata = false;
              });
            }

            // Cancel subscription after receiving metadata
            await _dataSubscription?.cancel();
          }
        },
        onError: (Object error) {
          if (mounted) {
            setState(() => _isWaitingForMetadata = false);
          }
        },
      );

      // Timeout after 10 seconds
      Future.delayed(const Duration(seconds: 10), () {
        if (mounted && _fileMetadata == null) {
          setState(() => _isWaitingForMetadata = false);
        }
      });
    } on Exception {
      if (mounted) {
        setState(() => _isWaitingForMetadata = false);
      }
    }
  }

  Future<void> _handleAccept() async {
    if (_sessionId == null) return;

    try {
      // CRITICAL: Mark receiver as ready in Firestore BEFORE navigating
      // This signals the sender that the receiver has accepted and is ready to receive
      final signalingService = ref.read(firestoreSignalingServiceProvider);
      await signalingService.setReceiverReady(_sessionId!);

      if (!mounted) return;

      // Now navigate to progress screen to start receiving
      await Navigator.of(context).pushReplacementNamed(
        AppRoutes.receiverProgress,
        arguments: {'sessionId': _sessionId},
      );
    } on Exception catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorSnackbar(
        context,
        ErrorMapper.mapError(e, context),
      );
    }
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
    final isDesktop = PlatformHelper.isDesktop;

    // Use provided metadata or show placeholder
    final metadata = _fileMetadata;
    final fileName = metadata?.name ?? 'File';
    final fileSize = metadata?.size ?? 0;

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
                  child: isDesktop
                      ? _buildDesktopLayout(
                          l10n,
                          theme,
                          colorScheme,
                          fileName,
                          fileSize,
                        )
                      : _buildMobileLayout(
                          l10n,
                          theme,
                          colorScheme,
                          fileName,
                          fileSize,
                        ),
                ),
              ),
      ),
    );
  }

  Widget _buildDesktopLayout(
    S l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    String fileName,
    int fileSize,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: DetailedFileInfoCard(
            fileName: fileName,
            fileSize: fileSize,
            warningText: fileSize > 80 * 1024 * 1024
                ? l10n.errorFileTooLarge
                : null,
            connectionInfo: l10n.homeInfoText,
          ),
        ),
        const SizedBox(width: AppSpacing.xxl),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Instructions
              InstructionText(l10n.acceptFilePrompt),
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
      ],
    );
  }

  Widget _buildMobileLayout(
    S l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    String fileName,
    int fileSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Instructions
        InstructionText(l10n.acceptFilePrompt),
        const SizedBox(height: AppSpacing.xxl),

        // File info card
        DetailedFileInfoCard(
          fileName: fileName,
          fileSize: fileSize,
          warningText: fileSize > 80 * 1024 * 1024
              ? l10n.errorFileTooLarge
              : null,
          connectionInfo: l10n.homeInfoText,
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
    );
  }
}
