import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/routine_names.dart';
import '../../core/theme.dart';
import '../../data/card_catalog.dart';
import '../../data/card_resolver.dart';
import '../../data/models.dart';
import '../../data/routine_templates.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../../widgets/card_art.dart';
import 'custom_card_editor.dart';
import 'routine_editor_screen.dart';
import 'settings_tab.dart';

/// The grown-ups' side of the app, reached through the parental gate.
class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.parentTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.tabRoutines),
              Tab(text: l10n.tabMyCards),
              Tab(text: l10n.tabSettings),
            ],
          ),
        ),
        body: const SafeArea(
          child: TabBarView(
            children: [
              ParentPage(child: _RoutinesTab()),
              ParentPage(child: _MyCardsTab()),
              ParentPage(child: SettingsTab()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Keeps parent screens at a readable width on tablets.
class ParentPage extends StatelessWidget {
  const ParentPage({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: child,
      ),
    );
  }
}

class _RoutinesTab extends ConsumerWidget {
  const _RoutinesTab();

  void _open(BuildContext context, String routineId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoutineEditorScreen(routineId: routineId),
      ),
    );
  }

  Future<void> _addFromTemplate(BuildContext context, WidgetRef ref) async {
    final presetKey = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _TemplateSheet(),
    );
    if (presetKey == null || !context.mounted) return;
    final routineId = ref
        .read(appControllerProvider.notifier)
        .addRoutineFromTemplate(presetKey);
    if (routineId != null) _open(context, routineId);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final routines = ref.watch(
      appControllerProvider.select((data) => data.routines),
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final routine in routines)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(14, 6, 12, 6),
                leading: SvgPicture.asset(
                  routineIconAsset(routine.iconId),
                  width: 44,
                  height: 44,
                  excludeFromSemantics: true,
                ),
                title: Text(
                  routineDisplayName(routine, l10n),
                  style: theme.textTheme.titleMedium?.copyWith(fontSize: 18),
                ),
                subtitle: Text(l10n.taskCount(routine.items.length)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _open(context, routine.id),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            FilledButton.icon(
              onPressed: () => _open(
                context,
                ref.read(appControllerProvider.notifier).addRoutine(),
              ),
              icon: const Icon(Icons.add_rounded),
              label: Text(l10n.newRoutine),
            ),
            OutlinedButton.icon(
              onPressed: () => _addFromTemplate(context, ref),
              icon: const Icon(Icons.auto_awesome_rounded),
              label: Text(l10n.addFromTemplate),
            ),
          ],
        ),
      ],
    );
  }
}

/// Lists the ready-made routines and pops with the chosen one's preset key.
class _TemplateSheet extends StatelessWidget {
  const _TemplateSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.fromLTRB(8, 20, 8, 16),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(l10n.templatesTitle, style: theme.textTheme.titleLarge),
          ),
          for (final template in routineTemplates)
            ListTile(
              leading: SvgPicture.asset(
                routineIconAsset(template.iconId),
                width: 40,
                height: 40,
                excludeFromSemantics: true,
              ),
              title: Text(
                presetName(template.presetKey, l10n) ?? template.presetKey,
                style: theme.textTheme.titleMedium,
              ),
              subtitle: Text(
                [
                  for (final cardId in template.cardIds)
                    builtInCardsById[cardId]?.label(languageCode) ?? cardId,
                ].join(' · '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => Navigator.of(context).pop(template.presetKey),
            ),
        ],
      ),
    );
  }
}

class _MyCardsTab extends ConsumerWidget {
  const _MyCardsTab();

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    CustomCard card,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCard),
        content: Text(l10n.deleteCardConfirm(card.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appControllerProvider.notifier).deleteCustomCard(card.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cards = ref.watch(
      appControllerProvider.select((data) => data.customCards),
    );

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.myCardsEmpty,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.inkSoft,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) => const CustomCardEditor(),
                  ),
                  icon: const Icon(Icons.add_a_photo_rounded),
                  label: Text(l10n.newCard),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170,
              mainAxisExtent: 176,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: cards.length,
            itemBuilder: (context, index) {
              final card = cards[index];
              return Material(
                color: cardTint(null),
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 16, 10, 10),
                      child: Column(
                        children: [
                          Expanded(
                            child: Center(
                              child: CardArt(
                                card: ResolvedCard(
                                  cardId: card.cardId,
                                  label: card.label,
                                  imageId: card.imageId,
                                ),
                                size: 92,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            card.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: () => _confirmDelete(context, ref, card),
                        tooltip: l10n.deleteCard,
                        icon: const Icon(Icons.delete_outline_rounded),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
