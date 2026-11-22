import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/app.dart';
import 'package:little_steps/data/models.dart';
import 'package:little_steps/features/welcome/welcome_screen.dart';
import 'package:little_steps/services/photo_picker.dart';
import 'package:little_steps/state/app_controller.dart';
import 'package:material_ui/material_ui.dart';

import 'support/harness.dart';

/// A valid 1×1 PNG, standing in for a photo from the camera.
final Uint8List tinyPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA'
  '60e6kgAAAABJRU5ErkJggg==',
);

AppData appState(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(LittleStepsApp)))
        .read(appControllerProvider);

void main() {
  late TestEnvironment environment;

  setUp(() => environment = TestEnvironment());

  group('welcome', () {
    testWidgets('a new installation chooses its routines first', (
      tester,
    ) async {
      await pumpApp(tester, environment, finishWelcome: false);

      expect(find.text('Choose routines to start with'), findsOneWidget);
      expect(find.text('Wake up'), findsNothing);

      await tester.tap(find.text('Evening'));
      await tester.ensureVisible(find.text('After school'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('After school'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(WelcomeScreen.startButtonKey));
      await tester.pumpAndSettle();

      final routines = appState(tester).routines;
      expect(appState(tester).onboardingDone, isTrue);
      expect(routines.map((r) => r.presetKey), ['morning', 'after_school']);
      expect(find.text('Wake up'), findsOneWidget);
      expect(find.text('After school'), findsOneWidget);
    });

    testWidgets('the start button waits until a routine is chosen', (
      tester,
    ) async {
      await pumpApp(tester, environment, finishWelcome: false);

      await tester.tap(find.text('Morning'));
      await tester.tap(find.text('Evening'));
      await tester.pumpAndSettle();

      final start = tester.widget<FilledButton>(
        find.byKey(WelcomeScreen.startButtonKey),
      );
      expect(start.onPressed, isNull);
    });

    testWidgets('a family already using the app goes straight to the board', (
      tester,
    ) async {
      environment = TestEnvironment(
        stored: const AppData(
          routines: [],
          progress: DayProgress(date: '2026-11-14'),
        ),
      );

      await pumpApp(tester, environment, finishWelcome: false);

      expect(find.text('Choose routines to start with'), findsNothing);
      expect(
        find.text('No routines yet. Ask a grown-up to make one!'),
        findsOneWidget,
      );
    });
  });

  group('child board', () {
    testWidgets('opens on the first routine with nothing done', (tester) async {
      await pumpApp(tester, environment);

      expect(find.text('Morning'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
      expect(find.text('Wake up'), findsOneWidget);
      // Once on the routine chip, once on the progress bar.
      expect(find.text('0 of 7'), findsNWidgets(2));
    });

    testWidgets('tapping a card plays its note', (tester) async {
      await pumpApp(tester, environment);

      await tester.tap(find.text('Brush teeth'));
      await tester.pump();

      // Brush teeth is the fourth built-in card.
      expect(environment.sounds.played, ['wood 4']);
      expect(appState(tester).totalStars, 0);
    });

    testWidgets('stays silent when sounds are switched off', (tester) async {
      await pumpApp(tester, environment);
      ProviderScope.containerOf(tester.element(find.byType(LittleStepsApp)))
          .read(appControllerProvider.notifier)
          .setSoundEnabled(false);

      await tester.tap(find.text('Brush teeth'));
      await tester.pump();

      expect(environment.sounds.played, isEmpty);
    });

    testWidgets('tapping a star marks the task done, tapping again undoes it', (
      tester,
    ) async {
      await pumpApp(tester, environment);

      await tester.tap(find.byTooltip('Mark Wake up as done'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Mark Wake up as not done'), findsOneWidget);
      expect(find.text('1 of 7'), findsNWidgets(2));

      await tester.tap(find.byTooltip('Mark Wake up as not done'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Mark Wake up as done'), findsOneWidget);
      expect(find.text('0 of 7'), findsNWidgets(2));
    });

    testWidgets('switching routine shows that routine\'s tasks', (
      tester,
    ) async {
      await pumpApp(tester, environment);

      await tester.tap(find.text('Evening'));
      await tester.pumpAndSettle();

      expect(find.text('Tidy up toys'), findsOneWidget);
      expect(find.text('Wake up'), findsNothing);
    });

    testWidgets('finishing a routine celebrates and adds a sticker', (
      tester,
    ) async {
      await pumpApp(tester, environment, size: tabletSize);
      final labels = [
        'Wake up',
        'Make the bed',
        'Brush teeth',
        'Wash face',
        'Get dressed',
        'Eat breakfast',
        'Pack my bag',
      ];

      for (final label in labels) {
        await tester.tap(find.byTooltip('Mark $label as done'));
        await tester.pump(const Duration(milliseconds: 500));
      }
      await tester.pumpAndSettle();

      expect(find.text('Great job!'), findsOneWidget);
      expect(
        find.text('A new friend joined your sticker book!'),
        findsOneWidget,
      );
      expect(environment.sounds.played.last, 'celebrate');

      await tester.tap(find.text('Yay!'));
      await tester.pumpAndSettle();

      expect(find.text('Great job!'), findsNothing);
      expect(appState(tester).stickers, hasLength(1));
      expect(find.text('7 of 7'), findsNWidgets(2));
    });

    testWidgets('the sticker book lists friends still to meet', (tester) async {
      await pumpApp(tester, environment);

      await tester.tap(find.byTooltip('Sticker book'));
      await tester.pumpAndSettle();

      expect(find.text('0 of 48 friends'), findsOneWidget);
      expect(find.text('Home and farm'), findsOneWidget);
      expect(find.text('No stars yet'), findsOneWidget);
      expect(find.text('?'), findsWidgets);
    });

    testWidgets('a new day gives a fresh board when the app comes back', (
      tester,
    ) async {
      await pumpApp(tester, environment);
      await tester.tap(find.byTooltip('Mark Wake up as done'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 7'), findsNWidgets(2));

      environment.now = DateTime(2026, 11, 15, 6, 45);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(find.text('0 of 7'), findsNWidgets(2));
      expect(appState(tester).totalStars, 1);
    });
  });

  group('layout', () {
    for (final (name, size) in [
      ('small phone', const Size(320, 568)),
      ('phone', phoneSize),
      ('phone on its side', const Size(844, 390)),
      ('small tablet upright', const Size(768, 1024)),
      ('tablet on its side', tabletSize),
    ]) {
      testWidgets('fits a $name without overflowing', (tester) async {
        // The test binding fails the test on any layout overflow.
        await pumpApp(tester, environment, size: size);
        expect(find.text('Wake up'), findsOneWidget);

        await tester.tap(find.byTooltip('Sticker book'));
        await tester.pumpAndSettle();
        expect(find.text('0 of 48 friends'), findsOneWidget);
        await tester.pageBack();
        await tester.pumpAndSettle();

        await openParentArea(tester);
        expect(find.text("Grown-ups' area"), findsOneWidget);
        await tester.tap(find.text('Morning'));
        await tester.pumpAndSettle();
        expect(find.text('Edit routine'), findsOneWidget);
        await tester.tap(find.text('Add cards'));
        await tester.pumpAndSettle();
        expect(find.text('Choose cards'), findsOneWidget);
      });
    }

    testWidgets('a phone on its side fits the celebration', (tester) async {
      await pumpApp(tester, environment, size: const Size(844, 390));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(LittleStepsApp)),
      );
      final routine = container.read(appControllerProvider).routines.first;
      for (final item in routine.items.skip(1)) {
        container
            .read(appControllerProvider.notifier)
            .toggleItem(routine.id, item.id);
      }
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Mark Wake up as done'));
      await tester.pumpAndSettle();

      expect(find.text('Great job!'), findsOneWidget);
    });
  });

  group('parental gate', () {
    testWidgets('a wrong answer keeps the parent area closed', (tester) async {
      await pumpApp(tester, environment);

      await tester.tap(find.byTooltip('Grown-ups'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Not quite. Try again.'), findsOneWidget);
      expect(find.text("Grown-ups' area"), findsNothing);
    });

    testWidgets('cancelling returns to the board', (tester) async {
      await pumpApp(tester, environment);

      await tester.tap(find.byTooltip('Grown-ups'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('For grown-ups'), findsNothing);
      expect(find.text('Wake up'), findsOneWidget);
    });

    testWidgets('the right answer opens the parent area', (tester) async {
      await pumpApp(tester, environment);

      await openParentArea(tester);

      expect(find.text("Grown-ups' area"), findsOneWidget);
      expect(find.text('7 tasks'), findsOneWidget);
    });
  });

  group('parent area', () {
    testWidgets('adds a card to a routine and it appears on the board', (
      tester,
    ) async {
      await pumpApp(tester, environment);
      await openParentArea(tester);

      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Drink milk'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      final morning = appState(tester).routines.first;
      expect(morning.items.last.cardId, 'drink_milk');
      expect(morning.items, hasLength(8));

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('0 of 8'), findsNWidgets(2));
    });

    testWidgets('unticking a card in the picker takes it off the routine', (
      tester,
    ) async {
      await pumpApp(tester, environment);
      await openParentArea(tester);

      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add cards'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Wake up'));
      await tester.pumpAndSettle();

      expect(
        appState(tester).routines.first.items.map((item) => item.cardId),
        isNot(contains('wake_up')),
      );
    });

    testWidgets('dragging a handle moves the task down the routine', (
      tester,
    ) async {
      await pumpApp(tester, environment);
      await openParentArea(tester);
      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();
      List<String> order() => [
        for (final item in appState(tester).routines.first.items) item.cardId,
      ];
      expect(order().take(3), ['wake_up', 'make_bed', 'brush_teeth']);

      // Each row is 70 px tall; drag the first one past the next two.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byIcon(Icons.drag_handle_rounded).first),
      );
      await tester.pump(const Duration(milliseconds: 100));
      for (var i = 0; i < 4; i++) {
        await gesture.moveBy(const Offset(0, 40));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(order().take(3), ['make_bed', 'brush_teeth', 'wake_up']);
    });

    testWidgets('removes a task with its close button', (tester) async {
      await pumpApp(tester, environment);
      await openParentArea(tester);
      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Remove').first);
      await tester.pumpAndSettle();

      expect(
        appState(tester).routines.first.items.map((item) => item.cardId),
        isNot(contains('wake_up')),
      );
      expect(appState(tester).routines.first.items, hasLength(6));
    });

    testWidgets('renames a routine', (tester) async {
      await pumpApp(tester, environment);
      await openParentArea(tester);

      await tester.tap(find.text('Morning'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Before school');
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.text('Before school'), findsOneWidget);
      expect(appState(tester).routines.first.name, 'Before school');
    });

    testWidgets('creates and deletes a routine', (tester) async {
      await pumpApp(tester, environment);
      await openParentArea(tester);

      await tester.tap(find.widgetWithText(FilledButton, 'New routine'));
      await tester.pumpAndSettle();
      expect(find.text('Edit routine'), findsOneWidget);
      expect(appState(tester).routines, hasLength(3));

      await tester.tap(find.byTooltip('Delete routine'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text("Grown-ups' area"), findsOneWidget);
      expect(appState(tester).routines, hasLength(2));
    });

    testWidgets('adds a ready-made routine and opens it', (tester) async {
      await pumpApp(tester, environment);
      await openParentArea(tester);

      await tester.tap(find.text('Add a ready-made routine'));
      await tester.pumpAndSettle();
      expect(find.text('Ready-made routines'), findsOneWidget);

      await tester.tap(find.text('Mealtime'));
      await tester.pumpAndSettle();

      expect(find.text('Edit routine'), findsOneWidget);
      final added = appState(tester).routines.last;
      expect(added.presetKey, 'mealtime');
      expect(added.items, hasLength(6));
    });

    testWidgets('makes a card from a photo and a name', (tester) async {
      await pumpApp(
        tester,
        environment,
        extraOverrides: [
          photoPickerProvider.overrideWithValue((source) async => tinyPng),
        ],
      );
      await openParentArea(tester);
      await tester.tap(find.text('My cards'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('New card'));
      await tester.pumpAndSettle();

      // Saving with nothing filled in explains what is missing.
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Add a photo first.'), findsOneWidget);

      await tester.tap(find.text('Choose photo'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a name.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Feed Mochi');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final card = appState(tester).customCards.single;
      expect(card.label, 'Feed Mochi');
      expect(await environment.images.load(card.imageId), tinyPng);
      expect(find.text('Feed Mochi'), findsOneWidget);
    });

    testWidgets('switching language translates the app at once', (
      tester,
    ) async {
      await pumpApp(tester, environment);
      await openParentArea(tester);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tiếng Việt'));
      await tester.pumpAndSettle();

      expect(find.text('Khu vực ba mẹ'), findsOneWidget);
      expect(appState(tester).localeCode, 'vi');
    });

    testWidgets('resetting today clears the stars on the board', (
      tester,
    ) async {
      await pumpApp(tester, environment);
      await tester.tap(find.byTooltip('Mark Wake up as done'));
      await tester.pumpAndSettle();
      await openParentArea(tester);
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      await tester.tap(find.text("Reset today's progress"));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text("Today's progress was reset."), findsOneWidget);
      expect(appState(tester).totalStars, 0);
    });
  });

  group('language', () {
    testWidgets('follows a Vietnamese device', (tester) async {
      tester.platformDispatcher.localesTestValue = const [Locale('vi', 'VN')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpApp(tester, environment);

      expect(find.text('Từng bước nhỏ'), findsOneWidget);
      expect(find.text('Buổi sáng'), findsOneWidget);
      expect(find.text('Đánh răng'), findsOneWidget);
    });

    testWidgets(
      'shows the whole Vietnamese name beside the board on a tablet',
      (tester) async {
        tester.platformDispatcher.localesTestValue = const [Locale('vi', 'VN')];
        addTearDown(tester.platformDispatcher.clearLocalesTestValue);

        await pumpApp(tester, environment, size: tabletSize);

        // The rail beside the board is narrow. The name shrinks to fit it
        // rather than ending in an ellipsis.
        final name = tester.renderObject<RenderParagraph>(
          find.text('Từng bước nhỏ'),
        );
        expect(name.didExceedMaxLines, isFalse);
      },
    );

    testWidgets('falls back to English on an unsupported device language', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ja', 'JP')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);

      await pumpApp(tester, environment);

      expect(find.text('Little Steps'), findsOneWidget);
      expect(find.text('Brush teeth'), findsOneWidget);
    });
  });
}
