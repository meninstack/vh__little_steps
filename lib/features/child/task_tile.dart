import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/card_resolver.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/card_art.dart';
import '../../widgets/pop_on_change.dart';

/// One task on the child's board.
///
/// Tapping the card plays its note and makes its picture pop; tapping the
/// star marks it done. The two actions are separate targets so that playing
/// with a card never completes the task by accident.
class TaskTile extends StatefulWidget {
  const TaskTile({
    super.key,
    required this.card,
    required this.order,
    required this.done,
    required this.compact,
    required this.onPlay,
    required this.onToggle,
  });

  final ResolvedCard card;

  /// Position in the routine, starting at 1.
  final int order;
  final bool done;

  /// A wide row for phones; otherwise a tall tile for the tablet grid.
  final bool compact;
  final VoidCallback onPlay;
  final VoidCallback onToggle;

  @override
  State<TaskTile> createState() => _TaskTileState();
}

class _TaskTileState extends State<TaskTile> {
  /// Counts taps on the card, so its picture pops on each one.
  int _plays = 0;

  void _play() {
    setState(() => _plays++);
    widget.onPlay();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final card = widget.card;
    final done = widget.done;
    final compact = widget.compact;

    final star = StarButton(
      done: done,
      onPressed: widget.onToggle,
      tooltip: done
          ? l10n.semanticMarkNotDone(card.label)
          : l10n.semanticMarkDone(card.label),
    );
    final label = Text(
      card.label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: compact ? TextAlign.start : TextAlign.center,
      style: theme.textTheme.titleLarge?.copyWith(
        fontSize: compact ? 22 : 19,
        height: 1.15,
      ),
    );

    Widget playArea(Widget body) => Semantics(
      button: true,
      label: card.label,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(25),
        onTap: _play,
        child: body,
      ),
    );

    if (compact) {
      return _TileSurface(
        card: card,
        done: done,
        child: Row(
          children: [
            Expanded(
              child: playArea(
                _CompactBody(
                  card: card,
                  order: widget.order,
                  plays: _plays,
                  label: label,
                ),
              ),
            ),
            Padding(padding: const EdgeInsets.only(right: 12), child: star),
          ],
        ),
      );
    }

    // In the grid the star hangs over the bottom edge of the card, so it
    // reads as a button and not as part of the picture.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          bottom: StarButton.size / 2,
          child: _TileSurface(
            card: card,
            done: done,
            child: playArea(
              _TallBody(
                card: card,
                order: widget.order,
                plays: _plays,
                label: label,
              ),
            ),
          ),
        ),
        Align(alignment: Alignment.bottomCenter, child: star),
      ],
    );
  }
}

class _TileSurface extends StatelessWidget {
  const _TileSurface({
    required this.card,
    required this.done,
    required this.child,
  });

  final ResolvedCard card;
  final bool done;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: done ? AppColors.doneSurface : cardTint(card.group),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: done ? AppColors.done : Colors.transparent,
          width: 3,
        ),
      ),
      child: Material(type: MaterialType.transparency, child: child),
    );
  }
}

class _CompactBody extends StatelessWidget {
  const _CompactBody({
    required this.card,
    required this.order,
    required this.plays,
    required this.label,
  });

  final ResolvedCard card;
  final int order;

  /// How many times the card has been tapped; the picture pops on each.
  final int plays;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
      child: Row(
        children: [
          _OrderBadge(order: order),
          const SizedBox(width: 10),
          PopOnChange(
            trigger: plays,
            child: CardArt(card: card, size: 68),
          ),
          const SizedBox(width: 14),
          Expanded(child: label),
        ],
      ),
    );
  }
}

class _TallBody extends StatelessWidget {
  const _TallBody({
    required this.card,
    required this.order,
    required this.plays,
    required this.label,
  });

  final ResolvedCard card;
  final int order;

  /// How many times the card has been tapped; the picture pops on each.
  final int plays;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Extra room at the bottom for the star that overlaps the edge.
      padding: const EdgeInsets.fromLTRB(12, 12, 12, StarButton.size / 2 + 6),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Center(
                    child: PopOnChange(
                      trigger: plays,
                      child: CardArt(
                        card: card,
                        size: constraints.biggest.shortestSide.clamp(40, 100),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(height: 46, child: Center(child: label)),
            ],
          ),
          Positioned(top: 0, left: 0, child: _OrderBadge(order: order)),
        ],
      ),
    );
  }
}

class _OrderBadge extends StatelessWidget {
  const _OrderBadge({required this.order});

  final int order;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$order',
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 16,
          color: AppColors.ink,
          height: 1,
        ),
      ),
    );
  }
}

/// The round star a child taps to finish a task. Pops when it turns gold.
class StarButton extends StatefulWidget {
  const StarButton({
    super.key,
    required this.done,
    required this.onPressed,
    required this.tooltip,
  });

  static const double size = 64;

  final bool done;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<StarButton> createState() => _StarButtonState();
}

class _StarButtonState extends State<StarButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 1.35,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1.35,
        end: 1,
      ).chain(CurveTween(curve: Curves.easeOutBack)),
      weight: 65,
    ),
  ]).animate(_controller);

  @override
  void didUpdateWidget(StarButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.done && !oldWidget.done) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.done;
    return ScaleTransition(
      scale: _scale,
      child: IconButton(
        onPressed: widget.onPressed,
        tooltip: widget.tooltip,
        iconSize: 44,
        style: IconButton.styleFrom(
          fixedSize: const Size.square(StarButton.size),
          backgroundColor: Colors.white,
          side: BorderSide(
            color: done ? AppColors.star : AppColors.outline,
            width: 3,
          ),
        ),
        icon: Icon(
          Icons.star_rounded,
          color: done ? AppColors.star : AppColors.starOff,
        ),
      ),
    );
  }
}
