// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Ukrainian (`uk`).
class AppLocalizationsUk extends AppLocalizations {
  AppLocalizationsUk([String locale = 'uk']) : super(locale);

  @override
  String get appTitle => 'Спіннер';

  @override
  String get languages => 'Мови';

  @override
  String get continueButton => 'Продовжити';

  @override
  String get save => 'Зберегти';

  @override
  String get changeLanguage => 'Змінити Мову';

  @override
  String get randomPicker => 'Випадковий Вибір';

  @override
  String get randomPickerDescription =>
      'Створіть користувацький спіннер зі своїми елементами';

  @override
  String get multiplayer => 'Мультиплеєр';

  @override
  String get multiplayerDescription =>
      'Грайте з друзями та змагайтеся в раундах';

  @override
  String get dice => 'Кістки';

  @override
  String get diceDescription => 'Киньте дві кістки та подивіться суму';

  @override
  String get whoFirst => 'Хто Перший';

  @override
  String get whoFirstDescription => 'Грайте з друзями та змагайтеся в раундах';

  @override
  String get adsOn => 'Реклама Увімкнена';

  @override
  String get adsOff => 'Реклама Вимкнена';

  @override
  String get vibrationOn => 'Вібрація Увімкнена';

  @override
  String get vibrationOff => 'Вібрація Вимкнена';

  @override
  String get soundOn => 'Звук Увімкнено';

  @override
  String get soundOff => 'Звук Вимкнено';

  @override
  String get spinnerTitle => 'Назва Спіннера';

  @override
  String get enterSpinnerTitle => 'Введіть назву спіннера';

  @override
  String get start => 'Почати';

  @override
  String get addItem => 'Додати Елемент';

  @override
  String get gameMode => 'Режим Гри';

  @override
  String get singlePlayer => 'Одиночна Гра';

  @override
  String get multiplayerMode => 'Мультиплеєр';

  @override
  String get howManyRounds => 'Скільки Раундів?';

  @override
  String get players => 'Гравці';

  @override
  String get addPlayer => 'Додати Гравця';

  @override
  String get enterPlayerName => 'Введіть ім\'я гравця';

  @override
  String get truthDare => 'Правда чи Дія';

  @override
  String get close => 'Закрити';

  @override
  String get edit => 'Редагувати';

  @override
  String get reset => 'Скинути';

  @override
  String get share => 'Поділитися';

  @override
  String get truth => 'Правда';

  @override
  String get dare => 'Дія';

  @override
  String get earned => 'ЗАРОБЛЕНО';

  @override
  String get selected => 'ВИБРАНО';

  @override
  String get you => 'Ви';

  @override
  String get computer => 'Комп\'ютер';

  @override
  String get round => 'Раунд';

  @override
  String get leave => 'Вийти';

  @override
  String get leaveGame => 'Вийти з Гри?';

  @override
  String get leaveGameMessage => 'Ви впевнені, що хочете вийти з гри?';

  @override
  String get cancel => 'Скасувати';

  @override
  String get gameResults => 'Результати Гри';

  @override
  String get gold => 'Золото';

  @override
  String get silver => 'Срібло';

  @override
  String get bronze => 'Бронза';

  @override
  String get watchAd => 'Дивитися Рекламу';

  @override
  String get toUnlock => 'щоб розблокувати';

  @override
  String get twoDice => 'Дві Кістки';

  @override
  String get multiplication => 'Множення';

  @override
  String get result => 'Результат';

  @override
  String get spin => 'Крутити';

  @override
  String get randomPickerTitle => 'Випадковий Вибір';

  @override
  String get spinner => 'Спіннер';

  @override
  String get level => 'Рівень';

  @override
  String get easy => 'Легкий';

  @override
  String get medium => 'Середній';

  @override
  String get hard => 'Важкий';

  @override
  String get selectLevel => 'Вибрати Рівень';

  @override
  String get mathSpinner => 'Математичний Спіннер';

  @override
  String get mathSpinnerDescription =>
      'Практикуйте математику з веселими завданнями спіннера';

  @override
  String get spinnerItems => 'Елементи Спіннера';

  @override
  String get enterItemName => 'Введіть назву елемента';

  @override
  String get noItems =>
      'Немає елементів. Натисніть \"Додати елемент\", щоб додати елементи.';

  @override
  String get pleaseAddAtLeastOneItem =>
      'Будь ласка, додайте принаймні один елемент';

  @override
  String duplicateItemName(String item) {
    return 'Дубльована назва елемента: \"$item\". Будь ласка, використовуйте унікальні імена.';
  }

  @override
  String get pleaseAddAtLeastOneUser =>
      'Будь ласка, додайте принаймні одного користувача';

  @override
  String duplicateUserName(String user) {
    return 'Дубльоване ім\'я користувача: \"$user\". Будь ласка, використовуйте унікальні імена.';
  }

  @override
  String get mathSpinnerComingSoon =>
      'Сторінка Математичного Спіннера незабаром!';

  @override
  String errorSharing(String error) {
    return 'Помилка при обміні: $error';
  }

  @override
  String get playerCount => 'Кількість Гравців';

  @override
  String get users => 'Користувачі';

  @override
  String get enterUserName => 'Введіть ім\'я користувача';

  @override
  String total(String score) {
    return 'Всього: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Раунди: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'Р$round: $score';
  }

  @override
  String get checkOutResults =>
      'Перевірте результати нашої багатокористувацької гри зі спіннером!';

  @override
  String get allItemsUsed => 'Всі елементи правди та виклику були використані!';

  @override
  String errorLoadingData(String error) {
    return 'Помилка при завантаженні даних: $error';
  }

  @override
  String get dice1 => 'Кістка 1';

  @override
  String get dice2 => 'Кістка 2';

  @override
  String get resultUppercase => 'РЕЗУЛЬТАТ';

  @override
  String score(String score) {
    return 'Очки: $score';
  }

  @override
  String turn(String user) {
    return 'Хід $user';
  }
}
