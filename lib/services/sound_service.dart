import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

import '../data/card_catalog.dart';

/// The two instruments the app plays: wooden bars for cards, bells for
/// animal friends. Each has [notesPerSet] notes of one pentatonic scale, so
/// any sequence a child taps sounds pleasant.
enum NoteSet { wood, bell }

const int notesPerSet = 8;

/// The note a card always plays, from 1 to [notesPerSet].
///
/// Built-in cards walk up the scale in catalogue order. Parent-made cards get
/// a note from their id, so a card sounds the same every time it is tapped.
int noteNumberForCard(String cardId) {
  final index = builtInCards.indexWhere((card) => card.id == cardId);
  return (index >= 0 ? index : _stableHash(cardId)) % notesPerSet + 1;
}

/// The note the animal friend at [index] in the sticker book always plays.
int noteNumberForSticker(int index) => index % notesPerSet + 1;

/// `String.hashCode` may differ between runs and platforms; this does not.
int _stableHash(String text) {
  var hash = 0;
  for (final unit in text.codeUnits) {
    hash = (hash * 31 + unit) & 0x7fffffff;
  }
  return hash;
}

/// Plays the short sounds that answer a child's taps.
abstract interface class SoundService {
  /// Plays note [number] (1 to [notesPerSet]) of [set].
  Future<void> playNote(NoteSet set, int number);

  /// Plays the short tune for a finished routine.
  Future<void> playCelebration();
}

/// Plays the files in `assets/sounds/`, which `tool/make_notes.py` generates.
class AssetSoundService implements SoundService {
  /// Enough players for a child tapping several cards in quick succession
  /// without one note cutting the previous one short.
  static const int _voices = 4;

  final List<AudioPlayer> _players = [];
  int _next = 0;

  @override
  Future<void> playNote(NoteSet set, int number) =>
      _play('sounds/${set.name}/note_$number.wav');

  @override
  Future<void> playCelebration() => _play('sounds/celebrate.wav');

  Future<void> _play(String asset) async {
    try {
      if (_players.length < _voices) _players.add(AudioPlayer());
      final player = _players[_next % _players.length];
      _next++;
      await player.stop();
      await player.play(AssetSource(asset));
    } on Exception catch (error) {
      // A device that cannot play sound should stay usable; the picture and
      // the written name still carry the meaning.
      debugPrint('Sound failed: $error');
    }
  }
}

/// Plays nothing and remembers what was asked for. Used by tests.
class SilentSoundService implements SoundService {
  final List<String> played = [];

  @override
  Future<void> playNote(NoteSet set, int number) async {
    played.add('${set.name} $number');
  }

  @override
  Future<void> playCelebration() async {
    played.add('celebrate');
  }
}
