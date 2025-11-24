import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/src.dart';

/// Sender file picker screen.
///
/// Allows user to select a file to send. Validates file size (100MB limit),
/// requests necessary permissions, and navigates to code screen on success.
/// On desktop platforms, supports drag-and-drop file selection.
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
  bool _isDragging = false;

  final _filePickerService = FilePickerService();
  final _permissionService = PermissionService();

  // Check if running on desktop platform
  bool get _isDesktop => PlatformHelper.isDesktop;

  Future<void> _pickFile() async {
    if (!_isDesktop) {
      await HapticFeedback.selectionClick();
    }
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
        if (!_isDesktop) {
          await HapticFeedback.lightImpact();
        }
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

    try {
      // Check internet connection
      final networkService = ref.read(networkServiceProvider);
      final hasConnection = await networkService.hasConnection();

      if (!hasConnection) {
        if (!mounted) return;
        UiHelpers.showErrorSnackbar(
          context,
          S.of(context).errorNetwork,
        );
        return;
      }

      // CRITICAL: Reset any previous transfer state to clear old metadata
      ref.read(fileSenderProvider.notifier).reset();

      // Navigate to code screen with selected file
      if (mounted) {
        await Navigator.of(context).pushNamed(
          AppRoutes.senderCode,
          arguments: {'file': _selectedFile},
        );
      }
    } on Exception catch (e) {
      if (!mounted) return;
      UiHelpers.showErrorSnackbar(
        context,
        ErrorMapper.mapError(e, context),
      );
    }
  }

  Future<void> _handleDroppedFile(File file) async {
    setState(() => _isLoading = true);

    try {
      // Validate file size (100MB limit)
      final fileSize = await file.length();
      const maxFileSizeBytes = 100 * 1024 * 1024; // 100 MB

      if (fileSize > maxFileSizeBytes) {
        throw FilePickerException(FilePickerErrorCode.fileTooLarge);
      }

      if (!mounted) return;

      setState(() => _selectedFile = file);
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);

    final body = SafeArea(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            InfoCard(text: l10n.homeInfoText),
            const SizedBox(height: AppSpacing.xxl),

            // Desktop drag-and-drop zone
            if (_isDesktop) ...[
              Expanded(
                child: Semantics(
                  label: l10n.dragDropFile,
                  hint: l10n.dropFileHere,
                  button: true,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _isDragging
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: _isDragging ? 2 : 1,
                      ),
                      borderRadius: AppRadius.borderRadiusLg,
                      color: _isDragging
                          ? Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withValues(
                              alpha: 0.1,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _isDragging
                                ? Icons.file_download_rounded
                                : Icons.cloud_upload_outlined,
                            size: AppIconSize.huge,
                            color: _isDragging
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            _isDragging ? l10n.dropFileHere : l10n.dragDropFile,
                            style: Theme.of(context).textTheme.titleLarge,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l10n.orClickToSelect,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ] else ...[
              // Mobile: Show selected file or spacer
              if (_selectedFile != null) ...[
                FutureBuilder<int>(
                  future: _selectedFile!.length(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return FileInfoCard(
                        fileName: _selectedFile!.uri.pathSegments.last,
                        fileSize: snapshot.data!,
                        highlighted: true,
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
                const SizedBox(height: AppSpacing.xl),
              ],
              const Spacer(),
            ],

            // Selected file display (for desktop when file is selected)
            if (_isDesktop && _selectedFile != null) ...[
              FutureBuilder<int>(
                future: _selectedFile!.length(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return FileInfoCard(
                      fileName: _selectedFile!.uri.pathSegments.last,
                      fileSize: snapshot.data!,
                      highlighted: true,
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],

            // Pick file button
            FilledButton.icon(
              onPressed: _isLoading ? null : _pickFile,
              icon: _isLoading
                  ? const LoadingButtonIcon()
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
    );

    return Shortcuts(
      shortcuts: AppKeyboardShortcuts.shortcuts,
      child: Actions(
        actions: {
          SelectFileIntent: CallbackAction<SelectFileIntent>(
            onInvoke: (_) async {
              if (!_isLoading) await _pickFile();
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
            title: Text(l10n.selectFile),
          ),
          body: _isDesktop
              ? DropTarget(
                  onDragEntered: (_) => setState(() => _isDragging = true),
                  onDragExited: (_) => setState(() => _isDragging = false),
                  onDragDone: (details) async {
                    setState(() => _isDragging = false);
                    if (details.files.isNotEmpty) {
                      final file = File(details.files.first.path);
                      await _handleDroppedFile(file);
                    }
                  },
                  child: body,
                )
              : body,
        ),
      ),
    );
  }
}
