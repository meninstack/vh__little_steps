import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/routine_names.dart';
import '../../core/theme.dart';
import '../../data/card_catalog.dart';
import '../../l10n/app_localizations.dart';
import '../../services/sound_service.dart';
import '../../state/app_controller.dart';
import '../../state/providers.dart';
import '../../widgets/pop_on_change.dart';

/// The animal friends a child has collected, and the ones still to meet,
/// one section for each [StickerSet].
class StickerBookScreen extends ConsumerStatefulWidget {
  const StickerBookScreen({super.key});

  @override
  ConsumerState<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends ConsumerState<StickerBookScreen> {
  /// Counts taps on each friend, so its picture pops on each one.
  final Map<String, int> _taps = {};

  void _play(Sticker sticker) {
    setState(() => _taps[sticker.id] = (_taps[sticker.id] ?? 0) + 1);
    if (!ref.read(appControllerProvider).soundEnabled) return;
    final note = noteNumberForSticker(stickers.indexOf(sticker));
    ref.read(soundServiceProvider).playNote(NoteSet.bell, note);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final data = ref.watch(appControllerProvider);
    final owned = data.stickers.toSet();

    Widget tile(Sticker sticker) {
      final has = owned.contains(sticker.id);
      final name = sticker.label(languageCode);
      return Material(
        color: has ? Colors.white : const Color(0xFFF3ECDD),
        borderRadius: BorderRadius.circular(24),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: has ? () => _play(sticker) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: PopOnChange(
                    trigger: _taps[sticker.id] ?? 0,
                    child: SvgPicture.asset(
                      sticker.asset,
                      excludeFromSemantics: true,
                      // A flat silhouette hints at the friend without giving
                      // the surprise away.
                      colorFilter: has
                          ? null
                          : const ColorFilter.mode(
                              Color(0xFFDCD3C0),
                              BlendMode.srcIn,
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  has ? name : '?',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  semanticsLabel: has ? name : l10n.stickerLocked,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: has ? AppColors.ink : AppColors.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.stickerBook)),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              sliver: SliverToBoxAdapter(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _Pill(
                      icon: Icons.star_rounded,
                      iconColor: AppColors.star,
                      text: l10n.totalStars(data.totalStars),
                    ),
                    _Pill(
                      icon: Icons.pets_rounded,
                      iconColor: AppColors.primary,
                      text: l10n.stickerBookProgress(
                        owned.length,
                        stickers.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            for (final group in StickerSet.values) ...[
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                sliver: SliverToBoxAdapter(
                  child: Semantics(
                    header: true,
                    child: Text(
                      stickerSetName(group, l10n),
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 150,
                    mainAxisExtent: 150,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: stickersIn(group).length,
                  itemBuilder: (context, index) =>
                      tile(stickersIn(group)[index]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.iconColor,
    required this.text,
  });

  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 26),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}
