import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/clock.dart';
import '../data/card_catalog.dart';
import '../data/models.dart';
import '../data/routine_templates.dart';
import 'providers.dart';

final appControllerProvider = NotifierProvider<AppController, AppData>(
  AppController.new,
);

/// What happened when a child tapped a task's star.
@immutable
class ToggleOutcome {
  const ToggleOutcome({
    required this.nowDone,
    this.routineFinished = false,
    this.newStickerId,
  });

  /// Whether the task is done after the tap.
  final bool nowDone;

  /// True when this tap finished the routine for the first time today.
  final bool routineFinished;

  /// The sticker won by finishing, or null when every sticker is owned.
  final String? newStickerId;
}

/// Owns [AppData] and writes every change to the device.
class AppController extends Notifier<AppData> {
  @override
  AppData build() {
    final stored = ref.watch(appRepositoryProvider).load();
    final today = _today();
    if (stored == null) return _starterData(today);
    return stored.progress.date == today
        ? stored
        : stored.copyWith(progress: DayProgress(date: today));
  }

  String _today() => dateKey(ref.read(clockProvider)());

  AppData _starterData(String today) => AppData(
    routines: [
      for (final key in starterTemplateKeys)
        _routineFrom(routineTemplatesByKey[key]!),
    ],
    progress: DayProgress(date: today),
    onboardingDone: false,
  );

  /// A new, unnamed routine holding the template's cards.
  Routine _routineFrom(RoutineTemplate template) {
    final ids = ref.read(idGeneratorProvider);
    return Routine(
      id: ids.next(),
      name: '',
      presetKey: template.presetKey,
      iconId: template.iconId,
      items: [
        for (final cardId in template.cardIds)
          RoutineItem(id: ids.next(), cardId: cardId),
      ],
    );
  }

  void _commit(AppData next) {
    state = next;
    unawaited(_persist(next));
  }

  Future<void> _persist(AppData data) async {
    try {
      await ref.read(appRepositoryProvider).save(data);
    } on Exception catch (error) {
      // The board keeps working from memory; the next change retries the
      // write with the full document.
      debugPrint('Saving app data failed: $error');
    }
  }

  void _replaceRoutine(Routine routine) {
    _commit(
      state.copyWith(
        routines: [
          for (final existing in state.routines)
            existing.id == routine.id ? routine : existing,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Child actions
  // ---------------------------------------------------------------------

  /// Starts a fresh board when the calendar day has changed.
  void refreshDay() {
    final today = _today();
    if (state.progress.date != today) {
      _commit(state.copyWith(progress: DayProgress(date: today)));
    }
  }

  /// Marks a task done, or not done if it already was.
  ///
  /// Finishing every task of a routine gives one sticker, at most once per
  /// routine per day, so undoing and redoing a task cannot farm stickers.
  ToggleOutcome toggleItem(String routineId, String itemId) {
    refreshDay();
    final routine = state.routineById(routineId);
    if (routine == null || !routine.items.any((item) => item.id == itemId)) {
      return const ToggleOutcome(nowDone: false);
    }

    final progress = state.progress;
    final done = {...progress.doneFor(routineId)};

    if (!done.add(itemId)) {
      done.remove(itemId);
      _commit(
        state.copyWith(
          progress: DayProgress(
            date: progress.date,
            done: {...progress.done, routineId: done},
            rewarded: progress.rewarded,
          ),
          totalStars: state.totalStars > 0 ? state.totalStars - 1 : 0,
        ),
      );
      return const ToggleOutcome(nowDone: false);
    }

    final finished =
        routine.items.every((item) => done.contains(item.id)) &&
        !progress.rewarded.contains(routineId);
    final newStickerId = finished ? _pickNewSticker() : null;

    _commit(
      state.copyWith(
        progress: DayProgress(
          date: progress.date,
          done: {...progress.done, routineId: done},
          rewarded: finished
              ? {...progress.rewarded, routineId}
              : progress.rewarded,
        ),
        totalStars: state.totalStars + 1,
        stickers: newStickerId == null
            ? state.stickers
            : [...state.stickers, newStickerId],
      ),
    );
    return ToggleOutcome(
      nowDone: true,
      routineFinished: finished,
      newStickerId: newStickerId,
    );
  }

  String? _pickNewSticker() {
    final missing = [
      for (final sticker in stickers)
        if (!state.stickers.contains(sticker.id)) sticker.id,
    ];
    if (missing.isEmpty) return null;
    return missing[ref.read(randomProvider).nextInt(missing.length)];
  }

  // ---------------------------------------------------------------------
  // Routines
  // ---------------------------------------------------------------------

  /// Adds an empty, unnamed routine and returns its id.
  String addRoutine() {
    final id = ref.read(idGeneratorProvider).next();
    _commit(
      state.copyWith(
        routines: [
          ...state.routines,
          Routine(
            id: id,
            name: '',
            iconId: defaultRoutineIconId,
            items: const [],
          ),
        ],
      ),
    );
    return id;
  }

  /// Adds a copy of the ready-made routine [presetKey] and returns its id,
  /// or null when there is no such template.
  String? addRoutineFromTemplate(String presetKey) {
    final template = routineTemplatesByKey[presetKey];
    if (template == null) return null;
    final routine = _routineFrom(template);
    _commit(state.copyWith(routines: [...state.routines, routine]));
    return routine.id;
  }

  void renameRoutine(String routineId, String name) {
    final routine = state.routineById(routineId);
    if (routine == null || routine.name == name) return;
    _replaceRoutine(routine.copyWith(name: name));
  }

  void setRoutineIcon(String routineId, String iconId) {
    final routine = state.routineById(routineId);
    if (routine == null || routine.iconId == iconId) return;
    _replaceRoutine(routine.copyWith(iconId: iconId));
  }

  void deleteRoutine(String routineId) {
    final progress = state.progress;
    _commit(
      state.copyWith(
        routines: [
          for (final routine in state.routines)
            if (routine.id != routineId) routine,
        ],
        progress: DayProgress(
          date: progress.date,
          done: {...progress.done}..remove(routineId),
          rewarded: {...progress.rewarded}..remove(routineId),
        ),
      ),
    );
  }

  /// Puts [cardId] at the end of the routine, or takes it off when
  /// [included] is false.
  void setCardInRoutine(
    String routineId,
    String cardId, {
    required bool included,
  }) {
    final routine = state.routineById(routineId);
    if (routine == null) return;
    final has = routine.items.any((item) => item.cardId == cardId);
    if (included == has) return;
    _replaceRoutine(
      routine.copyWith(
        items: included
            ? [
                ...routine.items,
                RoutineItem(
                  id: ref.read(idGeneratorProvider).next(),
                  cardId: cardId,
                ),
              ]
            : [
                for (final item in routine.items)
                  if (item.cardId != cardId) item,
              ],
      ),
    );
  }

  void removeItem(String routineId, String itemId) {
    final routine = state.routineById(routineId);
    if (routine == null) return;
    _replaceRoutine(
      routine.copyWith(
        items: [
          for (final item in routine.items)
            if (item.id != itemId) item,
        ],
      ),
    );
  }

  /// Moves the task at [from] so that it ends up at index [to].
  void moveItem(String routineId, int from, int to) {
    final routine = state.routineById(routineId);
    if (routine == null) return;
    final count = routine.items.length;
    if (from < 0 || from >= count || to < 0 || to >= count || from == to) {
      return;
    }
    final items = [...routine.items];
    items.insert(to, items.removeAt(from));
    _replaceRoutine(routine.copyWith(items: items));
  }

  // ---------------------------------------------------------------------
  // Parent-made cards
  // ---------------------------------------------------------------------

  Future<void> addCustomCard({
    required String label,
    required Uint8List imageBytes,
  }) async {
    final ids = ref.read(idGeneratorProvider);
    final imageId = ids.next();
    await ref.read(imageStoreProvider).save(imageId, imageBytes);
    _commit(
      state.copyWith(
        customCards: [
          ...state.customCards,
          CustomCard(id: ids.next(), label: label, imageId: imageId),
        ],
      ),
    );
  }

  /// Deletes the card, its photo, and every task that used it.
  Future<void> deleteCustomCard(String customCardId) async {
    CustomCard? card;
    for (final candidate in state.customCards) {
      if (candidate.id == customCardId) card = candidate;
    }
    if (card == null) return;
    final cardId = card.cardId;

    _commit(
      state.copyWith(
        customCards: [
          for (final existing in state.customCards)
            if (existing.id != customCardId) existing,
        ],
        routines: [
          for (final routine in state.routines)
            routine.copyWith(
              items: [
                for (final item in routine.items)
                  if (item.cardId != cardId) item,
              ],
            ),
        ],
      ),
    );
    await ref.read(imageStoreProvider).delete(card.imageId);
    ref.invalidate(cardImageProvider(card.imageId));
  }

  // ---------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------

  /// Ends the first-run welcome with the ready-made routines the family
  /// chose, in the order the templates are listed.
  void finishOnboarding(Set<String> templateKeys) {
    final existing = {
      for (final routine in state.routines) routine.presetKey: routine,
    };
    _commit(
      state.copyWith(
        routines: [
          for (final template in routineTemplates)
            if (templateKeys.contains(template.presetKey))
              existing[template.presetKey] ?? _routineFrom(template),
        ],
        onboardingDone: true,
      ),
    );
  }

  /// Pass null to follow the device language.
  void setLocale(String? localeCode) {
    _commit(state.copyWith(localeCode: () => localeCode));
  }

  void setSoundEnabled(bool enabled) {
    _commit(state.copyWith(soundEnabled: enabled));
  }

  /// Clears today's stars so the routines can be run again. Stickers
  /// already won are kept.
  void resetToday() {
    var earnedToday = 0;
    for (final done in state.progress.done.values) {
      earnedToday += done.length;
    }
    final remaining = state.totalStars - earnedToday;
    _commit(
      state.copyWith(
        progress: DayProgress(date: _today()),
        totalStars: remaining > 0 ? remaining : 0,
      ),
    );
  }
}
