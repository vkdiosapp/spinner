import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_af.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('af'),
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fil'),
    Locale('fr'),
    Locale('hi'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Spinner'**
  String get appTitle;

  /// No description provided for @languages.
  ///
  /// In en, this message translates to:
  /// **'Languages'**
  String get languages;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Change Language'**
  String get changeLanguage;

  /// No description provided for @randomPicker.
  ///
  /// In en, this message translates to:
  /// **'Decision Spinner'**
  String get randomPicker;

  /// No description provided for @randomPickerDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a custom spinner with your own items'**
  String get randomPickerDescription;

  /// No description provided for @multiplayer.
  ///
  /// In en, this message translates to:
  /// **'Spin Battle'**
  String get multiplayer;

  /// No description provided for @multiplayerDescription.
  ///
  /// In en, this message translates to:
  /// **'Play with friends and compete in rounds'**
  String get multiplayerDescription;

  /// No description provided for @dice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get dice;

  /// No description provided for @diceDescription.
  ///
  /// In en, this message translates to:
  /// **'Roll two dice and see the total'**
  String get diceDescription;

  /// No description provided for @whoFirst.
  ///
  /// In en, this message translates to:
  /// **'Race to 10'**
  String get whoFirst;

  /// No description provided for @whoFirstDescription.
  ///
  /// In en, this message translates to:
  /// **'Play with friends and compete in rounds'**
  String get whoFirstDescription;

  /// No description provided for @adsOn.
  ///
  /// In en, this message translates to:
  /// **'Ads On'**
  String get adsOn;

  /// No description provided for @adsOff.
  ///
  /// In en, this message translates to:
  /// **'Ads Off'**
  String get adsOff;

  /// No description provided for @vibrationOn.
  ///
  /// In en, this message translates to:
  /// **'Vibration On'**
  String get vibrationOn;

  /// No description provided for @vibrationOff.
  ///
  /// In en, this message translates to:
  /// **'Vibration Off'**
  String get vibrationOff;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Sound On'**
  String get soundOn;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Sound Off'**
  String get soundOff;

  /// No description provided for @spinnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Spinner Title'**
  String get spinnerTitle;

  /// No description provided for @enterSpinnerTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter spinner title'**
  String get enterSpinnerTitle;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @gameMode.
  ///
  /// In en, this message translates to:
  /// **'Game Mode'**
  String get gameMode;

  /// No description provided for @singlePlayer.
  ///
  /// In en, this message translates to:
  /// **'Single Player'**
  String get singlePlayer;

  /// No description provided for @multiplayerMode.
  ///
  /// In en, this message translates to:
  /// **'Spin Battle'**
  String get multiplayerMode;

  /// No description provided for @howManyRounds.
  ///
  /// In en, this message translates to:
  /// **'How Many Rounds?'**
  String get howManyRounds;

  /// No description provided for @players.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get players;

  /// No description provided for @addPlayer.
  ///
  /// In en, this message translates to:
  /// **'Add Player'**
  String get addPlayer;

  /// No description provided for @enterPlayerName.
  ///
  /// In en, this message translates to:
  /// **'Enter player name'**
  String get enterPlayerName;

  /// No description provided for @truthDare.
  ///
  /// In en, this message translates to:
  /// **'Truth & Dare'**
  String get truthDare;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @truth.
  ///
  /// In en, this message translates to:
  /// **'Truth'**
  String get truth;

  /// No description provided for @dare.
  ///
  /// In en, this message translates to:
  /// **'Dare'**
  String get dare;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'EARNED'**
  String get earned;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'SELECTED'**
  String get selected;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// No description provided for @computer.
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computer;

  /// No description provided for @round.
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// No description provided for @leave.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get leave;

  /// No description provided for @leaveGame.
  ///
  /// In en, this message translates to:
  /// **'Leave Game?'**
  String get leaveGame;

  /// No description provided for @leaveGameMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to leave the game?'**
  String get leaveGameMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @gameResults.
  ///
  /// In en, this message translates to:
  /// **'Game Results'**
  String get gameResults;

  /// No description provided for @gold.
  ///
  /// In en, this message translates to:
  /// **'Gold'**
  String get gold;

  /// No description provided for @silver.
  ///
  /// In en, this message translates to:
  /// **'Silver'**
  String get silver;

  /// No description provided for @bronze.
  ///
  /// In en, this message translates to:
  /// **'Bronze'**
  String get bronze;

  /// No description provided for @watchAd.
  ///
  /// In en, this message translates to:
  /// **'Watch Ad'**
  String get watchAd;

  /// No description provided for @toUnlock.
  ///
  /// In en, this message translates to:
  /// **'to unlock'**
  String get toUnlock;

  /// No description provided for @twoDice.
  ///
  /// In en, this message translates to:
  /// **'Two Dice'**
  String get twoDice;

  /// No description provided for @multiplication.
  ///
  /// In en, this message translates to:
  /// **'Multiplication'**
  String get multiplication;

  /// No description provided for @result.
  ///
  /// In en, this message translates to:
  /// **'Result'**
  String get result;

  /// No description provided for @spin.
  ///
  /// In en, this message translates to:
  /// **'Spin'**
  String get spin;

  /// No description provided for @randomPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Decision Spinner'**
  String get randomPickerTitle;

  /// No description provided for @spinner.
  ///
  /// In en, this message translates to:
  /// **'Spinner'**
  String get spinner;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get level;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @selectLevel.
  ///
  /// In en, this message translates to:
  /// **'Select Level'**
  String get selectLevel;

  /// No description provided for @mathSpinner.
  ///
  /// In en, this message translates to:
  /// **'Math Challenge'**
  String get mathSpinner;

  /// No description provided for @mathSpinnerDescription.
  ///
  /// In en, this message translates to:
  /// **'Practice math with fun spinner challenges'**
  String get mathSpinnerDescription;

  /// No description provided for @spinnerItems.
  ///
  /// In en, this message translates to:
  /// **'Spinner Items'**
  String get spinnerItems;

  /// No description provided for @enterItemName.
  ///
  /// In en, this message translates to:
  /// **'Enter item name'**
  String get enterItemName;

  /// No description provided for @noItems.
  ///
  /// In en, this message translates to:
  /// **'No items. Click \"Add Item\" to add items.'**
  String get noItems;

  /// No description provided for @pleaseAddAtLeastOneItem.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item'**
  String get pleaseAddAtLeastOneItem;

  /// No description provided for @duplicateItemName.
  ///
  /// In en, this message translates to:
  /// **'Duplicate item name: \"{item}\". Please use unique names.'**
  String duplicateItemName(String item);

  /// No description provided for @pleaseAddAtLeastOneUser.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one user'**
  String get pleaseAddAtLeastOneUser;

  /// No description provided for @duplicateUserName.
  ///
  /// In en, this message translates to:
  /// **'Duplicate user name: \"{user}\". Please use unique names.'**
  String duplicateUserName(String user);

  /// No description provided for @mathSpinnerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Math Challenge page coming soon!'**
  String get mathSpinnerComingSoon;

  /// No description provided for @errorSharing.
  ///
  /// In en, this message translates to:
  /// **'Error sharing: {error}'**
  String errorSharing(String error);

  /// No description provided for @playerCount.
  ///
  /// In en, this message translates to:
  /// **'Player Count'**
  String get playerCount;

  /// No description provided for @users.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get users;

  /// No description provided for @enterUserName.
  ///
  /// In en, this message translates to:
  /// **'Enter user name'**
  String get enterUserName;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total: {score}'**
  String total(String score);

  /// No description provided for @rounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds: {roundsList}'**
  String rounds(String roundsList);

  /// No description provided for @roundScore.
  ///
  /// In en, this message translates to:
  /// **'R{round}: {score}'**
  String roundScore(String round, String score);

  /// No description provided for @checkOutResults.
  ///
  /// In en, this message translates to:
  /// **'Check out our Spin Battle spinner game results!'**
  String get checkOutResults;

  /// No description provided for @allItemsUsed.
  ///
  /// In en, this message translates to:
  /// **'All truth and dare items have been used!'**
  String get allItemsUsed;

  /// No description provided for @errorLoadingData.
  ///
  /// In en, this message translates to:
  /// **'Error loading data: {error}'**
  String errorLoadingData(String error);

  /// No description provided for @dice1.
  ///
  /// In en, this message translates to:
  /// **'Dice 1'**
  String get dice1;

  /// No description provided for @dice2.
  ///
  /// In en, this message translates to:
  /// **'Dice 2'**
  String get dice2;

  /// No description provided for @resultUppercase.
  ///
  /// In en, this message translates to:
  /// **'RESULT'**
  String get resultUppercase;

  /// No description provided for @score.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String score(String score);

  /// No description provided for @turn.
  ///
  /// In en, this message translates to:
  /// **'{user}\'s Turn'**
  String turn(String user);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'af',
    'ar',
    'de',
    'en',
    'es',
    'fil',
    'fr',
    'hi',
    'id',
    'it',
    'ja',
    'ko',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'uk',
    'vi',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'af':
      return AppLocalizationsAf();
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fil':
      return AppLocalizationsFil();
    case 'fr':
      return AppLocalizationsFr();
    case 'hi':
      return AppLocalizationsHi();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
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
