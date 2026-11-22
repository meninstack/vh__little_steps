import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/data/card_catalog.dart';
import 'package:little_steps/data/routine_templates.dart';

void main() {
  test('card, icon and sticker ids are unique', () {
    final cardIds = [for (final card in builtInCards) card.id];
    final stickerIds = [for (final sticker in stickers) sticker.id];

    expect(cardIds.toSet(), hasLength(cardIds.length));
    expect(routineIconIds.toSet(), hasLength(routineIconIds.length));
    expect(stickerIds.toSet(), hasLength(stickerIds.length));
  });

  test('every card, icon and sticker has its picture', () {
    final assets = [
      for (final card in builtInCards) card.asset,
      for (final iconId in routineIconIds) routineIconAsset(iconId),
      for (final sticker in stickers) sticker.asset,
    ];

    for (final asset in assets) {
      expect(File(asset).existsSync(), isTrue, reason: asset);
    }
  });

  test('every card group and sticker set has something in it', () {
    for (final group in CardGroup.values) {
      expect(builtInCardsIn(group), isNotEmpty, reason: group.name);
    }
    for (final group in StickerSet.values) {
      expect(stickersIn(group), isNotEmpty, reason: group.name);
    }
  });

  test('cards of one group sit together in the catalogue', () {
    // The card picker shows one tab per group, in catalogue order.
    final groupsInOrder = <CardGroup>[];
    for (final card in builtInCards) {
      if (groupsInOrder.isEmpty || groupsInOrder.last != card.group) {
        groupsInOrder.add(card.group);
      }
    }

    expect(groupsInOrder, CardGroup.values);
  });

  group('ready-made routines', () {
    test('have unique keys', () {
      final keys = [
        for (final template in routineTemplates) template.presetKey,
      ];

      expect(keys.toSet(), hasLength(keys.length));
    });

    test('only use cards and icons that exist', () {
      for (final template in routineTemplates) {
        expect(routineIconIds, contains(template.iconId));
        expect(template.cardIds, isNotEmpty);
        for (final cardId in template.cardIds) {
          expect(
            builtInCardsById,
            contains(cardId),
            reason: template.presetKey,
          );
        }
      }
    });

    test('include the routines a new installation starts with', () {
      for (final key in starterTemplateKeys) {
        expect(routineTemplatesByKey, contains(key));
      }
    });
  });
}
