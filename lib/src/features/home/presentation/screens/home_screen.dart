import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/src.dart';

/// Home screen with large Send and Receive buttons.
///
/// The main entry point for PeerLink's user interface.
/// Uses Material You design with generous spacing and touch targets.
/// Responsive layout: vertical on mobile, horizontal on desktop.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = S.of(context);
    final isDesktop = PlatformHelper.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await Navigator.of(context).pushNamed(AppRoutes.settings);
            },
            tooltip: l10n.settings,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: AppSpacing.screenPadding,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppDimensions.contentMaxWidth,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App logo placeholder
                  Icon(
                    Icons.swap_horiz_rounded,
                    size: AppIconSize.logo,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.appTitle,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.appTagline,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.huge),

                  // Buttons - responsive layout
                  if (isDesktop)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSendButton(
                            context,
                            l10n,
                            isDesktop: true,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: _buildReceiveButton(
                            context,
                            l10n,
                            isDesktop: true,
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSendButton(context, l10n),
                        const SizedBox(height: AppSpacing.lg),
                        _buildReceiveButton(context, l10n),
                      ],
                    ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Info text
                  Text(
                    l10n.homeInfoText,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(
    BuildContext context,
    S l10n, {
    bool isDesktop = false,
  }) {
    return FilledButton.icon(
      onPressed: () async {
        if (!isDesktop) {
          await HapticFeedback.mediumImpact();
        }
        await Navigator.of(context).pushNamed(AppRoutes.senderFilePicker);
      },
      icon: Icon(
        Icons.send_rounded,
        size: isDesktop ? AppIconSize.lg : AppIconSize.md,
      ),
      label: Text(
        l10n.sendFile,
        style: TextStyle(
          fontSize: isDesktop ? AppFontSize.lg : AppFontSize.md,
        ),
      ),
      style: FilledButton.styleFrom(
        padding: isDesktop
            ? AppSpacing.buttonPaddingLarge
            : AppSpacing.buttonPaddingVertical,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
        ),
      ),
    );
  }

  Widget _buildReceiveButton(
    BuildContext context,
    S l10n, {
    bool isDesktop = false,
  }) {
    return FilledButton.tonalIcon(
      onPressed: () async {
        if (!isDesktop) {
          await HapticFeedback.mediumImpact();
        }
        await Navigator.of(context).pushNamed(AppRoutes.receiverCodeEntry);
      },
      icon: Icon(
        Icons.download_rounded,
        size: isDesktop ? AppIconSize.lg : AppIconSize.md,
      ),
      label: Text(
        l10n.receiveFile,
        style: TextStyle(
          fontSize: isDesktop ? AppFontSize.lg : AppFontSize.md,
        ),
      ),
      style: FilledButton.styleFrom(
        padding: isDesktop
            ? AppSpacing.buttonPaddingLarge
            : AppSpacing.buttonPaddingVertical,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
        ),
      ),
    );
  }
}
