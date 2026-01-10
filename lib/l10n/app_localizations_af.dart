// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Afrikaans (`af`).
class AppLocalizationsAf extends AppLocalizations {
  AppLocalizationsAf([String locale = 'af']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Tale';

  @override
  String get continueButton => 'Gaan voort';

  @override
  String get save => 'Stoor';

  @override
  String get changeLanguage => 'Verander Taal';

  @override
  String get randomPicker => 'Ewekansige Kieser';

  @override
  String get randomPickerDescription =>
      'Skep \'n pasgemaakte spinner met jou eie items';

  @override
  String get multiplayer => 'Meervoudige Speler';

  @override
  String get multiplayerDescription =>
      'Speel met vriende en kompeteer in rondes';

  @override
  String get dice => 'Dobbelstene';

  @override
  String get diceDescription => 'Rol twee dobbelstene en sien die totaal';

  @override
  String get whoFirst => 'Wie Eerste';

  @override
  String get whoFirstDescription => 'Speel met vriende en kompeteer in rondes';

  @override
  String get adsOn => 'Advertensies Aan';

  @override
  String get adsOff => 'Advertensies Af';

  @override
  String get vibrationOn => 'Vibrasie Aan';

  @override
  String get vibrationOff => 'Vibrasie Af';

  @override
  String get soundOn => 'Klank Aan';

  @override
  String get soundOff => 'Klank Af';

  @override
  String get spinnerTitle => 'Spinner Titel';

  @override
  String get enterSpinnerTitle => 'Voer spinner titel in';

  @override
  String get start => 'Begin';

  @override
  String get addItem => 'Voeg Item By';

  @override
  String get gameMode => 'Spel Modus';

  @override
  String get singlePlayer => 'Enkelspeler';

  @override
  String get multiplayerMode => 'Meervoudige Speler';

  @override
  String get howManyRounds => 'Hoeveel Rondes?';

  @override
  String get players => 'Spelers';

  @override
  String get addPlayer => 'Voeg Speler By';

  @override
  String get enterPlayerName => 'Voer speler naam in';

  @override
  String get truthDare => 'Waarheid & Durf';

  @override
  String get close => 'Sluit';

  @override
  String get edit => 'Wysig';

  @override
  String get reset => 'Herstel';

  @override
  String get share => 'Deel';

  @override
  String get truth => 'Waarheid';

  @override
  String get dare => 'Durf';

  @override
  String get earned => 'VERDIEN';

  @override
  String get selected => 'GEKIES';

  @override
  String get you => 'Jy';

  @override
  String get computer => 'Rekenaar';

  @override
  String get round => 'Ronde';

  @override
  String get leave => 'Verlaat';

  @override
  String get leaveGame => 'Verlaat Spel?';

  @override
  String get leaveGameMessage => 'Is jy seker jy wil die spel verlaat?';

  @override
  String get cancel => 'Kanselleer';

  @override
  String get gameResults => 'Spel Resultate';

  @override
  String get gold => 'Goud';

  @override
  String get silver => 'Silwer';

  @override
  String get bronze => 'Brons';

  @override
  String get watchAd => 'Kyk Advertensie';

  @override
  String get toUnlock => 'om te ontsluit';

  @override
  String get twoDice => 'Twee Dobbelstene';

  @override
  String get multiplication => 'Vermenigvuldiging';

  @override
  String get result => 'Resultaat';

  @override
  String get spin => 'Draai';

  @override
  String get randomPickerTitle => 'Ewekansige Kieser';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Vlak';

  @override
  String get easy => 'Maklik';

  @override
  String get medium => 'Medium';

  @override
  String get hard => 'Moeilik';

  @override
  String get selectLevel => 'Kies Vlak';

  @override
  String get mathSpinner => 'Wiskunde Spinner';

  @override
  String get mathSpinnerDescription =>
      'Oefen wiskunde met lekker spinner uitdagings';

  @override
  String get spinnerItems => 'Spinner Items';

  @override
  String get enterItemName => 'Voer item naam in';

  @override
  String get noItems =>
      'Geen items. Klik \"Voeg Item By\" om items by te voeg.';

  @override
  String get pleaseAddAtLeastOneItem => 'Voeg asseblief ten minste een item by';

  @override
  String duplicateItemName(String item) {
    return 'Duplikaat item naam: \"$item\". Gebruik asseblief unieke name.';
  }

  @override
  String get pleaseAddAtLeastOneUser =>
      'Voeg asseblief ten minste een gebruiker by';

  @override
  String duplicateUserName(String user) {
    return 'Duplikaat gebruiker naam: \"$user\". Gebruik asseblief unieke name.';
  }

  @override
  String get mathSpinnerComingSoon => 'Wiskunde Spinner bladsy kom binnekort!';

  @override
  String errorSharing(String error) {
    return 'Fout met deel: $error';
  }

  @override
  String get playerCount => 'Speler Telling';

  @override
  String get users => 'Gebruikers';

  @override
  String get enterUserName => 'Voer gebruiker naam in';

  @override
  String total(String score) {
    return 'Totaal: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Rondes: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults =>
      'Kyk na ons meervoudige spinner spel resultate!';

  @override
  String get allItemsUsed => 'Alle waarheid en durf items is gebruik!';

  @override
  String errorLoadingData(String error) {
    return 'Fout met laai data: $error';
  }

  @override
  String get dice1 => 'Dobbelsteen 1';

  @override
  String get dice2 => 'Dobbelsteen 2';

  @override
  String get resultUppercase => 'RESULTAAT';

  @override
  String score(String score) {
    return 'Punt: $score';
  }

  @override
  String turn(String user) {
    return '$user se Beurt';
  }
}
