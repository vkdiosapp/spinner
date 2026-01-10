// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Спиннер';

  @override
  String get languages => 'Языки';

  @override
  String get continueButton => 'Продолжить';

  @override
  String get save => 'Сохранить';

  @override
  String get changeLanguage => 'Изменить Язык';

  @override
  String get randomPicker => 'Случайный Выбор';

  @override
  String get randomPickerDescription =>
      'Создайте пользовательский спиннер со своими элементами';

  @override
  String get multiplayer => 'Мультиплеер';

  @override
  String get multiplayerDescription =>
      'Играйте с друзьями и соревнуйтесь в раундах';

  @override
  String get dice => 'Кости';

  @override
  String get diceDescription => 'Бросьте две кости и посмотрите сумму';

  @override
  String get whoFirst => 'Кто Первый';

  @override
  String get whoFirstDescription =>
      'Играйте с друзьями и соревнуйтесь в раундах';

  @override
  String get adsOn => 'Реклама Включена';

  @override
  String get adsOff => 'Реклама Выключена';

  @override
  String get vibrationOn => 'Вибрация Включена';

  @override
  String get vibrationOff => 'Вибрация Выключена';

  @override
  String get soundOn => 'Звук Включен';

  @override
  String get soundOff => 'Звук Выключен';

  @override
  String get spinnerTitle => 'Название Спиннера';

  @override
  String get enterSpinnerTitle => 'Введите название спиннера';

  @override
  String get start => 'Начать';

  @override
  String get addItem => 'Добавить Элемент';

  @override
  String get gameMode => 'Режим Игры';

  @override
  String get singlePlayer => 'Одиночная Игра';

  @override
  String get multiplayerMode => 'Мультиплеер';

  @override
  String get howManyRounds => 'Сколько Раундов?';

  @override
  String get players => 'Игроки';

  @override
  String get addPlayer => 'Добавить Игрока';

  @override
  String get enterPlayerName => 'Введите имя игрока';

  @override
  String get truthDare => 'Правда или Действие';

  @override
  String get close => 'Закрыть';

  @override
  String get edit => 'Редактировать';

  @override
  String get reset => 'Сбросить';

  @override
  String get share => 'Поделиться';

  @override
  String get truth => 'Правда';

  @override
  String get dare => 'Действие';

  @override
  String get earned => 'ЗАРАБОТАНО';

  @override
  String get selected => 'ВЫБРАНО';

  @override
  String get you => 'Вы';

  @override
  String get computer => 'Компьютер';

  @override
  String get round => 'Раунд';

  @override
  String get leave => 'Выйти';

  @override
  String get leaveGame => 'Выйти из Игры?';

  @override
  String get leaveGameMessage => 'Вы уверены, что хотите выйти из игры?';

  @override
  String get cancel => 'Отмена';

  @override
  String get gameResults => 'Результаты Игры';

  @override
  String get gold => 'Золото';

  @override
  String get silver => 'Серебро';

  @override
  String get bronze => 'Бронза';

  @override
  String get watchAd => 'Смотреть Рекламу';

  @override
  String get toUnlock => 'чтобы разблокировать';

  @override
  String get twoDice => 'Две Кости';

  @override
  String get multiplication => 'Умножение';

  @override
  String get result => 'Результат';

  @override
  String get spin => 'Крутить';

  @override
  String get randomPickerTitle => 'Случайный Выбор';

  @override
  String get spinner => 'Спиннер';

  @override
  String get level => 'Уровень';

  @override
  String get easy => 'Легкий';

  @override
  String get medium => 'Средний';

  @override
  String get hard => 'Сложный';

  @override
  String get selectLevel => 'Выбрать Уровень';

  @override
  String get mathSpinner => 'Математический Спиннер';

  @override
  String get mathSpinnerDescription =>
      'Практикуйте математику с веселыми заданиями спиннера';

  @override
  String get spinnerItems => 'Элементы Спиннера';

  @override
  String get enterItemName => 'Введите название элемента';

  @override
  String get noItems =>
      'Нет элементов. Нажмите \"Добавить элемент\", чтобы добавить элементы.';

  @override
  String get pleaseAddAtLeastOneItem =>
      'Пожалуйста, добавьте хотя бы один элемент';

  @override
  String duplicateItemName(String item) {
    return 'Дублирующееся название элемента: \"$item\". Пожалуйста, используйте уникальные имена.';
  }

  @override
  String get pleaseAddAtLeastOneUser =>
      'Пожалуйста, добавьте хотя бы одного пользователя';

  @override
  String duplicateUserName(String user) {
    return 'Дублирующееся имя пользователя: \"$user\". Пожалуйста, используйте уникальные имена.';
  }

  @override
  String get mathSpinnerComingSoon =>
      'Страница Математического Спиннера скоро появится!';

  @override
  String errorSharing(String error) {
    return 'Ошибка при обмене: $error';
  }

  @override
  String get playerCount => 'Количество Игроков';

  @override
  String get users => 'Пользователи';

  @override
  String get enterUserName => 'Введите имя пользователя';

  @override
  String total(String score) {
    return 'Всего: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Раунды: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'Р$round: $score';
  }

  @override
  String get checkOutResults =>
      'Посмотрите результаты нашей многопользовательской игры со спиннером!';

  @override
  String get allItemsUsed => 'Все элементы правды и вызова были использованы!';

  @override
  String errorLoadingData(String error) {
    return 'Ошибка при загрузке данных: $error';
  }

  @override
  String get dice1 => 'Кость 1';

  @override
  String get dice2 => 'Кость 2';

  @override
  String get resultUppercase => 'РЕЗУЛЬТАТ';

  @override
  String score(String score) {
    return 'Счет: $score';
  }

  @override
  String turn(String user) {
    return 'Ход $user';
  }
}
