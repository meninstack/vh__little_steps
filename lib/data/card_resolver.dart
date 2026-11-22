import 'card_catalog.dart';
import 'models.dart';

/// What the UI needs to draw and name a card, whichever kind it is.
class ResolvedCard {
  const ResolvedCard({
    required this.cardId,
    required this.label,
    this.asset,
    this.imageId,
    this.group,
  });

  final String cardId;
  final String label;

  /// Bundled artwork, set for built-in cards.
  final String? asset;

  /// Photo in the image store, set for parent-made cards.
  final String? imageId;

  /// Null for parent-made cards.
  final CardGroup? group;
}

/// Looks [cardId] up among the built-in and parent-made cards.
///
/// Deleting a parent-made card also removes it from every routine, so a miss
/// means damaged data; the caller still gets something drawable.
ResolvedCard resolveCard(AppData data, String cardId, String languageCode) {
  final builtIn = builtInCardsById[cardId];
  if (builtIn != null) {
    return ResolvedCard(
      cardId: cardId,
      label: builtIn.label(languageCode),
      asset: builtIn.asset,
      group: builtIn.group,
    );
  }
  final custom = data.customCardByCardId(cardId);
  if (custom != null) {
    return ResolvedCard(
      cardId: cardId,
      label: custom.label,
      imageId: custom.imageId,
    );
  }
  return ResolvedCard(cardId: cardId, label: '?');
}
