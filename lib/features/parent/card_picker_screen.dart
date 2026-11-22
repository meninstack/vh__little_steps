import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/routine_names.dart';
import '../../core/theme.dart';
import '../../data/card_catalog.dart';
import '../../data/card_resolver.dart';
import '../../l10n/app_localizations.dart';
import '../../state/app_controller.dart';
import '../../widgets/card_art.dart';

/// Lets a parent tick the cards that belong on a routine.
///
/// Each tap takes effect at once, so there is nothing to confirm or lose.
class CardPickerScreen extends ConsumerWidget {
  const CardPickerScreen({super.key, required this.routineId});

  final String routineId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final data = ref.watch(appControllerProvider);
    final routine = data.routineById(routineId);
    final included = {
      for (final item in routine?.items ?? const []) item.cardId,
    };

    Widget grid(List<String> cardIds) => GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 150,
        mainAxisExtent: 150,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: cardIds.length,
      itemBuilder: (context, index) {
        final card = resolveCard(data, cardIds[index], languageCode);
        final selected = included.contains(card.cardId);
        return _PickerTile(
          card: card,
          selected: selected,
          onTap: () => ref
              .read(appControllerProvider.notifier)
              .setCardInRoutine(routineId, card.cardId, included: !selected),
        );
      },
    );

    return DefaultTabController(
      length: CardGroup.values.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.pickCards),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonDone),
              ),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              for (final group in CardGroup.values)
                Tab(text: cardGroupName(group, l10n)),
              Tab(text: l10n.groupCustom),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              for (final group in CardGroup.values)
                grid([for (final card in builtInCardsIn(group)) card.id]),
              if (data.customCards.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n.pickerNoCustomCards,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                )
              else
                grid([for (final card in data.customCards) card.cardId]),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.card,
    required this.selected,
    required this.onTap,
  });

  final ResolvedCard card;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      button: true,
      label: card.label,
      excludeSemantics: true,
      child: Material(
        color: cardTint(card.group),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 14, 10, 10),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(child: CardArt(card: card, size: 64)),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      height: 38,
                      child: Center(
                        child: Text(
                          card.label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            height: 1.2,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: AppColors.primary,
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
