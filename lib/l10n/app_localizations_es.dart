// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Idiomas';

  @override
  String get continueButton => 'Continuar';

  @override
  String get save => 'Guardar';

  @override
  String get changeLanguage => 'Cambiar Idioma';

  @override
  String get randomPicker => 'Giratorio de Decisiones';

  @override
  String get randomPickerDescription =>
      'Crea un spinner personalizado con tus propios elementos';

  @override
  String get multiplayer => 'Batalla de Giro';

  @override
  String get multiplayerDescription => 'Juega con amigos y compite en rondas';

  @override
  String get dice => 'Dados';

  @override
  String get diceDescription => 'Tira dos dados y ve el total';

  @override
  String get whoFirst => 'Carrera a 10';

  @override
  String get whoFirstDescription => 'Juega con amigos y compite en rondas';

  @override
  String get adsOn => 'Anuncios Activados';

  @override
  String get adsOff => 'Anuncios Desactivados';

  @override
  String get vibrationOn => 'Vibración Activada';

  @override
  String get vibrationOff => 'Vibración Desactivada';

  @override
  String get soundOn => 'Sonido Activado';

  @override
  String get soundOff => 'Sonido Desactivado';

  @override
  String get spinnerTitle => 'Título del Spinner';

  @override
  String get enterSpinnerTitle => 'Ingresa el título del spinner';

  @override
  String get start => 'Iniciar';

  @override
  String get addItem => 'Agregar Elemento';

  @override
  String get gameMode => 'Modo de Juego';

  @override
  String get singlePlayer => 'Un Jugador';

  @override
  String get multiplayerMode => 'Batalla de Giro';

  @override
  String get howManyRounds => '¿Cuántas Rondas?';

  @override
  String get players => 'Jugadores';

  @override
  String get addPlayer => 'Agregar Jugador';

  @override
  String get enterPlayerName => 'Ingresa el nombre del jugador';

  @override
  String get truthDare => 'Verdad o Reto';

  @override
  String get close => 'Cerrar';

  @override
  String get edit => 'Editar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get share => 'Compartir';

  @override
  String get truth => 'Verdad';

  @override
  String get dare => 'Reto';

  @override
  String get earned => 'GANADO';

  @override
  String get selected => 'SELECCIONADO';

  @override
  String get you => 'Tú';

  @override
  String get computer => 'Computadora';

  @override
  String get round => 'Ronda';

  @override
  String get leave => 'Salir';

  @override
  String get leaveGame => '¿Salir del Juego?';

  @override
  String get leaveGameMessage =>
      '¿Estás seguro de que quieres salir del juego?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get gameResults => 'Resultados del Juego';

  @override
  String get gold => 'Oro';

  @override
  String get silver => 'Plata';

  @override
  String get bronze => 'Bronce';

  @override
  String get watchAd => 'Ver Anuncio';

  @override
  String get toUnlock => 'para desbloquear';

  @override
  String get twoDice => 'Dos Dados';

  @override
  String get multiplication => 'Multiplicación';

  @override
  String get result => 'Resultado';

  @override
  String get spin => 'Girar';

  @override
  String get randomPickerTitle => 'Giratorio de Decisiones';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Nivel';

  @override
  String get easy => 'Fácil';

  @override
  String get medium => 'Medio';

  @override
  String get hard => 'Difícil';

  @override
  String get selectLevel => 'Seleccionar Nivel';

  @override
  String get mathSpinner => 'Desafío Matemático';

  @override
  String get mathSpinnerDescription =>
      'Practica matemáticas con desafíos divertidos de spinner';

  @override
  String get spinnerItems => 'Elementos del Spinner';

  @override
  String get enterItemName => 'Ingresa el nombre del elemento';

  @override
  String get noItems =>
      'No hay elementos. Haz clic en \"Agregar Elemento\" para agregar elementos.';

  @override
  String get pleaseAddAtLeastOneItem => 'Por favor agrega al menos un elemento';

  @override
  String duplicateItemName(String item) {
    return 'Nombre de elemento duplicado: \"$item\". Por favor usa nombres únicos.';
  }

  @override
  String get pleaseAddAtLeastOneUser => 'Por favor agrega al menos un usuario';

  @override
  String duplicateUserName(String user) {
    return 'Nombre de usuario duplicado: \"$user\". Por favor usa nombres únicos.';
  }

  @override
  String get mathSpinnerComingSoon =>
      '¡La página del Desafío Matemático llegará pronto!';

  @override
  String errorSharing(String error) {
    return 'Error al compartir: $error';
  }

  @override
  String get playerCount => 'Número de Jugadores';

  @override
  String get users => 'Usuarios';

  @override
  String get enterUserName => 'Ingresa el nombre de usuario';

  @override
  String total(String score) {
    return 'Total: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Rondas: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults =>
      '¡Mira los resultados de nuestro juego de spinner Batalla de Giro!';

  @override
  String get allItemsUsed =>
      '¡Todos los elementos de verdad o reto han sido usados!';

  @override
  String errorLoadingData(String error) {
    return 'Error al cargar datos: $error';
  }

  @override
  String get dice1 => 'Dado 1';

  @override
  String get dice2 => 'Dado 2';

  @override
  String get resultUppercase => 'RESULTADO';

  @override
  String score(String score) {
    return 'Puntuación: $score';
  }

  @override
  String turn(String user) {
    return 'Turno de $user';
  }
}
