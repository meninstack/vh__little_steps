import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../state/app_controller.dart';

/// Chooses the app's language: follow the device, Vietnamese or English.
class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key});

  static const String _system = 'system';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final localeCode = ref.watch(
      appControllerProvider.select((data) => data.localeCode),
    );

    return SegmentedButton<String>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: _system, label: Text(l10n.languageSystem)),
        // Language names stay in their own language so they can be found
        // whatever the app is currently set to.
        const ButtonSegment(value: 'vi', label: Text('Tiếng Việt')),
        const ButtonSegment(value: 'en', label: Text('English')),
      ],
      selected: {localeCode ?? _system},
      onSelectionChanged: (selection) {
        final choice = selection.first;
        ref
            .read(appControllerProvider.notifier)
            .setLocale(choice == _system ? null : choice);
      },
    );
  }
}
