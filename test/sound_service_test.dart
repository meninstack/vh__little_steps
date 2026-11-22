import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/data/card_catalog.dart';
import 'package:little_steps/data/models.dart';
import 'package:little_steps/services/sound_service.dart';

void main() {
  group('card notes', () {
    test('built-in cards walk up the scale in catalogue order', () {
      expect(noteNumberForCard('wake_up'), 1);
      expect(noteNumberForCard('make_bed'), 2);
      expect(noteNumberForCard('breakfast'), 8);
      expect(noteNumberForCard('drink_milk'), 1);
    });

    test('every built-in card gets a note that exists', () {
      for (final card in builtInCards) {
        expect(noteNumberForCard(card.id), inInclusiveRange(1, notesPerSet));
      }
    });

    test('a parent-made card keeps the same note on every run', () {
      // Fixed values: these must not change between runs or platforms, or a
      // child's own card would sound different after a restart.
      expect(noteNumberForCard('${customCardPrefix}abc'), 2);
      expect(noteNumberForCard('${customCardPrefix}k3x9'), 3);
    });
  });

  test('animal friends cycle through the notes', () {
    expect(noteNumberForSticker(0), 1);
    expect(noteNumberForSticker(7), 8);
    expect(noteNumberForSticker(8), 1);
    expect(noteNumberForSticker(stickers.length - 1), 8);
  });

  test('every sound the app can ask for is bundled', () {
    for (final set in NoteSet.values) {
      for (var number = 1; number <= notesPerSet; number++) {
        final path = 'assets/sounds/${set.name}/note_$number.wav';
        expect(File(path).existsSync(), isTrue, reason: path);
      }
    }
    expect(File('assets/sounds/celebrate.wav').existsSync(), isTrue);
  });
}
