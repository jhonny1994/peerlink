import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/src.dart';

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
              InfoCard(text: l10n.homeInfoText),
              const SizedBox(height: AppSpacing.xxl),

              // Selected file display
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
      ),
    );
  }
}
