import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:little_steps/app.dart';
import 'package:little_steps/core/id_generator.dart';
import 'package:little_steps/data/app_repository.dart';
import 'package:little_steps/data/image_store.dart';
import 'package:little_steps/data/models.dart';
import 'package:little_steps/features/welcome/welcome_screen.dart';
import 'package:little_steps/services/sound_service.dart';
import 'package:little_steps/state/providers.dart';
import 'package:material_ui/material_ui.dart';

/// Keeps the saved document in memory so tests can inspect what was written.
class MemoryAppRepository implements AppRepository {
  MemoryAppRepository([this.stored]);

  AppData? stored;
  int saveCount = 0;

  @override
  AppData? load() => stored;

  @override
  Future<void> save(AppData data) async {
    stored = data;
    saveCount++;
  }
}

/// The fakes behind one test, plus the overrides that install them.
class TestEnvironment {
  TestEnvironment({AppData? stored, DateTime? now, this.defaultLocaleCode})
    : repository = MemoryAppRepository(stored),
      now = now ?? DateTime(2026, 11, 14, 7, 30);

  final MemoryAppRepository repository;
  final SilentSoundService sounds = SilentSoundService();
  final MemoryImageStore images = MemoryImageStore();

  /// The language of a new installation. Null, unlike in the real app, so
  /// that tests follow the test device and read in English.
  final String? defaultLocaleCode;

  /// Change this to move the app to another time or day.
  DateTime now;

  List<Override> get overrides => [
    appRepositoryProvider.overrideWithValue(repository),
    soundServiceProvider.overrideWithValue(sounds),
    imageStoreProvider.overrideWithValue(images),
    clockProvider.overrideWithValue(() => now),
    defaultLocaleCodeProvider.overrideWithValue(defaultLocaleCode),
    randomProvider.overrideWithValue(Random(1)),
    idGeneratorProvider.overrideWithValue(IdGenerator(Random(2))),
  ];
}

const Size phoneSize = Size(390, 844);
const Size tabletSize = Size(1180, 820);

/// Starts the whole app on a screen of [size] and waits for it to settle.
///
/// A new installation opens on the welcome screen. Most tests are about what
/// comes after it, so it is accepted as it stands unless [finishWelcome] is
/// false.
Future<void> pumpApp(
  WidgetTester tester,
  TestEnvironment environment, {
  Size size = phoneSize,
  List<Override> extraOverrides = const [],
  bool finishWelcome = true,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [...environment.overrides, ...extraOverrides],
      child: const LittleStepsApp(),
    ),
  );
  await tester.pumpAndSettle();

  final start = find.byKey(WelcomeScreen.startButtonKey);
  if (finishWelcome && start.evaluate().isNotEmpty) {
    await tester.tap(start);
    await tester.pumpAndSettle();
  }
}

/// Answers the multiplication question and lands in the parent area.
Future<void> openParentArea(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Grown-ups'));
  await tester.pumpAndSettle();

  final question = tester.widget<Text>(find.textContaining('×')).data!;
  final numbers = RegExp(r'\d+').allMatches(question).map((m) => m[0]!);
  final answer = numbers.map(int.parse).reduce((a, b) => a * b);

  await tester.enterText(find.byType(TextField), '$answer');
  await tester.tap(find.text('Continue'));
  await tester.pumpAndSettle();
}
