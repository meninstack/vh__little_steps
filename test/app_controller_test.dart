import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/data/card_catalog.dart';
import 'package:little_steps/data/models.dart';
import 'package:little_steps/data/routine_templates.dart';
import 'package:little_steps/state/app_controller.dart';

import 'support/harness.dart';

void main() {
  late TestEnvironment environment;
  late ProviderContainer container;

  AppData state() => container.read(appControllerProvider);
  AppController controller() => container.read(appControllerProvider.notifier);

  void start({AppData? stored}) {
    environment = TestEnvironment(stored: stored);
    container = ProviderContainer.test(overrides: environment.overrides);
  }

  /// Taps every star of [routine] and returns the outcome of the last tap.
  ToggleOutcome finish(Routine routine) {
    late ToggleOutcome last;
    for (final item in routine.items) {
      last = controller().toggleItem(routine.id, item.id);
    }
    return last;
  }

  group('first launch', () {
    test('starts with a morning and an evening routine', () {
      start();

      expect(state().routines.map((r) => r.presetKey), ['morning', 'evening']);
      expect(state().routines.first.items, isNotEmpty);
      expect(state().progress.date, '2026-11-14');
      expect(state().totalStars, 0);
      expect(state().stickers, isEmpty);
    });

    test('opens on the welcome screen until it is finished', () {
      start();

      expect(state().onboardingDone, isFalse);
    });

    test('the welcome keeps the chosen routines and adds new ones', () {
      start();
      final morning = state().routines.first;

      controller().finishOnboarding({'bedtime', 'morning'});

      expect(state().onboardingDone, isTrue);
      expect(state().routines.map((r) => r.presetKey), ['morning', 'bedtime']);
      expect(state().routines.first.id, morning.id);
      expect(state().routines.last.items, isNotEmpty);
    });

    test('starter routines only use cards that exist', () {
      start();

      for (final routine in state().routines) {
        for (final item in routine.items) {
          expect(builtInCardsById, contains(item.cardId));
        }
      }
    });
  });

  group('finishing tasks', () {
    test('a tap marks the task done and earns a star', () {
      start();
      final routine = state().routines.first;
      final item = routine.items.first;

      final outcome = controller().toggleItem(routine.id, item.id);

      expect(outcome.nowDone, isTrue);
      expect(outcome.routineFinished, isFalse);
      expect(state().isDone(routine.id, item.id), isTrue);
      expect(state().doneCount(routine), 1);
      expect(state().totalStars, 1);
    });

    test('a second tap undoes the task and takes the star back', () {
      start();
      final routine = state().routines.first;
      final item = routine.items.first;
      controller().toggleItem(routine.id, item.id);

      final outcome = controller().toggleItem(routine.id, item.id);

      expect(outcome.nowDone, isFalse);
      expect(state().isDone(routine.id, item.id), isFalse);
      expect(state().totalStars, 0);
    });

    test('finishing a routine gives one new sticker', () {
      start();
      final routine = state().routines.first;

      final outcome = finish(routine);

      expect(outcome.routineFinished, isTrue);
      expect(stickersById, contains(outcome.newStickerId));
      expect(state().stickers, [outcome.newStickerId]);
      expect(state().totalStars, routine.items.length);
    });

    test('undoing and redoing a task does not give a second sticker', () {
      start();
      final routine = state().routines.first;
      finish(routine);
      final lastItem = routine.items.last;

      controller().toggleItem(routine.id, lastItem.id);
      final again = controller().toggleItem(routine.id, lastItem.id);

      expect(again.nowDone, isTrue);
      expect(again.routineFinished, isFalse);
      expect(state().stickers, hasLength(1));
    });

    test('each routine gives its own sticker, never a duplicate', () {
      start();
      final morning = state().routines[0];
      final evening = state().routines[1];

      finish(morning);
      finish(evening);

      expect(state().stickers, hasLength(2));
      expect(state().stickers.toSet(), hasLength(2));
    });

    test('still celebrates when every sticker is already owned', () {
      start();
      final seeded = state().copyWith(
        stickers: [for (final sticker in stickers) sticker.id],
      );
      start(stored: seeded);
      final routine = state().routines.first;

      final outcome = finish(routine);

      expect(outcome.routineFinished, isTrue);
      expect(outcome.newStickerId, isNull);
      expect(state().stickers, hasLength(stickers.length));
    });

    test('ignores a task that is not on the routine', () {
      start();
      final routine = state().routines.first;

      final outcome = controller().toggleItem(routine.id, 'no-such-item');

      expect(outcome.nowDone, isFalse);
      expect(state().totalStars, 0);
    });
  });

  group('a new day', () {
    test('clears the board but keeps stars and stickers', () {
      start();
      final routine = state().routines.first;
      finish(routine);

      environment.now = DateTime(2026, 11, 15, 6);
      controller().refreshDay();

      expect(state().progress.date, '2026-11-15');
      expect(state().doneCount(routine), 0);
      expect(state().totalStars, routine.items.length);
      expect(state().stickers, hasLength(1));
    });

    test('the same routine can win a sticker again the next day', () {
      start();
      final routine = state().routines.first;
      finish(routine);

      environment.now = DateTime(2026, 11, 15, 6);
      final outcome = finish(routine);

      expect(outcome.routineFinished, isTrue);
      expect(state().stickers, hasLength(2));
    });

    test('progress saved on an earlier day is not shown at launch', () {
      start();
      final routine = state().routines.first;
      controller().toggleItem(routine.id, routine.items.first.id);
      final saved = environment.repository.stored!;

      environment = TestEnvironment(
        stored: saved,
        now: DateTime(2026, 11, 16, 8),
      );
      container = ProviderContainer.test(overrides: environment.overrides);

      expect(state().progress.date, '2026-11-16');
      expect(state().doneCount(state().routines.first), 0);
      expect(state().totalStars, 1);
    });

    test('staying on the same day changes nothing', () {
      start();
      final routine = state().routines.first;
      controller().toggleItem(routine.id, routine.items.first.id);
      final saves = environment.repository.saveCount;

      environment.now = DateTime(2026, 11, 14, 23, 59);
      controller().refreshDay();

      expect(state().doneCount(routine), 1);
      expect(environment.repository.saveCount, saves);
    });
  });

  group('editing routines', () {
    test('a new routine is empty and unnamed', () {
      start();

      final id = controller().addRoutine();

      final routine = state().routineById(id)!;
      expect(routine.name, isEmpty);
      expect(routine.presetKey, isNull);
      expect(routine.items, isEmpty);
      expect(state().routines, hasLength(3));
    });

    test('a ready-made routine arrives with its cards', () {
      start();

      final id = controller().addRoutineFromTemplate('mealtime')!;

      final routine = state().routineById(id)!;
      expect(routine.name, isEmpty);
      expect(routine.presetKey, 'mealtime');
      expect(routine.iconId, 'meal');
      expect([
        for (final item in routine.items) item.cardId,
      ], routineTemplatesByKey['mealtime']!.cardIds);
      expect(state().routines, hasLength(3));
    });

    test('an unknown ready-made routine adds nothing', () {
      start();

      expect(controller().addRoutineFromTemplate('no-such-routine'), isNull);
      expect(state().routines, hasLength(2));
    });

    test('renames and changes the icon', () {
      start();
      final id = state().routines.first.id;

      controller().renameRoutine(id, 'Before school');
      controller().setRoutineIcon(id, 'rocket');

      expect(state().routineById(id)!.name, 'Before school');
      expect(state().routineById(id)!.iconId, 'rocket');
    });

    test('adds a card at the end and removes it again', () {
      start();
      final id = state().routines.first.id;
      final before = state().routineById(id)!.items.length;

      controller().setCardInRoutine(id, 'drink_water', included: true);
      expect(state().routineById(id)!.items.last.cardId, 'drink_water');
      expect(state().routineById(id)!.items, hasLength(before + 1));

      // Asking again for a card that is already there adds nothing.
      controller().setCardInRoutine(id, 'drink_water', included: true);
      expect(state().routineById(id)!.items, hasLength(before + 1));

      controller().setCardInRoutine(id, 'drink_water', included: false);
      expect(state().routineById(id)!.items, hasLength(before));
    });

    test('moves a task to a new position', () {
      start();
      final id = state().routines.first.id;
      List<String> order() => [
        for (final item in state().routineById(id)!.items) item.cardId,
      ];
      final original = order();

      controller().moveItem(id, 0, 2);

      expect(order(), [
        original[1],
        original[2],
        original[0],
        ...original.skip(3),
      ]);

      controller().moveItem(id, 2, 0);
      expect(order(), original);
    });

    test('ignores a move outside the list', () {
      start();
      final id = state().routines.first.id;
      final before = state().routineById(id)!.items;

      controller().moveItem(id, 0, 99);
      controller().moveItem(id, -1, 0);

      expect(state().routineById(id)!.items, before);
    });

    test('removes a single task', () {
      start();
      final routine = state().routines.first;
      final removed = routine.items[1];

      controller().removeItem(routine.id, removed.id);

      expect(
        state().routineById(routine.id)!.items.map((item) => item.id),
        isNot(contains(removed.id)),
      );
    });

    test('deleting a routine also drops its progress', () {
      start();
      final routine = state().routines.first;
      controller().toggleItem(routine.id, routine.items.first.id);

      controller().deleteRoutine(routine.id);

      expect(state().routineById(routine.id), isNull);
      expect(state().progress.done, isNot(contains(routine.id)));
    });
  });

  group('parent-made cards', () {
    final photo = Uint8List.fromList([1, 2, 3]);

    test('stores the photo and adds the card', () async {
      start();

      await controller().addCustomCard(label: 'Feed Mochi', imageBytes: photo);

      final card = state().customCards.single;
      expect(card.label, 'Feed Mochi');
      expect(await environment.images.load(card.imageId), photo);
    });

    test(
      'deleting a card removes it from routines and deletes the photo',
      () async {
        start();
        await controller().addCustomCard(
          label: 'Feed Mochi',
          imageBytes: photo,
        );
        final card = state().customCards.single;
        final routineId = state().routines.first.id;
        controller().setCardInRoutine(routineId, card.cardId, included: true);

        await controller().deleteCustomCard(card.id);

        expect(state().customCards, isEmpty);
        expect(
          state().routineById(routineId)!.items.map((item) => item.cardId),
          isNot(contains(card.cardId)),
        );
        expect(await environment.images.load(card.imageId), isNull);
      },
    );
  });

  group('settings', () {
    test('reset clears today and takes back today\'s stars only', () {
      start();
      final morning = state().routines[0];
      finish(morning);
      environment.now = DateTime(2026, 11, 15, 7);
      controller().toggleItem(morning.id, morning.items.first.id);
      expect(state().totalStars, morning.items.length + 1);

      controller().resetToday();

      expect(state().doneCount(morning), 0);
      expect(state().totalStars, morning.items.length);
      expect(state().stickers, hasLength(1));
    });

    test('language can be forced and returned to the device setting', () {
      start();

      controller().setLocale('vi');
      expect(state().localeCode, 'vi');

      controller().setLocale(null);
      expect(state().localeCode, isNull);
    });
  });

  group('saving', () {
    test('data saved before the welcome screen existed skips it', () {
      start();
      final saved =
          jsonDecode(jsonEncode(state().toJson())) as Map<String, dynamic>
            ..remove('onboardingDone');

      expect(AppData.fromJson(saved).onboardingDone, isTrue);
    });

    test('every change is written, and survives a JSON round trip', () async {
      start();
      final routine = state().routines.first;
      controller().toggleItem(routine.id, routine.items.first.id);
      controller().renameRoutine(routine.id, 'Sáng');
      controller().setLocale('vi');
      controller().setSoundEnabled(false);
      await controller().addCustomCard(
        label: 'Cho mèo ăn',
        imageBytes: Uint8List.fromList([9]),
      );

      final saved = environment.repository.stored!;
      final restored = AppData.fromJson(
        jsonDecode(jsonEncode(saved.toJson())) as Map<String, dynamic>,
      );

      expect(jsonEncode(restored.toJson()), jsonEncode(state().toJson()));
      expect(restored.routines.first.name, 'Sáng');
      expect(restored.isDone(routine.id, routine.items.first.id), isTrue);
      expect(restored.localeCode, 'vi');
      expect(restored.soundEnabled, isFalse);
      expect(restored.customCards.single.label, 'Cho mèo ăn');
    });
  });
}
