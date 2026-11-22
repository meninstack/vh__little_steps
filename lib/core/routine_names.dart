import '../data/card_catalog.dart';
import '../data/models.dart';
import '../l10n/app_localizations.dart';

/// The name to show for a routine: what the parent typed, or a translated
/// default for a ready-made or still-unnamed routine.
String routineDisplayName(Routine routine, AppLocalizations l10n) {
  final name = routine.name.trim();
  if (name.isNotEmpty) return name;
  return presetName(routine.presetKey, l10n) ?? l10n.newRoutine;
}

/// The translated name of a ready-made routine, or null for an unknown key.
String? presetName(String? presetKey, AppLocalizations l10n) =>
    switch (presetKey) {
      'morning' => l10n.presetMorning,
      'evening' => l10n.presetEvening,
      'after_school' => l10n.presetAfterSchool,
      'going_out' => l10n.presetGoingOut,
      'mealtime' => l10n.presetMealtime,
      'bedtime' => l10n.presetBedtime,
      'weekend' => l10n.presetWeekend,
      'chores' => l10n.presetChores,
      'doctor' => l10n.presetDoctor,
      _ => null,
    };

/// The translated name of a card group, shown on the card picker's tabs.
String cardGroupName(CardGroup group, AppLocalizations l10n) => switch (group) {
  CardGroup.morning => l10n.groupMorning,
  CardGroup.school => l10n.groupSchool,
  CardGroup.care => l10n.groupCare,
  CardGroup.home => l10n.groupHome,
  CardGroup.outside => l10n.groupOutside,
  CardGroup.manners => l10n.groupManners,
};

/// The translated name of a page of the sticker book.
String stickerSetName(StickerSet group, AppLocalizations l10n) =>
    switch (group) {
      StickerSet.farm => l10n.stickerSetFarm,
      StickerSet.forest => l10n.stickerSetForest,
      StickerSet.wild => l10n.stickerSetWild,
      StickerSet.sea => l10n.stickerSetSea,
      StickerSet.tiny => l10n.stickerSetTiny,
    };
