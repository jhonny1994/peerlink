import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/features/connection/domain/entities/peer_connection.dart'
    as peer;
import 'package:peerlink/src/src.dart' hide ConnectionState;
import 'package:qr_flutter/qr_flutter.dart';

/// Sender code display screen.
///
/// Displays 6-digit code and QR code for receiver to scan.
/// Once receiver connects, transfers begin on this screen - no navigation needed.
class SenderCodeScreen extends ConsumerStatefulWidget {
  const SenderCodeScreen({super.key});

  @override
  ConsumerState<SenderCodeScreen> createState() => _SenderCodeScreenState();
}

class _SenderCodeScreenState extends ConsumerState<SenderCodeScreen> {
  File? _file;
  String? _sessionId;
  bool _isInitializing = true;
  bool _isTransferring = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Get file from navigation arguments
    if (_file == null) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      _file = args?['file'] as File?;

      if (_file != null && _sessionId == null) {
        // Delay provider modification until after build phase
        // ignore: discarded_futures
        Future.microtask(_initializeConnection);
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

  Future<void> _startTransferAfterConnection() async {
    if (_file == null || _sessionId == null || !mounted || _isTransferring) {
      return;
    }

    setState(() => _isTransferring = true);

    try {
      // Send metadata immediately so receiver can see file info
      final dataChannelService = ref.read(dataChannelServiceProvider);
      await dataChannelService.waitForDataChannel(_sessionId!);

      final fileSize = await _file!.length();
      final fileName = _file!.path.split(Platform.pathSeparator).last;
      final hashService = ref.read(hashServiceProvider);
      final fileHash = await hashService.calculateFileHash(_file!.path);

      // Send metadata
      final metadata = {
        'type': 'metadata',
        'name': fileName,
        'size': fileSize,
        'mimeType': _getMimeType(fileName),
        'hash': fileHash,
      };
      await dataChannelService.sendData(
        _sessionId!,
        Uint8List.fromList(utf8.encode(json.encode(metadata))),
      );

      // Wait for receiver to accept with 30-second timeout
      final signalingService = ref.read(firestoreSignalingServiceProvider);
      final deadline = DateTime.now().add(const Duration(seconds: 30));
      var receiverReady = false;

      while (!receiverReady && DateTime.now().isBefore(deadline) && mounted) {
        final session = await signalingService.getSession(_sessionId!);

        if (session == null) {
          throw Exception('Session not found');
        }

        if (session.receiverReady) {
          receiverReady = true;
          break;
        }

        await Future<void>.delayed(const Duration(milliseconds: 500));
      }

      if (!mounted) return;

      if (!receiverReady) {
        throw Exception('Receiver did not accept within 30 seconds');
      }

      // Give receiver a brief moment to prepare
      await Future<void>.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Start transfer
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
    } finally {
      setState(() => _isTransferring = false);
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    final mimeTypes = {
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'txt': 'text/plain',
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'zip': 'application/zip',
      'mp4': 'video/mp4',
    };
    return mimeTypes[extension] ?? 'application/octet-stream';
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

    // When receiver connects, start the transfer directly on this screen
    connectionState?.whenData((connection) {
      if (connection.state == peer.ConnectionState.connected && mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          if (mounted) {
            await _startTransferAfterConnection();
          }
        });
      }
    });

    // Watch transfer progress from provider
    final transferState = _isTransferring
        ? ref.watch(fileSenderProvider)
        : const AsyncValue.data(null);

    return Shortcuts(
      shortcuts: AppKeyboardShortcuts.shortcuts,
      child: Actions(
        actions: {
          CopyCodeIntent: CallbackAction<CopyCodeIntent>(
            onInvoke: (_) async {
              await _copyCodeToClipboard();
              return null;
            },
          ),
          CancelIntent: CallbackAction<CancelIntent>(
            onInvoke: (_) {
              if (!_isTransferring) {
                Navigator.of(context).pop();
              }
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
                    child: _isTransferring
                        ? _buildTransferContent(
                            context,
                            l10n,
                            theme,
                            colorScheme,
                            transferState,
                          )
                        : _buildContent(context, l10n, theme, colorScheme),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTransferContent(
    BuildContext context,
    S l10n,
    ThemeData theme,
    ColorScheme colorScheme,
    AsyncValue<FileTransfer?> transferState,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InstructionText(l10n.sendingFileTitle),
        const SizedBox(height: AppSpacing.xxl),
        transferState.when(
          data: (transfer) {
            if (transfer != null && transfer.progress != null) {
              return TransferProgressWidget(
                fileName: transfer.metadata.name,
                progressPercentage: transfer.progress!.percentage / 100,
                transferSpeedMbps: transfer.progress!.speedMBps,
                onCancel: () =>
                    ref.read(fileSenderProvider.notifier).cancelTransfer(),
              );
            }
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: CircularProgressIndicator(),
              ),
            );
          },
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => Card(
            color: colorScheme.errorContainer,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Row(
                children: [
                  Icon(
                    Icons.error_rounded,
                    color: colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Text(
                      error.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        if (_file != null) _buildFileInfoCard(),
      ],
    );
  }

  Widget _buildContent(
    BuildContext context,
    S l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isDesktop =
        Platform.isWindows || Platform.isMacOS || Platform.isLinux;

    if (isDesktop && _sessionId != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InstructionText(l10n.shareThisCode),
                const SizedBox(height: AppSpacing.xxl),
                _buildCodeContainer(l10n, theme, colorScheme),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildQrCodeSection(l10n, theme, colorScheme),
                const SizedBox(height: AppSpacing.xxl),
                _buildWaitingStatusCard(l10n, theme),
                const SizedBox(height: AppSpacing.lg),
                if (_file != null) _buildFileInfoCard(),
              ],
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Instructions
          InstructionText(l10n.shareThisCode),
          const SizedBox(height: AppSpacing.xxl),

          // 6-digit code display
          _buildCodeContainer(l10n, theme, colorScheme),
          const SizedBox(height: AppSpacing.xxl),

          // QR Code
          if (_sessionId != null) ...[
            _buildQrCodeSection(l10n, theme, colorScheme),
            const SizedBox(height: AppSpacing.xxl),
          ],

          // Waiting status
          _buildWaitingStatusCard(l10n, theme),

          const SizedBox(height: AppSpacing.lg),

          // File info
          if (_file != null) _buildFileInfoCard(),
        ],
      );
    }
  }

  Widget _buildCodeContainer(
    S l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
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
    );
  }

  Widget _buildQrCodeSection(
    S l10n,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (_sessionId == null) return const SizedBox.shrink();

    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.borderRadiusLg,
      ),
      child: QrImageView(
        data: _sessionId!,
        size: AppDimensions.qrCodeSize,
      ),
    );
  }

  Widget _buildWaitingStatusCard(S l10n, ThemeData theme) {
    return Card(
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
    );
  }

  Widget _buildFileInfoCard() {
    return FutureBuilder<int>(
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
    );
  }
}
