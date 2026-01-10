// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Filipino Pilipino (`fil`).
class AppLocalizationsFil extends AppLocalizations {
  AppLocalizationsFil([String locale = 'fil']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Mga Wika';

  @override
  String get continueButton => 'Magpatuloy';

  @override
  String get save => 'I-save';

  @override
  String get changeLanguage => 'Palitan ang Wika';

  @override
  String get randomPicker => 'Random Picker';

  @override
  String get randomPickerDescription =>
      'Gumawa ng custom spinner gamit ang iyong sariling mga item';

  @override
  String get multiplayer => 'Multiplayer';

  @override
  String get multiplayerDescription =>
      'Maglaro kasama ang mga kaibigan at makipagkumpetensya sa mga round';

  @override
  String get dice => 'Dice';

  @override
  String get diceDescription =>
      'I-roll ang dalawang dice at tingnan ang kabuuan';

  @override
  String get whoFirst => 'Sino Una';

  @override
  String get whoFirstDescription =>
      'Maglaro kasama ang mga kaibigan at makipagkumpetensya sa mga round';

  @override
  String get adsOn => 'Naka-on ang Ads';

  @override
  String get adsOff => 'Naka-off ang Ads';

  @override
  String get vibrationOn => 'Naka-on ang Vibration';

  @override
  String get vibrationOff => 'Naka-off ang Vibration';

  @override
  String get soundOn => 'Naka-on ang Sound';

  @override
  String get soundOff => 'Naka-off ang Sound';

  @override
  String get spinnerTitle => 'Spinner Title';

  @override
  String get enterSpinnerTitle => 'Ilagay ang spinner title';

  @override
  String get start => 'Simula';

  @override
  String get addItem => 'Magdagdag ng Item';

  @override
  String get gameMode => 'Game Mode';

  @override
  String get singlePlayer => 'Single Player';

  @override
  String get multiplayerMode => 'Multiplayer';

  @override
  String get howManyRounds => 'Ilang Rounds?';

  @override
  String get players => 'Mga Player';

  @override
  String get addPlayer => 'Magdagdag ng Player';

  @override
  String get enterPlayerName => 'Ilagay ang pangalan ng player';

  @override
  String get truthDare => 'Truth & Dare';

  @override
  String get close => 'Isara';

  @override
  String get edit => 'I-edit';

  @override
  String get reset => 'I-reset';

  @override
  String get share => 'I-share';

  @override
  String get truth => 'Truth';

  @override
  String get dare => 'Dare';

  @override
  String get earned => 'NAKAMIT';

  @override
  String get selected => 'NAPILI';

  @override
  String get you => 'Ikaw';

  @override
  String get computer => 'Computer';

  @override
  String get round => 'Round';

  @override
  String get leave => 'Umalis';

  @override
  String get leaveGame => 'Umalis sa Laro?';

  @override
  String get leaveGameMessage => 'Sigurado ka bang gusto mong umalis sa laro?';

  @override
  String get cancel => 'Kanselahin';

  @override
  String get gameResults => 'Mga Resulta ng Laro';

  @override
  String get gold => 'Ginto';

  @override
  String get silver => 'Pilak';

  @override
  String get bronze => 'Tanso';

  @override
  String get watchAd => 'Manood ng Ad';

  @override
  String get toUnlock => 'para ma-unlock';

  @override
  String get twoDice => 'Dalawang Dice';

  @override
  String get multiplication => 'Multiplication';

  @override
  String get result => 'Resulta';

  @override
  String get spin => 'I-spin';

  @override
  String get randomPickerTitle => 'Random Picker';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Level';

  @override
  String get easy => 'Madali';

  @override
  String get medium => 'Katamtaman';

  @override
  String get hard => 'Mahirap';

  @override
  String get selectLevel => 'Pumili ng Level';

  @override
  String get mathSpinner => 'Math Spinner';

  @override
  String get mathSpinnerDescription =>
      'Magsanay ng math gamit ang masayang spinner challenges';

  @override
  String get spinnerItems => 'Spinner Items';

  @override
  String get enterItemName => 'Ilagay ang pangalan ng item';

  @override
  String get noItems =>
      'Walang items. I-click ang \"Add Item\" para magdagdag ng items.';

  @override
  String get pleaseAddAtLeastOneItem =>
      'Mangyaring magdagdag ng kahit isang item';

  @override
  String duplicateItemName(String item) {
    return 'Duplicate na pangalan ng item: \"$item\". Mangyaring gumamit ng natatanging pangalan.';
  }

  @override
  String get pleaseAddAtLeastOneUser =>
      'Mangyaring magdagdag ng kahit isang user';

  @override
  String duplicateUserName(String user) {
    return 'Duplicate na pangalan ng user: \"$user\". Mangyaring gumamit ng natatanging pangalan.';
  }

  @override
  String get mathSpinnerComingSoon => 'Math Spinner page darating na!';

  @override
  String errorSharing(String error) {
    return 'Error sa pagbabahagi: $error';
  }

  @override
  String get playerCount => 'Bilang ng Player';

  @override
  String get users => 'Users';

  @override
  String get enterUserName => 'Ilagay ang pangalan ng user';

  @override
  String total(String score) {
    return 'Kabuuan: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Rounds: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults =>
      'Tingnan ang aming multiplayer spinner game results!';

  @override
  String get allItemsUsed => 'Lahat ng truth at dare items ay nagamit na!';

  @override
  String errorLoadingData(String error) {
    return 'Error sa pag-load ng data: $error';
  }

  @override
  String get dice1 => 'Dice 1';

  @override
  String get dice2 => 'Dice 2';

  @override
  String get resultUppercase => 'RESULTA';

  @override
  String score(String score) {
    return 'Score: $score';
  }

  @override
  String turn(String user) {
    return 'Turn ni $user';
  }
}
