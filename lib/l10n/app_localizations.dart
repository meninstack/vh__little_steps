import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Little Steps'**
  String get appTitle;

  /// No description provided for @welcomeIntro.
  ///
  /// In en, this message translates to:
  /// **'A picture routine chart that helps your child do everyday tasks, one step at a time.'**
  String get welcomeIntro;

  /// No description provided for @welcomePickRoutines.
  ///
  /// In en, this message translates to:
  /// **'Choose routines to start with'**
  String get welcomePickRoutines;

  /// No description provided for @welcomePickRoutinesHint.
  ///
  /// In en, this message translates to:
  /// **'You can add, change or remove them later in the grown-ups\' area.'**
  String get welcomePickRoutinesHint;

  /// No description provided for @welcomeStart.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get welcomeStart;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get commonDone;

  /// No description provided for @commonContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// No description provided for @stickerBook.
  ///
  /// In en, this message translates to:
  /// **'Sticker book'**
  String get stickerBook;

  /// No description provided for @stickerBookProgress.
  ///
  /// In en, this message translates to:
  /// **'{owned} of {total} friends'**
  String stickerBookProgress(int owned, int total);

  /// No description provided for @stickerLocked.
  ///
  /// In en, this message translates to:
  /// **'Finish a routine to meet this friend'**
  String get stickerLocked;

  /// No description provided for @stickerSetFarm.
  ///
  /// In en, this message translates to:
  /// **'Home and farm'**
  String get stickerSetFarm;

  /// No description provided for @stickerSetForest.
  ///
  /// In en, this message translates to:
  /// **'In the forest'**
  String get stickerSetForest;

  /// No description provided for @stickerSetWild.
  ///
  /// In en, this message translates to:
  /// **'Wild animals'**
  String get stickerSetWild;

  /// No description provided for @stickerSetSea.
  ///
  /// In en, this message translates to:
  /// **'In the sea'**
  String get stickerSetSea;

  /// No description provided for @stickerSetTiny.
  ///
  /// In en, this message translates to:
  /// **'Small and magical'**
  String get stickerSetTiny;

  /// No description provided for @totalStars.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No stars yet} =1{1 star} other{{count} stars}}'**
  String totalStars(int count);

  /// No description provided for @parentArea.
  ///
  /// In en, this message translates to:
  /// **'Grown-ups'**
  String get parentArea;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'{done} of {total}'**
  String progressLabel(int done, int total);

  /// No description provided for @childEmptyRoutine.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Ask a grown-up to add some!'**
  String get childEmptyRoutine;

  /// No description provided for @childNoRoutines.
  ///
  /// In en, this message translates to:
  /// **'No routines yet. Ask a grown-up to make one!'**
  String get childNoRoutines;

  /// No description provided for @semanticMarkDone.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as done'**
  String semanticMarkDone(String name);

  /// No description provided for @semanticMarkNotDone.
  ///
  /// In en, this message translates to:
  /// **'Mark {name} as not done'**
  String semanticMarkNotDone(String name);

  /// No description provided for @celebrateTitle.
  ///
  /// In en, this message translates to:
  /// **'Great job!'**
  String get celebrateTitle;

  /// No description provided for @celebrateBody.
  ///
  /// In en, this message translates to:
  /// **'You finished everything!'**
  String get celebrateBody;

  /// No description provided for @celebrateNewSticker.
  ///
  /// In en, this message translates to:
  /// **'A new friend joined your sticker book!'**
  String get celebrateNewSticker;

  /// No description provided for @celebrateAllCollected.
  ///
  /// In en, this message translates to:
  /// **'You have met every friend!'**
  String get celebrateAllCollected;

  /// No description provided for @celebrateButton.
  ///
  /// In en, this message translates to:
  /// **'Yay!'**
  String get celebrateButton;

  /// No description provided for @gateTitle.
  ///
  /// In en, this message translates to:
  /// **'For grown-ups'**
  String get gateTitle;

  /// No description provided for @gateQuestion.
  ///
  /// In en, this message translates to:
  /// **'What is {a} × {b}?'**
  String gateQuestion(int a, int b);

  /// No description provided for @gateAnswerLabel.
  ///
  /// In en, this message translates to:
  /// **'Answer'**
  String get gateAnswerLabel;

  /// No description provided for @gateWrong.
  ///
  /// In en, this message translates to:
  /// **'Not quite. Try again.'**
  String get gateWrong;

  /// No description provided for @parentTitle.
  ///
  /// In en, this message translates to:
  /// **'Grown-ups\' area'**
  String get parentTitle;

  /// No description provided for @tabRoutines.
  ///
  /// In en, this message translates to:
  /// **'Routines'**
  String get tabRoutines;

  /// No description provided for @tabMyCards.
  ///
  /// In en, this message translates to:
  /// **'My cards'**
  String get tabMyCards;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @presetMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get presetMorning;

  /// No description provided for @presetEvening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get presetEvening;

  /// No description provided for @presetAfterSchool.
  ///
  /// In en, this message translates to:
  /// **'After school'**
  String get presetAfterSchool;

  /// No description provided for @presetGoingOut.
  ///
  /// In en, this message translates to:
  /// **'Going out'**
  String get presetGoingOut;

  /// No description provided for @presetMealtime.
  ///
  /// In en, this message translates to:
  /// **'Mealtime'**
  String get presetMealtime;

  /// No description provided for @presetBedtime.
  ///
  /// In en, this message translates to:
  /// **'Bedtime'**
  String get presetBedtime;

  /// No description provided for @presetWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get presetWeekend;

  /// No description provided for @presetChores.
  ///
  /// In en, this message translates to:
  /// **'Helping at home'**
  String get presetChores;

  /// No description provided for @presetDoctor.
  ///
  /// In en, this message translates to:
  /// **'Doctor visit'**
  String get presetDoctor;

  /// No description provided for @newRoutine.
  ///
  /// In en, this message translates to:
  /// **'New routine'**
  String get newRoutine;

  /// No description provided for @addFromTemplate.
  ///
  /// In en, this message translates to:
  /// **'Add a ready-made routine'**
  String get addFromTemplate;

  /// No description provided for @templatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready-made routines'**
  String get templatesTitle;

  /// No description provided for @taskCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No tasks} =1{1 task} other{{count} tasks}}'**
  String taskCount(int count);

  /// No description provided for @editRoutine.
  ///
  /// In en, this message translates to:
  /// **'Edit routine'**
  String get editRoutine;

  /// No description provided for @routineNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Routine name'**
  String get routineNameLabel;

  /// No description provided for @routineIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get routineIconLabel;

  /// No description provided for @tasksHeader.
  ///
  /// In en, this message translates to:
  /// **'Tasks'**
  String get tasksHeader;

  /// No description provided for @addCards.
  ///
  /// In en, this message translates to:
  /// **'Add cards'**
  String get addCards;

  /// No description provided for @reorderHint.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to change the order.'**
  String get reorderHint;

  /// No description provided for @removeTask.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get removeTask;

  /// No description provided for @deleteRoutine.
  ///
  /// In en, this message translates to:
  /// **'Delete routine'**
  String get deleteRoutine;

  /// No description provided for @deleteRoutineConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? This cannot be undone.'**
  String deleteRoutineConfirm(String name);

  /// No description provided for @editorEmptyRoutine.
  ///
  /// In en, this message translates to:
  /// **'No tasks yet. Tap “Add cards” to start.'**
  String get editorEmptyRoutine;

  /// No description provided for @pickCards.
  ///
  /// In en, this message translates to:
  /// **'Choose cards'**
  String get pickCards;

  /// No description provided for @groupMorning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get groupMorning;

  /// No description provided for @groupSchool.
  ///
  /// In en, this message translates to:
  /// **'School'**
  String get groupSchool;

  /// No description provided for @groupCare.
  ///
  /// In en, this message translates to:
  /// **'Meals & care'**
  String get groupCare;

  /// No description provided for @groupHome.
  ///
  /// In en, this message translates to:
  /// **'Home & bedtime'**
  String get groupHome;

  /// No description provided for @groupOutside.
  ///
  /// In en, this message translates to:
  /// **'Out and about'**
  String get groupOutside;

  /// No description provided for @groupManners.
  ///
  /// In en, this message translates to:
  /// **'Kind words'**
  String get groupManners;

  /// No description provided for @groupCustom.
  ///
  /// In en, this message translates to:
  /// **'My cards'**
  String get groupCustom;

  /// No description provided for @pickerNoCustomCards.
  ///
  /// In en, this message translates to:
  /// **'You have not made any cards yet. Create one in “My cards”.'**
  String get pickerNoCustomCards;

  /// No description provided for @newCard.
  ///
  /// In en, this message translates to:
  /// **'New card'**
  String get newCard;

  /// No description provided for @cardNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Card name'**
  String get cardNameLabel;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @choosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose photo'**
  String get choosePhoto;

  /// No description provided for @cardNeedsPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add a photo first.'**
  String get cardNeedsPhoto;

  /// No description provided for @cardNeedsName.
  ///
  /// In en, this message translates to:
  /// **'Enter a name.'**
  String get cardNeedsName;

  /// No description provided for @photoError.
  ///
  /// In en, this message translates to:
  /// **'That photo could not be loaded.'**
  String get photoError;

  /// No description provided for @deleteCard.
  ///
  /// In en, this message translates to:
  /// **'Delete card'**
  String get deleteCard;

  /// No description provided for @deleteCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete “{name}”? It will be removed from every routine.'**
  String deleteCardConfirm(String name);

  /// No description provided for @myCardsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Make your own cards with a photo and a name.'**
  String get myCardsEmpty;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @settingsSound.
  ///
  /// In en, this message translates to:
  /// **'Play sounds'**
  String get settingsSound;

  /// No description provided for @settingsResetToday.
  ///
  /// In en, this message translates to:
  /// **'Reset today\'s progress'**
  String get settingsResetToday;

  /// No description provided for @settingsResetConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear every star earned today?'**
  String get settingsResetConfirm;

  /// No description provided for @settingsResetDone.
  ///
  /// In en, this message translates to:
  /// **'Today\'s progress was reset.'**
  String get settingsResetDone;

  /// No description provided for @settingsPrivacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacyTitle;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In en, this message translates to:
  /// **'This app collects no data. Photos and progress stay on this device.'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsLicenses.
  ///
  /// In en, this message translates to:
  /// **'Licenses and credits'**
  String get settingsLicenses;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
