// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Languages';

  @override
  String get continueButton => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get changeLanguage => 'Change Language';

  @override
  String get randomPicker => 'Decision Spinner';

  @override
  String get randomPickerDescription =>
      'Create a custom spinner with your own items';

  @override
  String get multiplayer => 'Spin Battle';

  @override
  String get multiplayerDescription =>
      'Play with friends and compete in rounds';

  @override
  String get dice => 'Dice';

  @override
  String get diceDescription => 'Roll two dice and see the total';

  @override
  String get whoFirst => 'Race to 10';

  @override
  String get whoFirstDescription => 'Play with friends and compete in rounds';

  @override
  String get adsOn => 'Ads On';

  @override
  String get adsOff => 'Ads Off';

  @override
  String get vibrationOn => 'Vibration On';

  @override
  String get vibrationOff => 'Vibration Off';

  @override
  String get soundOn => 'Sound On';

  @override
  String get soundOff => 'Sound Off';

  @override
  String get spinnerTitle => 'Spinner Title';

  @override
  String get enterSpinnerTitle => 'Enter spinner title';

  @override
  String get start => 'Start';

  @override
  String get addItem => 'Add Item';

  @override
  String get gameMode => 'Game Mode';

  @override
  String get singlePlayer => 'Single Player';

  @override
  String get multiplayerMode => 'Spin Battle';

  @override
  String get howManyRounds => 'How Many Rounds?';

  @override
  String get players => 'Players';

  @override
  String get addPlayer => 'Add Player';

  @override
  String get enterPlayerName => 'Enter player name';

  @override
  String get truthDare => 'Truth & Dare';

  @override
  String get close => 'Close';

  @override
  String get edit => 'Edit';

  @override
  String get reset => 'Reset';

  @override
  String get share => 'Share';

  @override
  String get truth => 'Truth';

  @override
  String get dare => 'Dare';

  @override
  String get earned => 'EARNED';

  @override
  String get selected => 'SELECTED';

  @override
  String get you => 'You';

  @override
  String get computer => 'Computer';

  @override
  String get round => 'Round';

  @override
  String get leave => 'Leave';

  @override
  String get leaveGame => 'Leave Game?';

  @override
  String get leaveGameMessage => 'Are you sure you want to leave the game?';

  @override
  String get cancel => 'Cancel';

  @override
  String get gameResults => 'Game Results';

  @override
  String get gold => 'Gold';

  @override
  String get silver => 'Silver';

  @override
  String get bronze => 'Bronze';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String get toUnlock => 'to unlock';

  @override
  String get twoDice => 'Two Dice';

  @override
  String get multiplication => 'Multiplication';

  @override
  String get result => 'Result';

  @override
  String get spin => 'Spin';

  @override
  String get randomPickerTitle => 'Decision Spinner';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Level';

  @override
  String get easy => 'Easy';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Hard';

  @override
  String get selectLevel => 'Select Level';

  @override
  String get mathSpinner => 'Math Challenge';

  @override
  String get mathSpinnerDescription =>
      'Practice math with fun spinner challenges';

  @override
  String get spinnerItems => 'Spinner Items';

  @override
  String get enterItemName => 'Enter item name';

  @override
  String get noItems => 'No items. Click \"Add Item\" to add items.';

  @override
  String get pleaseAddAtLeastOneItem => 'Please add at least one item';

  @override
  String duplicateItemName(String item) {
    return 'Duplicate item name: \"$item\". Please use unique names.';
  }

  @override
  String get pleaseAddAtLeastOneUser => 'Please add at least one user';

  @override
  String duplicateUserName(String user) {
    return 'Duplicate user name: \"$user\". Please use unique names.';
  }

  @override
  String get mathSpinnerComingSoon => 'Math Challenge page coming soon!';

  @override
  String errorSharing(String error) {
    return 'Error sharing: $error';
  }

  @override
  String get playerCount => 'Player Count';

  @override
  String get users => 'Users';

  @override
  String get enterUserName => 'Enter user name';

  @override
  String total(String score) {
    return 'Total: $score';
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
      'Check out our Spin Battle spinner game results!';

  @override
  String get allItemsUsed => 'All truth and dare items have been used!';

  @override
  String errorLoadingData(String error) {
    return 'Error loading data: $error';
  }

  @override
  String get dice1 => 'Dice 1';

  @override
  String get dice2 => 'Dice 2';

  @override
  String get resultUppercase => 'RESULT';

  @override
  String score(String score) {
    return 'Score: $score';
  }

  @override
  String turn(String user) {
    return '$user\'s Turn';
  }
}
