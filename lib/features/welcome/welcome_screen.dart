import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/routine_names.dart';
import '../../core/theme.dart';
import '../../data/card_catalog.dart';
import '../../data/routine_templates.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../../widgets/language_picker.dart';

/// Shown once, on a new installation: a grown-up picks the language and the
/// routines to start with. Everything chosen here can be changed later in
/// the parent area.
class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  /// Lets tests press the button whatever language the screen is in.
  static const Key startButtonKey = Key('welcome-start');

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final Set<String> _chosen = {...starterTemplateKeys};

  void _setChosen(String presetKey, bool chosen) {
    setState(() {
      if (chosen) {
        _chosen.add(presetKey);
      } else {
        _chosen.remove(presetKey);
      }
    });
  }

  void _start() {
    ref.read(appControllerProvider.notifier).finishOnboarding(_chosen);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final soft = theme.textTheme.bodyLarge?.copyWith(color: AppColors.inkSoft);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              l10n.appTitle,
                              style: theme.textTheme.headlineMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(l10n.welcomeIntro, style: soft),
                      const SizedBox(height: 24),
                      Text(
                        l10n.settingsLanguage,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      // Shrinks on a very narrow phone instead of overflowing.
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: LanguagePicker(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.welcomePickRoutines,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(l10n.welcomePickRoutinesHint, style: soft),
                      const SizedBox(height: 12),
                      for (final template in routineTemplates)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            clipBehavior: Clip.antiAlias,
                            child: CheckboxListTile(
                              value: _chosen.contains(template.presetKey),
                              onChanged: (chosen) => _setChosen(
                                template.presetKey,
                                chosen ?? false,
                              ),
                              secondary: SvgPicture.asset(
                                routineIconAsset(template.iconId),
                                width: 40,
                                height: 40,
                                excludeFromSemantics: true,
                              ),
                              title: Text(
                                presetName(template.presetKey, l10n) ??
                                    template.presetKey,
                                style: theme.textTheme.titleMedium,
                              ),
                              subtitle: Text(
                                l10n.taskCount(template.cardIds.length),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: FilledButton(
                    key: WelcomeScreen.startButtonKey,
                    onPressed: _chosen.isEmpty ? null : _start,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      textStyle: theme.textTheme.titleLarge,
                    ),
                    child: Text(l10n.welcomeStart),
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
