import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/routine_names.dart';
import '../../core/theme.dart';
import '../../data/card_catalog.dart';
import '../../data/card_resolver.dart';
import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../../services/sound_service.dart';
import '../../state/app_controller.dart';
import '../../state/providers.dart';
import '../parent/parent_home_screen.dart';
import '../parent/parental_gate.dart';
import 'celebration.dart';
import 'sticker_book_screen.dart';
import 'task_tile.dart';

/// The child's board: pick a routine, tap a task to hear its note, tap its
/// star when done.
class ChildHomeScreen extends ConsumerStatefulWidget {
  const ChildHomeScreen({super.key});

  @override
  ConsumerState<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends ConsumerState<ChildHomeScreen> {
  String? _selectedRoutineId;

  /// The chosen routine, or the first one when nothing is chosen yet or the
  /// chosen one was deleted in the parent area.
  Routine? _selected(AppData data) =>
      data.routineById(_selectedRoutineId ?? '') ?? data.routines.firstOrNull;

  /// Null while sounds are switched off in the parent area.
  SoundService? get _sounds => ref.read(appControllerProvider).soundEnabled
      ? ref.read(soundServiceProvider)
      : null;

  void _playCard(String cardId) {
    _sounds?.playNote(NoteSet.wood, noteNumberForCard(cardId));
  }

  void _toggle(Routine routine, RoutineItem item) {
    final outcome = ref
        .read(appControllerProvider.notifier)
        .toggleItem(routine.id, item.id);
    if (outcome.nowDone) HapticFeedback.mediumImpact();
    if (outcome.routineFinished) {
      _sounds?.playCelebration();
      showCelebration(context, newStickerId: outcome.newStickerId);
    }
  }

  Future<void> _openParentArea() async {
    final passed = await showParentalGate(context, ref.read(randomProvider));
    if (!passed || !mounted) return;
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const ParentHomeScreen()));
  }

  void _openStickerBook() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const StickerBookScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appControllerProvider);
    final routine = _selected(data);

    Widget routineList(Axis axis) => _RoutineList(
      axis: axis,
      data: data,
      selectedId: routine?.id,
      onSelected: (id) => setState(() => _selectedRoutineId = id),
    );

    final actions = _HeaderActions(
      stickerCount: data.stickers.length,
      onStickerBook: _openStickerBook,
      onParentArea: _openParentArea,
    );

    final board = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (routine != null && routine.items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: _ProgressBar(
              done: data.doneCount(routine),
              total: routine.items.length,
            ),
          ),
        Expanded(
          child: _TaskBoard(
            data: data,
            routine: routine,
            onPlay: _playCard,
            onToggle: _toggle,
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= Breakpoints.rail) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 232,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(20, 16, 12, 12),
                          child: _Brand(),
                        ),
                        Expanded(child: routineList(Axis.vertical)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: actions,
                          ),
                        ),
                        Expanded(child: board),
                      ],
                    ),
                  ),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
                  child: Row(
                    children: [
                      const Expanded(child: _Brand()),
                      actions,
                    ],
                  ),
                ),
                if (data.routines.isNotEmpty)
                  SizedBox(height: 72, child: routineList(Axis.horizontal)),
                const SizedBox(height: 8),
                Expanded(child: board),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 10),
        // The name is never cut short. Where there is too little room for it,
        // on the tablet rail or a small phone, it shrinks to fit.
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              AppLocalizations.of(context).appTitle,
              maxLines: 1,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderActions extends StatelessWidget {
  const _HeaderActions({
    required this.stickerCount,
    required this.onStickerBook,
    required this.onParentArea,
  });

  final int stickerCount;
  final VoidCallback onStickerBook;
  final VoidCallback onParentArea;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          button: true,
          label: l10n.stickerBook,
          value: '$stickerCount',
          onTap: onStickerBook,
          excludeSemantics: true,
          child: Tooltip(
            message: l10n.stickerBook,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onStickerBook,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pets_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$stickerCount',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 4),
        // Deliberately plain: nothing here should invite a child to tap.
        IconButton(
          onPressed: onParentArea,
          tooltip: l10n.parentArea,
          iconSize: 26,
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          color: AppColors.inkSoft,
          icon: const Icon(Icons.lock_outline_rounded),
        ),
      ],
    );
  }
}

class _RoutineList extends StatelessWidget {
  const _RoutineList({
    required this.axis,
    required this.data,
    required this.selectedId,
    required this.onSelected,
  });

  final Axis axis;
  final AppData data;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final horizontal = axis == Axis.horizontal;
    return ListView.separated(
      scrollDirection: axis,
      padding: horizontal
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
          : const EdgeInsets.fromLTRB(16, 4, 8, 16),
      itemCount: data.routines.length,
      separatorBuilder: (_, _) => const SizedBox.square(dimension: 10),
      itemBuilder: (context, index) {
        final routine = data.routines[index];
        final selected = routine.id == selectedId;
        final foreground = selected ? Colors.white : AppColors.ink;
        return Semantics(
          selected: selected,
          button: true,
          child: Material(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => onSelected(routine.id),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 18, 10),
                child: Row(
                  mainAxisSize: horizontal
                      ? MainAxisSize.min
                      : MainAxisSize.max,
                  children: [
                    SvgPicture.asset(
                      routineIconAsset(routine.iconId),
                      width: 40,
                      height: 40,
                      excludeFromSemantics: true,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            routineDisplayName(routine, l10n),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              height: 1.2,
                              color: foreground,
                            ),
                          ),
                          Text(
                            l10n.progressLabel(
                              data.doneCount(routine),
                              routine.items.length,
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              height: 1.2,
                              color: foreground.withValues(alpha: 0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: AppColors.star, size: 30),
          const SizedBox(width: 6),
          Text(
            l10n.progressLabel(done, total),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: total == 0 ? 0 : done / total),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 16,
                  color: AppColors.star,
                  backgroundColor: AppColors.starOff,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskBoard extends StatelessWidget {
  const _TaskBoard({
    required this.data,
    required this.routine,
    required this.onPlay,
    required this.onToggle,
  });

  final AppData data;
  final Routine? routine;

  /// Called with the id of the tapped card.
  final ValueChanged<String> onPlay;
  final void Function(Routine routine, RoutineItem item) onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final routine = this.routine;

    if (routine == null) return _EmptyBoard(message: l10n.childNoRoutines);
    if (routine.items.isEmpty) {
      return _EmptyBoard(message: l10n.childEmptyRoutine);
    }

    TaskTile tile(int index, {required bool compact}) {
      final item = routine.items[index];
      final card = resolveCard(data, item.cardId, languageCode);
      return TaskTile(
        key: ValueKey(item.id),
        card: card,
        order: index + 1,
        done: data.isDone(routine.id, item.id),
        compact: compact,
        onPlay: () => onPlay(card.cardId),
        onToggle: () => onToggle(routine, item),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= Breakpoints.grid;
        // Tall tiles need room; a phone on its side gets rows instead.
        final tall = wide && constraints.maxHeight >= 420;

        if (tall) {
          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 230,
              mainAxisExtent: 252,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: routine.items.length,
            itemBuilder: (context, index) => tile(index, compact: false),
          );
        }
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: wide ? 2 : 1,
            mainAxisExtent: 100,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: routine.items.length,
          itemBuilder: (context, index) => tile(index, compact: true),
        );
      },
    );
  }
}

class _EmptyBoard extends StatelessWidget {
  const _EmptyBoard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              size: 64,
              color: AppColors.star,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
