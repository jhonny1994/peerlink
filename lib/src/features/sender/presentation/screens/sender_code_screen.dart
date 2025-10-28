import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/features/connection/domain/entities/peer_connection.dart'
    as connection_entities;
import 'package:peerlink/src/src.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

    return Shortcuts(
      shortcuts: AppKeyboardShortcuts.shortcuts,
      child: Actions(
        actions: {
          CopyCodeIntent: CallbackAction<CopyCodeIntent>(
            onInvoke: (_) {
              _copyCodeToClipboard();
              return null;
            },
          ),
          CancelIntent: CallbackAction<CancelIntent>(
            onInvoke: (_) {
              Navigator.of(context).pop();
              return null;
            },
          ),
        },
        child: Scaffold(
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
                    InstructionText(l10n.shareThisCode),
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
                            const LoadingButtonIcon(),
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
                      FutureBuilder<int>(
                        future: _file!.length(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return FileInfoCard(
                              fileName: _file!.uri.pathSegments.last,
                              fileSize: snapshot.data!,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
}
