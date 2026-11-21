// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Little Steps';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonDone => 'Done';

  @override
  String get commonContinue => 'Continue';

  @override
  String get stickerBook => 'Sticker book';

  @override
  String stickerBookProgress(int owned, int total) {
    return '$owned of $total friends';
  }

  @override
  String get stickerLocked => 'Finish a routine to meet this friend';

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stars',
      one: '1 star',
      zero: 'No stars yet',
    );
    return '$_temp0';
  }

  @override
  String get parentArea => 'Grown-ups';

  @override
  String progressLabel(int done, int total) {
    return '$done of $total';
  }

  @override
  String get childEmptyRoutine => 'No tasks yet. Ask a grown-up to add some!';

  @override
  String get childNoRoutines => 'No routines yet. Ask a grown-up to make one!';

  @override
  String semanticMarkDone(String name) {
    return 'Mark $name as done';
  }

  @override
  String semanticMarkNotDone(String name) {
    return 'Mark $name as not done';
  }

  @override
  String get celebrateTitle => 'Great job!';

  @override
  String get celebrateBody => 'You finished everything!';

  @override
  String get celebrateNewSticker => 'A new friend joined your sticker book!';

  @override
  String get celebrateAllCollected => 'You have met every friend!';

  @override
  String get celebrateButton => 'Yay!';

  @override
  String get gateTitle => 'For grown-ups';

  @override
  String gateQuestion(int a, int b) {
    return 'What is $a × $b?';
  }

  @override
  String get gateAnswerLabel => 'Answer';

  @override
  String get gateWrong => 'Not quite. Try again.';

  @override
  String get parentTitle => 'Grown-ups\' area';

  @override
  String get tabRoutines => 'Routines';

  @override
  String get tabMyCards => 'My cards';

  @override
  String get tabSettings => 'Settings';

  @override
  String get presetMorning => 'Morning';

  @override
  String get presetEvening => 'Evening';

  @override
  String get newRoutine => 'New routine';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count tasks',
      one: '1 task',
      zero: 'No tasks',
    );
    return '$_temp0';
  }

  @override
  String get editRoutine => 'Edit routine';

  @override
  String get routineNameLabel => 'Routine name';

  @override
  String get routineIconLabel => 'Icon';

  @override
  String get tasksHeader => 'Tasks';

  @override
  String get addCards => 'Add cards';

  @override
  String get reorderHint => 'Drag the handle to change the order.';

  @override
  String get removeTask => 'Remove';

  @override
  String get deleteRoutine => 'Delete routine';

  @override
  String deleteRoutineConfirm(String name) {
    return 'Delete “$name”? This cannot be undone.';
  }

  @override
  String get editorEmptyRoutine => 'No tasks yet. Tap “Add cards” to start.';

  @override
  String get pickCards => 'Choose cards';

  @override
  String get groupMorning => 'Morning';

  @override
  String get groupSchool => 'School';

  @override
  String get groupCare => 'Meals & care';

  @override
  String get groupHome => 'Home & bedtime';

  @override
  String get groupCustom => 'My cards';

  @override
  String get pickerNoCustomCards =>
      'You have not made any cards yet. Create one in “My cards”.';

  @override
  String get newCard => 'New card';

  @override
  String get cardNameLabel => 'Card name';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get choosePhoto => 'Choose photo';

  @override
  String get cardNeedsPhoto => 'Add a photo first.';

  @override
  String get cardNeedsName => 'Enter a name.';

  @override
  String get photoError => 'That photo could not be loaded.';

  @override
  String get deleteCard => 'Delete card';

  @override
  String deleteCardConfirm(String name) {
    return 'Delete “$name”? It will be removed from every routine.';
  }

  @override
  String get myCardsEmpty => 'Make your own cards with a photo and a name.';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get settingsSound => 'Play sounds';

  @override
  String get settingsResetToday => 'Reset today\'s progress';

  @override
  String get settingsResetConfirm => 'Clear every star earned today?';

  @override
  String get settingsResetDone => 'Today\'s progress was reset.';

  @override
  String get settingsPrivacyTitle => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'This app collects no data. Photos and progress stay on this device.';

  @override
  String get settingsLicenses => 'Licenses and credits';
}
