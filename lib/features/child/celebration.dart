import 'dart:math';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme.dart';
import '../../data/card_catalog.dart';
import '../../l10n/app_localizations.dart';

/// Shows the full-screen reward for finishing a routine.
///
/// [newStickerId] is the animal friend just won, or null when the child
/// already owns every sticker.
Future<void> showCelebration(BuildContext context, {String? newStickerId}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0xB32B2D42),
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, _, _) =>
        CelebrationView(sticker: stickersById[newStickerId]),
  );
}

class CelebrationView extends StatefulWidget {
  const CelebrationView({super.key, this.sticker});

  final Sticker? sticker;

  @override
  State<CelebrationView> createState() => _CelebrationViewState();
}

class _CelebrationViewState extends State<CelebrationView>
    with SingleTickerProviderStateMixin {
  // Runs once and stops, so the screen comes to rest for people who are
  // sensitive to motion, and for widget tests.
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..forward();

  late final Animation<double> _popIn = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.22, curve: Curves.easeOutBack),
  );

  /// The new friend bounces in a moment after the card it sits on.
  late final Animation<double> _friendIn = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.1, 0.45, curve: Curves.elasticOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final sticker = widget.sticker;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ConfettiPainter(_controller)),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ScaleTransition(
                scale: _popIn,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 380),
                  padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (sticker != null)
                        Container(
                          width: 168,
                          height: 168,
                          padding: const EdgeInsets.all(26),
                          decoration: const BoxDecoration(
                            color: Color(0xFFFFF1C9),
                            shape: BoxShape.circle,
                          ),
                          child: ScaleTransition(
                            scale: _friendIn,
                            child: SvgPicture.asset(
                              sticker.asset,
                              excludeFromSemantics: true,
                            ),
                          ),
                        )
                      else
                        const Icon(
                          Icons.star_rounded,
                          size: 150,
                          color: AppColors.star,
                        ),
                      if (sticker != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          sticker.label(languageCode),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      Text(
                        l10n.celebrateTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontSize: 34,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l10n.celebrateBody,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        sticker != null
                            ? l10n.celebrateNewSticker
                            : l10n.celebrateAllCollected,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.inkSoft,
                        ),
                      ),
                      const SizedBox(height: 22),
                      FilledButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(200, 60),
                          textStyle: theme.textTheme.titleLarge,
                        ),
                        child: Text(l10n.celebrateButton),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiPiece {
  _ConfettiPiece(Random random)
    : x = random.nextDouble(),
      delay = random.nextDouble() * 0.45,
      sway = 12 + random.nextDouble() * 28,
      swayTurns = 1 + random.nextDouble() * 2,
      spin = (random.nextDouble() - 0.5) * 14,
      width = 8 + random.nextDouble() * 8,
      height = 10 + random.nextDouble() * 10,
      color = _colors[random.nextInt(_colors.length)];

  static const List<Color> _colors = [
    Color(0xFFFFB703),
    Color(0xFFFF6B6B),
    Color(0xFF4F6DF5),
    Color(0xFF2EB67D),
    Color(0xFFB57BFF),
    Color(0xFF3CC8F4),
  ];

  /// Horizontal start position as a fraction of the width.
  final double x;

  /// Fraction of the animation to wait before this piece starts falling.
  final double delay;
  final double sway;
  final double swayTurns;
  final double spin;
  final double width;
  final double height;
  final Color color;
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress) : super(repaint: progress);

  final Animation<double> progress;

  // A fixed seed keeps the shower identical on every run.
  static final List<_ConfettiPiece> _pieces = () {
    final random = Random(7);
    return List.generate(90, (_) => _ConfettiPiece(random));
  }();

  static const double _fallFraction = 0.55;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in _pieces) {
      final t = ((progress.value - piece.delay) / _fallFraction).clamp(
        0.0,
        1.0,
      );
      if (t <= 0 || t >= 1) continue;

      final dx =
          piece.x * size.width + sin(t * piece.swayTurns * 2 * pi) * piece.sway;
      final dy = -20 + t * (size.height + 40);
      paint.color = piece.color;

      canvas
        ..save()
        ..translate(dx, dy)
        ..rotate(t * piece.spin)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: piece.width,
              height: piece.height,
            ),
            const Radius.circular(3),
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
