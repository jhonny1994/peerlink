import 'package:flutter/material.dart';
import 'package:flutter_localized_locales/flutter_localized_locales.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:peerlink/src/src.dart';

/// Settings screen.
///
/// Allows users to customize app preferences including theme mode.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = S.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final supportedLocales = S.delegate.supportedLocales;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: SafeArea(
        child: ListView(
          padding: AppSpacing.screenPadding,
          children: [
            // Appearance Section
            _SectionHeader(l10n.appearance),
            Card(
              child: Column(
                children: [
                  // Theme Mode Selector
                  _ThemeTile(
                    title: l10n.themeLight,
                    subtitle: l10n.themeLightDesc,
                    icon: Icons.light_mode_rounded,
                    isSelected: themeMode == ThemeMode.light,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.light),
                  ),
                  const Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  _ThemeTile(
                    title: l10n.themeDark,
                    subtitle: l10n.themeDarkDesc,
                    icon: Icons.dark_mode_rounded,
                    isSelected: themeMode == ThemeMode.dark,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.dark),
                  ),
                  const Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  _ThemeTile(
                    title: l10n.themeSystem,
                    subtitle: l10n.themeSystemDesc,
                    icon: Icons.brightness_auto_rounded,
                    isSelected: themeMode == ThemeMode.system,
                    onTap: () => ref
                        .read(themeModeProvider.notifier)
                        .setThemeMode(ThemeMode.system),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Language Section
            _SectionHeader(l10n.language),
            Card(
              child: Column(
                children: [
                  // System Default
                  _LanguageTile(
                    title: l10n.languageSystem,
                    subtitle: l10n.languageSystemDesc,
                    icon: Icons.language_rounded,
                    isSelected: locale == null,
                    onTap: () =>
                        ref.read(localeProvider.notifier).setLocale(null),
                  ),
                  // Dynamic language tiles - automatically from ARB files
                  ...supportedLocales.expand((supportedLocale) {
                    final languageCode = supportedLocale.languageCode;
                    // Get native language name using flutter_localized_locales package
                    final nativeName =
                        LocaleNames.of(context)?.nameOf(languageCode) ??
                        LocaleNamesLocalizationsDelegate
                            .nativeLocaleNames[languageCode] ??
                        languageCode.toUpperCase();

                    return [
                      const Divider(
                        height: 1,
                        indent: AppSpacing.md,
                        endIndent: AppSpacing.md,
                      ),
                      _LanguageTile(
                        title: nativeName,
                        subtitle: languageCode.toUpperCase(),
                        icon: Icons.language_rounded,
                        isSelected: locale?.languageCode == languageCode,
                        onTap: () => ref
                            .read(localeProvider.notifier)
                            .setLocale(Locale(languageCode)),
                      ),
                    ];
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // About Section
            _SectionHeader(l10n.about),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: Text(l10n.appName),
                    subtitle: const Text('Version 1.0.0'),
                  ),
                  const Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(l10n.licenses),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppIconSize.xs,
                    ),
                    onTap: () {
                      showLicensePage(
                        context: context,
                        applicationName: l10n.appName,
                        applicationVersion: '1.0.0',
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Info Card
            InfoCard(text: l10n.settingsInfo),
          ],
        ),
      ),
    );
  }
}

/// Section header widget.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Theme selection tile widget.
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}

/// Language selection tile widget.
class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? colorScheme.primary : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle_rounded,
              color: colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}
