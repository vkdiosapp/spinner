// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Koło';

  @override
  String get languages => 'Języki';

  @override
  String get continueButton => 'Kontynuuj';

  @override
  String get save => 'Zapisz';

  @override
  String get changeLanguage => 'Zmień Język';

  @override
  String get randomPicker => 'Koło Decyzji';

  @override
  String get randomPickerDescription =>
      'Utwórz niestandardowe koło z własnymi elementami';

  @override
  String get multiplayer => 'Bitwa Obrótów';

  @override
  String get multiplayerDescription =>
      'Graj z przyjaciółmi i rywalizuj w rundach';

  @override
  String get dice => 'Kostki';

  @override
  String get diceDescription => 'Rzuć dwiema kostkami i zobacz sumę';

  @override
  String get whoFirst => 'Wyścig do 10';

  @override
  String get whoFirstDescription => 'Graj z przyjaciółmi i rywalizuj w rundach';

  @override
  String get adsOn => 'Reklamy Włączone';

  @override
  String get adsOff => 'Reklamy Wyłączone';

  @override
  String get vibrationOn => 'Wibracje Włączone';

  @override
  String get vibrationOff => 'Wibracje Wyłączone';

  @override
  String get soundOn => 'Dźwięk Włączony';

  @override
  String get soundOff => 'Dźwięk Wyłączony';

  @override
  String get spinnerTitle => 'Tytuł Koła';

  @override
  String get enterSpinnerTitle => 'Wprowadź tytuł koła';

  @override
  String get start => 'Start';

  @override
  String get addItem => 'Dodaj Element';

  @override
  String get gameMode => 'Tryb Gry';

  @override
  String get singlePlayer => 'Pojedynczy Gracz';

  @override
  String get multiplayerMode => 'Bitwa Obrótów';

  @override
  String get howManyRounds => 'Ile Rund?';

  @override
  String get players => 'Gracze';

  @override
  String get addPlayer => 'Dodaj Gracza';

  @override
  String get enterPlayerName => 'Wprowadź imię gracza';

  @override
  String get truthDare => 'Prawda czy Wyzwanie';

  @override
  String get close => 'Zamknij';

  @override
  String get edit => 'Edytuj';

  @override
  String get reset => 'Resetuj';

  @override
  String get share => 'Udostępnij';

  @override
  String get truth => 'Prawda';

  @override
  String get dare => 'Wyzwanie';

  @override
  String get earned => 'ZAROBIONE';

  @override
  String get selected => 'WYBRANE';

  @override
  String get you => 'Ty';

  @override
  String get computer => 'Komputer';

  @override
  String get round => 'Runda';

  @override
  String get leave => 'Opuść';

  @override
  String get leaveGame => 'Opuścić Grę?';

  @override
  String get leaveGameMessage => 'Czy na pewno chcesz opuścić grę?';

  @override
  String get cancel => 'Anuluj';

  @override
  String get gameResults => 'Wyniki Gry';

  @override
  String get gold => 'Złoto';

  @override
  String get silver => 'Srebro';

  @override
  String get bronze => 'Brąz';

  @override
  String get watchAd => 'Obejrzyj Reklamę';

  @override
  String get toUnlock => 'aby odblokować';

  @override
  String get twoDice => 'Dwie Kostki';

  @override
  String get multiplication => 'Mnożenie';

  @override
  String get result => 'Wynik';

  @override
  String get spin => 'Obróć';

  @override
  String get randomPickerTitle => 'Koło Decyzji';

  @override
  String get spinner => 'Koło';

  @override
  String get level => 'Poziom';

  @override
  String get easy => 'Łatwy';

  @override
  String get medium => 'Średni';

  @override
  String get hard => 'Trudny';

  @override
  String get selectLevel => 'Wybierz Poziom';

  @override
  String get mathSpinner => 'Wyzwanie Matematyczne';

  @override
  String get mathSpinnerDescription =>
      'Ćwicz matematykę z zabawnymi wyzwaniami koła';

  @override
  String get spinnerItems => 'Elementy Koła';

  @override
  String get enterItemName => 'Wprowadź nazwę elementu';

  @override
  String get noItems =>
      'Brak elementów. Kliknij \"Dodaj Element\", aby dodać elementy.';

  @override
  String get pleaseAddAtLeastOneItem =>
      'Proszę dodać co najmniej jeden element';

  @override
  String duplicateItemName(String item) {
    return 'Zduplikowana nazwa elementu: \"$item\". Proszę użyć unikalnych nazw.';
  }

  @override
  String get pleaseAddAtLeastOneUser =>
      'Proszę dodać co najmniej jednego użytkownika';

  @override
  String duplicateUserName(String user) {
    return 'Zduplikowana nazwa użytkownika: \"$user\". Proszę użyć unikalnych nazw.';
  }

  @override
  String get mathSpinnerComingSoon => 'Strona Wyzwania Matematycznego wkrótce!';

  @override
  String errorSharing(String error) {
    return 'Błąd podczas udostępniania: $error';
  }

  @override
  String get playerCount => 'Liczba Graczy';

  @override
  String get users => 'Użytkownicy';

  @override
  String get enterUserName => 'Wprowadź nazwę użytkownika';

  @override
  String total(String score) {
    return 'Suma: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Rundy: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults => 'Sprawdź wyniki naszej gry koła Bitwa Obrótów!';

  @override
  String get allItemsUsed =>
      'Wszystkie elementy prawdy i wyzwania zostały użyte!';

  @override
  String errorLoadingData(String error) {
    return 'Błąd podczas ładowania danych: $error';
  }

  @override
  String get dice1 => 'Kostka 1';

  @override
  String get dice2 => 'Kostka 2';

  @override
  String get resultUppercase => 'WYNIK';

  @override
  String score(String score) {
    return 'Wynik: $score';
  }

  @override
  String turn(String user) {
    return 'Kolej $user';
  }
}
