// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Lingue';

  @override
  String get continueButton => 'Continua';

  @override
  String get save => 'Salva';

  @override
  String get changeLanguage => 'Cambia Lingua';

  @override
  String get randomPicker => 'Giratore di Decisioni';

  @override
  String get randomPickerDescription =>
      'Crea uno spinner personalizzato con i tuoi elementi';

  @override
  String get multiplayer => 'Battaglia di Rotazione';

  @override
  String get multiplayerDescription => 'Gioca con gli amici e competi in round';

  @override
  String get dice => 'Dadi';

  @override
  String get diceDescription => 'Lancia due dadi e vedi il totale';

  @override
  String get whoFirst => 'Corsa a 10';

  @override
  String get whoFirstDescription => 'Gioca con gli amici e competi in round';

  @override
  String get adsOn => 'Pubblicità Attive';

  @override
  String get adsOff => 'Pubblicità Disattivate';

  @override
  String get vibrationOn => 'Vibrazione Attiva';

  @override
  String get vibrationOff => 'Vibrazione Disattivata';

  @override
  String get soundOn => 'Suono Attivo';

  @override
  String get soundOff => 'Suono Disattivato';

  @override
  String get spinnerTitle => 'Titolo Spinner';

  @override
  String get enterSpinnerTitle => 'Inserisci il titolo dello spinner';

  @override
  String get start => 'Inizia';

  @override
  String get addItem => 'Aggiungi Elemento';

  @override
  String get gameMode => 'Modalità di Gioco';

  @override
  String get singlePlayer => 'Giocatore Singolo';

  @override
  String get multiplayerMode => 'Battaglia di Rotazione';

  @override
  String get howManyRounds => 'Quanti Round?';

  @override
  String get players => 'Giocatori';

  @override
  String get addPlayer => 'Aggiungi Giocatore';

  @override
  String get enterPlayerName => 'Inserisci il nome del giocatore';

  @override
  String get truthDare => 'Verità o Coraggio';

  @override
  String get close => 'Chiudi';

  @override
  String get edit => 'Modifica';

  @override
  String get reset => 'Reimposta';

  @override
  String get share => 'Condividi';

  @override
  String get truth => 'Verità';

  @override
  String get dare => 'Coraggio';

  @override
  String get earned => 'GUADAGNATO';

  @override
  String get selected => 'SELEZIONATO';

  @override
  String get you => 'Tu';

  @override
  String get computer => 'Computer';

  @override
  String get round => 'Round';

  @override
  String get leave => 'Esci';

  @override
  String get leaveGame => 'Uscire dal Gioco?';

  @override
  String get leaveGameMessage => 'Sei sicuro di voler uscire dal gioco?';

  @override
  String get cancel => 'Annulla';

  @override
  String get gameResults => 'Risultati del Gioco';

  @override
  String get gold => 'Oro';

  @override
  String get silver => 'Argento';

  @override
  String get bronze => 'Bronzo';

  @override
  String get watchAd => 'Guarda la Pubblicità';

  @override
  String get toUnlock => 'per sbloccare';

  @override
  String get twoDice => 'Due Dadi';

  @override
  String get multiplication => 'Moltiplicazione';

  @override
  String get result => 'Risultato';

  @override
  String get spin => 'Gira';

  @override
  String get randomPickerTitle => 'Giratore di Decisioni';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Livello';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difficile';

  @override
  String get selectLevel => 'Seleziona Livello';

  @override
  String get mathSpinner => 'Sfida Matematica';

  @override
  String get mathSpinnerDescription =>
      'Pratica la matematica con sfide spinner divertenti';

  @override
  String get spinnerItems => 'Elementi dello Spinner';

  @override
  String get enterItemName => 'Inserisci il nome dell\'elemento';

  @override
  String get noItems =>
      'Nessun elemento. Fai clic su \"Add Item\" per aggiungere elementi.';

  @override
  String get pleaseAddAtLeastOneItem => 'Aggiungi almeno un elemento';

  @override
  String duplicateItemName(String item) {
    return 'Nome elemento duplicato: \"$item\". Usa nomi univoci.';
  }

  @override
  String get pleaseAddAtLeastOneUser => 'Aggiungi almeno un utente';

  @override
  String duplicateUserName(String user) {
    return 'Nome utente duplicato: \"$user\". Usa nomi univoci.';
  }

  @override
  String get mathSpinnerComingSoon => 'Pagina Sfida Matematica in arrivo!';

  @override
  String errorSharing(String error) {
    return 'Errore nella condivisione: $error';
  }

  @override
  String get playerCount => 'Numero di Giocatori';

  @override
  String get users => 'Utenti';

  @override
  String get enterUserName => 'Inserisci il nome utente';

  @override
  String total(String score) {
    return 'Totale: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Round: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults =>
      'Guarda i risultati del nostro gioco spinner Battaglia di Rotazione!';

  @override
  String get allItemsUsed =>
      'Tutti gli elementi verità e sfida sono stati usati!';

  @override
  String errorLoadingData(String error) {
    return 'Errore nel caricamento dei dati: $error';
  }

  @override
  String get dice1 => 'Dado 1';

  @override
  String get dice2 => 'Dado 2';

  @override
  String get resultUppercase => 'RISULTATO';

  @override
  String score(String score) {
    return 'Punteggio: $score';
  }

  @override
  String turn(String user) {
    return 'Turno di $user';
  }
}
