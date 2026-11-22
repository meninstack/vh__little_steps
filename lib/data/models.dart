import 'package:flutter/foundation.dart';

/// Card ids of parent-made cards carry this prefix; built-in ids do not.
const String customCardPrefix = 'custom:';

/// One task on a routine. The same card may appear twice in a routine, so
/// progress is tracked per item, not per card.
@immutable
class RoutineItem {
  const RoutineItem({required this.id, required this.cardId});

  factory RoutineItem.fromJson(Map<String, dynamic> json) =>
      RoutineItem(id: json['id'] as String, cardId: json['cardId'] as String);

  final String id;
  final String cardId;

  Map<String, dynamic> toJson() => {'id': id, 'cardId': cardId};
}

@immutable
class Routine {
  const Routine({
    required this.id,
    required this.name,
    required this.iconId,
    required this.items,
    this.presetKey,
  });

  factory Routine.fromJson(Map<String, dynamic> json) => Routine(
    id: json['id'] as String,
    name: json['name'] as String? ?? '',
    presetKey: json['presetKey'] as String?,
    iconId: json['iconId'] as String? ?? 'star',
    items: [
      for (final item in json['items'] as List<dynamic>? ?? const [])
        RoutineItem.fromJson(item as Map<String, dynamic>),
    ],
  );

  final String id;

  /// Name typed by a parent. Empty for a starter routine that has not been
  /// renamed; the UI then shows the translated name for [presetKey].
  final String name;

  /// `morning` or `evening` for the starter routines, otherwise null.
  final String? presetKey;

  final String iconId;
  final List<RoutineItem> items;

  Routine copyWith({String? name, String? iconId, List<RoutineItem>? items}) =>
      Routine(
        id: id,
        name: name ?? this.name,
        presetKey: presetKey,
        iconId: iconId ?? this.iconId,
        items: items ?? this.items,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'presetKey': ?presetKey,
    'iconId': iconId,
    'items': [for (final item in items) item.toJson()],
  };
}

/// A card a parent made from a photo and a name.
@immutable
class CustomCard {
  const CustomCard({
    required this.id,
    required this.label,
    required this.imageId,
  });

  factory CustomCard.fromJson(Map<String, dynamic> json) => CustomCard(
    id: json['id'] as String,
    label: json['label'] as String,
    imageId: json['imageId'] as String,
  );

  final String id;
  final String label;

  /// Key of the photo in the image store.
  final String imageId;

  String get cardId => '$customCardPrefix$id';

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'imageId': imageId,
  };
}

/// What has been finished on one calendar day.
@immutable
class DayProgress {
  const DayProgress({
    required this.date,
    this.done = const {},
    this.rewarded = const {},
  });

  factory DayProgress.fromJson(Map<String, dynamic> json) => DayProgress(
    date: json['date'] as String,
    done: {
      for (final entry
          in (json['done'] as Map<String, dynamic>? ?? const {}).entries)
        entry.key: {
          for (final id in entry.value as List<dynamic>) id as String,
        },
    },
    rewarded: {
      for (final id in json['rewarded'] as List<dynamic>? ?? const [])
        id as String,
    },
  );

  /// See `dateKey` in `core/clock.dart`.
  final String date;

  /// Finished item ids, keyed by routine id.
  final Map<String, Set<String>> done;

  /// Routines that already gave their sticker today.
  final Set<String> rewarded;

  Set<String> doneFor(String routineId) => done[routineId] ?? const {};

  Map<String, dynamic> toJson() => {
    'date': date,
    'done': {for (final entry in done.entries) entry.key: entry.value.toList()},
    'rewarded': rewarded.toList(),
  };
}

/// Everything the app persists.
@immutable
class AppData {
  const AppData({
    required this.routines,
    required this.progress,
    this.customCards = const [],
    this.stickers = const [],
    this.totalStars = 0,
    this.localeCode,
    this.soundEnabled = true,
    this.onboardingDone = true,
  });

  factory AppData.fromJson(Map<String, dynamic> json) => AppData(
    routines: [
      for (final routine in json['routines'] as List<dynamic>? ?? const [])
        Routine.fromJson(routine as Map<String, dynamic>),
    ],
    customCards: [
      for (final card in json['customCards'] as List<dynamic>? ?? const [])
        CustomCard.fromJson(card as Map<String, dynamic>),
    ],
    progress: DayProgress.fromJson(json['progress'] as Map<String, dynamic>),
    stickers: [
      for (final id in json['stickers'] as List<dynamic>? ?? const [])
        id as String,
    ],
    totalStars: json['totalStars'] as int? ?? 0,
    localeCode: json['localeCode'] as String?,
    soundEnabled: json['soundEnabled'] as bool? ?? true,
    // Data saved before the welcome screen existed belongs to a family
    // that is already using the app.
    onboardingDone: json['onboardingDone'] as bool? ?? true,
  );

  final List<Routine> routines;
  final List<CustomCard> customCards;
  final DayProgress progress;

  /// Sticker ids the child owns, oldest first.
  final List<String> stickers;

  /// Lifetime count of finished tasks.
  final int totalStars;

  /// `vi`, `en`, or null to follow the device language.
  final String? localeCode;

  /// Whether taps play notes and a finished routine plays its tune.
  final bool soundEnabled;

  /// False on a new installation until the welcome screen is finished.
  final bool onboardingDone;

  Routine? routineById(String id) {
    for (final routine in routines) {
      if (routine.id == id) return routine;
    }
    return null;
  }

  CustomCard? customCardByCardId(String cardId) {
    for (final card in customCards) {
      if (card.cardId == cardId) return card;
    }
    return null;
  }

  bool isDone(String routineId, String itemId) =>
      progress.doneFor(routineId).contains(itemId);

  /// Finished tasks that are still on the routine.
  int doneCount(Routine routine) {
    final done = progress.doneFor(routine.id);
    return routine.items.where((item) => done.contains(item.id)).length;
  }

  AppData copyWith({
    List<Routine>? routines,
    List<CustomCard>? customCards,
    DayProgress? progress,
    List<String>? stickers,
    int? totalStars,
    ValueGetter<String?>? localeCode,
    bool? soundEnabled,
    bool? onboardingDone,
  }) => AppData(
    routines: routines ?? this.routines,
    customCards: customCards ?? this.customCards,
    progress: progress ?? this.progress,
    stickers: stickers ?? this.stickers,
    totalStars: totalStars ?? this.totalStars,
    localeCode: localeCode != null ? localeCode() : this.localeCode,
    soundEnabled: soundEnabled ?? this.soundEnabled,
    onboardingDone: onboardingDone ?? this.onboardingDone,
  );

  Map<String, dynamic> toJson() => {
    'version': 1,
    'routines': [for (final routine in routines) routine.toJson()],
    'customCards': [for (final card in customCards) card.toJson()],
    'progress': progress.toJson(),
    'stickers': stickers,
    'totalStars': totalStars,
    'localeCode': ?localeCode,
    'soundEnabled': soundEnabled,
    'onboardingDone': onboardingDone,
  };
}
