import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  static const String _systemLanguage = 'system';

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsResetToday),
        content: Text(l10n.settingsResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonContinue),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    ref.read(appControllerProvider.notifier).resetToday();
    messenger.showSnackBar(SnackBar(content: Text(l10n.settingsResetDone)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(appControllerProvider.notifier);
    final localeCode = ref.watch(
      appControllerProvider.select((data) => data.localeCode),
    );
    final soundEnabled = ref.watch(
      appControllerProvider.select((data) => data.soundEnabled),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Panel(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                l10n.settingsLanguage,
                style: theme.textTheme.titleMedium,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: _systemLanguage,
                      label: Text(l10n.languageSystem),
                    ),
                    // Language names stay in their own language so they can
                    // be found whatever the app is currently set to.
                    const ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
                    const ButtonSegment(value: 'en', label: Text('English')),
                  ],
                  selected: {localeCode ?? _systemLanguage},
                  onSelectionChanged: (selection) => controller.setLocale(
                    selection.first == _systemLanguage ? null : selection.first,
                  ),
                ),
              ),
            ),
          ],
        ),
        _Panel(
          children: [
            SwitchListTile(
              title: Text(l10n.settingsSound),
              secondary: const Icon(Icons.volume_up_rounded),
              value: soundEnabled,
              onChanged: controller.setSoundEnabled,
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded),
              title: Text(l10n.settingsResetToday),
              onTap: () => _confirmReset(context, ref),
            ),
          ],
        ),
        _Panel(
          children: [
            ListTile(
              leading: const Icon(Icons.shield_outlined),
              title: Text(l10n.settingsPrivacyTitle),
              subtitle: Text(l10n.settingsPrivacyBody),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.settingsLicenses),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => showLicensePage(
                context: context,
                applicationName: l10n.appTitle,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
