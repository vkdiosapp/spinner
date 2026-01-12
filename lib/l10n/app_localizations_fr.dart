// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Langues';

  @override
  String get continueButton => 'Continuer';

  @override
  String get save => 'Enregistrer';

  @override
  String get changeLanguage => 'Changer la langue';

  @override
  String get randomPicker => 'Girouette de Décision';

  @override
  String get randomPickerDescription =>
      'Créez un spinner personnalisé avec vos propres éléments';

  @override
  String get multiplayer => 'Bataille de Rotation';

  @override
  String get multiplayerDescription =>
      'Jouez avec des amis et competez en rounds';

  @override
  String get dice => 'Dés';

  @override
  String get diceDescription => 'Lancez deux dés et voyez le total';

  @override
  String get whoFirst => 'Course vers 10';

  @override
  String get whoFirstDescription => 'Jouez avec des amis et competez en rounds';

  @override
  String get adsOn => 'Publicités Activées';

  @override
  String get adsOff => 'Publicités Désactivées';

  @override
  String get vibrationOn => 'Vibration Activée';

  @override
  String get vibrationOff => 'Vibration Désactivée';

  @override
  String get soundOn => 'Son Activé';

  @override
  String get soundOff => 'Son Désactivé';

  @override
  String get spinnerTitle => 'Titre du Spinner';

  @override
  String get enterSpinnerTitle => 'Entrez le titre du spinner';

  @override
  String get start => 'Démarrer';

  @override
  String get addItem => 'Ajouter un Élément';

  @override
  String get gameMode => 'Mode de Jeu';

  @override
  String get singlePlayer => 'Joueur Unique';

  @override
  String get multiplayerMode => 'Multijoueur';

  @override
  String get howManyRounds => 'Combien de Rounds?';

  @override
  String get players => 'Joueurs';

  @override
  String get addPlayer => 'Ajouter un Joueur';

  @override
  String get enterPlayerName => 'Entrez le nom du joueur';

  @override
  String get truthDare => 'Action ou Vérité';

  @override
  String get close => 'Fermer';

  @override
  String get edit => 'Modifier';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get share => 'Partager';

  @override
  String get truth => 'Vérité';

  @override
  String get dare => 'Action';

  @override
  String get earned => 'GAGNÉ';

  @override
  String get selected => 'SÉLECTIONNÉ';

  @override
  String get you => 'Vous';

  @override
  String get computer => 'Ordinateur';

  @override
  String get round => 'Round';

  @override
  String get leave => 'Quitter';

  @override
  String get leaveGame => 'Quitter le Jeu?';

  @override
  String get leaveGameMessage => 'Êtes-vous sûr de vouloir quitter le jeu?';

  @override
  String get cancel => 'Annuler';

  @override
  String get gameResults => 'Résultats du Jeu';

  @override
  String get gold => 'Or';

  @override
  String get silver => 'Argent';

  @override
  String get bronze => 'Bronze';

  @override
  String get watchAd => 'Regarder la Pub';

  @override
  String get toUnlock => 'pour débloquer';

  @override
  String get twoDice => 'Deux Dés';

  @override
  String get multiplication => 'Multiplication';

  @override
  String get result => 'Résultat';

  @override
  String get spin => 'Tourner';

  @override
  String get randomPickerTitle => 'Girouette de Décision';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Niveau';

  @override
  String get easy => 'Facile';

  @override
  String get medium => 'Moyen';

  @override
  String get hard => 'Difficile';

  @override
  String get selectLevel => 'Sélectionner le Niveau';

  @override
  String get mathSpinner => 'Défi Mathématique';

  @override
  String get mathSpinnerDescription =>
      'Pratiquez les mathématiques avec des défis de spinner amusants';

  @override
  String get spinnerItems => 'Éléments du Spinner';

  @override
  String get enterItemName => 'Entrez le nom de l\'élément';

  @override
  String get noItems =>
      'Aucun élément. Cliquez sur \"Ajouter un élément\" pour ajouter des éléments.';

  @override
  String get pleaseAddAtLeastOneItem => 'Veuillez ajouter au moins un élément';

  @override
  String duplicateItemName(String item) {
    return 'Nom d\'élément en double: \"$item\". Veuillez utiliser des noms uniques.';
  }

  @override
  String get pleaseAddAtLeastOneUser =>
      'Veuillez ajouter au moins un utilisateur';

  @override
  String duplicateUserName(String user) {
    return 'Nom d\'utilisateur en double: \"$user\". Veuillez utiliser des noms uniques.';
  }

  @override
  String get mathSpinnerComingSoon => 'Page Défi Mathématique à venir bientôt!';

  @override
  String errorSharing(String error) {
    return 'Erreur lors du partage: $error';
  }

  @override
  String get playerCount => 'Nombre de Joueurs';

  @override
  String get users => 'Utilisateurs';

  @override
  String get enterUserName => 'Entrez le nom d\'utilisateur';

  @override
  String total(String score) {
    return 'Total: $score';
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
      'Découvrez les résultats de notre jeu de spinner Bataille de Rotation!';

  @override
  String get allItemsUsed =>
      'Tous les éléments de vérité et d\'action ont été utilisés!';

  @override
  String errorLoadingData(String error) {
    return 'Erreur lors du chargement des données: $error';
  }

  @override
  String get dice1 => 'Dé 1';

  @override
  String get dice2 => 'Dé 2';

  @override
  String get resultUppercase => 'RÉSULTAT';

  @override
  String score(String score) {
    return 'Score: $score';
  }

  @override
  String turn(String user) {
    return 'Tour de $user';
  }
}
