// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Diller';

  @override
  String get continueButton => 'Devam Et';

  @override
  String get save => 'Kaydet';

  @override
  String get changeLanguage => 'Dili Değiştir';

  @override
  String get randomPicker => 'Rastgele Seçici';

  @override
  String get randomPickerDescription =>
      'Kendi öğelerinizle özel bir spinner oluşturun';

  @override
  String get multiplayer => 'Çok Oyunculu';

  @override
  String get multiplayerDescription =>
      'Arkadaşlarınızla oynayın ve raundlarda yarışın';

  @override
  String get dice => 'Zar';

  @override
  String get diceDescription => 'İki zar atın ve toplamı görün';

  @override
  String get whoFirst => 'Kim Önce';

  @override
  String get whoFirstDescription =>
      'Arkadaşlarınızla oynayın ve raundlarda yarışın';

  @override
  String get adsOn => 'Reklamlar Açık';

  @override
  String get adsOff => 'Reklamlar Kapalı';

  @override
  String get vibrationOn => 'Titreşim Açık';

  @override
  String get vibrationOff => 'Titreşim Kapalı';

  @override
  String get soundOn => 'Ses Açık';

  @override
  String get soundOff => 'Ses Kapalı';

  @override
  String get spinnerTitle => 'Spinner Başlığı';

  @override
  String get enterSpinnerTitle => 'Spinner başlığını girin';

  @override
  String get start => 'Başlat';

  @override
  String get addItem => 'Öğe Ekle';

  @override
  String get gameMode => 'Oyun Modu';

  @override
  String get singlePlayer => 'Tek Oyunculu';

  @override
  String get multiplayerMode => 'Çok Oyunculu';

  @override
  String get howManyRounds => 'Kaç Raund?';

  @override
  String get players => 'Oyuncular';

  @override
  String get addPlayer => 'Oyuncu Ekle';

  @override
  String get enterPlayerName => 'Oyuncu adını girin';

  @override
  String get truthDare => 'Doğruluk mu Cesaret mi';

  @override
  String get close => 'Kapat';

  @override
  String get edit => 'Düzenle';

  @override
  String get reset => 'Sıfırla';

  @override
  String get share => 'Paylaş';

  @override
  String get truth => 'Doğruluk';

  @override
  String get dare => 'Cesaret';

  @override
  String get earned => 'KAZANILDI';

  @override
  String get selected => 'SEÇİLDİ';

  @override
  String get you => 'Sen';

  @override
  String get computer => 'Bilgisayar';

  @override
  String get round => 'Raund';

  @override
  String get leave => 'Ayrıl';

  @override
  String get leaveGame => 'Oyundan Ayrıl?';

  @override
  String get leaveGameMessage =>
      'Oyundan ayrılmak istediğinizden emin misiniz?';

  @override
  String get cancel => 'İptal';

  @override
  String get gameResults => 'Oyun Sonuçları';

  @override
  String get gold => 'Altın';

  @override
  String get silver => 'Gümüş';

  @override
  String get bronze => 'Bronz';

  @override
  String get watchAd => 'Reklam İzle';

  @override
  String get toUnlock => 'kilidini açmak için';

  @override
  String get twoDice => 'İki Zar';

  @override
  String get multiplication => 'Çarpma';

  @override
  String get result => 'Sonuç';

  @override
  String get spin => 'Döndür';

  @override
  String get randomPickerTitle => 'Rastgele Seçici';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Seviye';

  @override
  String get easy => 'Kolay';

  @override
  String get medium => 'Orta';

  @override
  String get hard => 'Zor';

  @override
  String get selectLevel => 'Seviye Seç';

  @override
  String get mathSpinner => 'Matematik Spinner';

  @override
  String get mathSpinnerDescription =>
      'Eğlenceli spinner zorluklarıyla matematik pratiği yapın';

  @override
  String get spinnerItems => 'Spinner Öğeleri';

  @override
  String get enterItemName => 'Öğe adını girin';

  @override
  String get noItems => 'Öğe yok. Öğe eklemek için \"Öğe Ekle\"ye tıklayın.';

  @override
  String get pleaseAddAtLeastOneItem => 'Lütfen en az bir öğe ekleyin';

  @override
  String duplicateItemName(String item) {
    return 'Yinelenen öğe adı: \"$item\". Lütfen benzersiz adlar kullanın.';
  }

  @override
  String get pleaseAddAtLeastOneUser => 'Lütfen en az bir kullanıcı ekleyin';

  @override
  String duplicateUserName(String user) {
    return 'Yinelenen kullanıcı adı: \"$user\". Lütfen benzersiz adlar kullanın.';
  }

  @override
  String get mathSpinnerComingSoon => 'Matematik Spinner sayfası yakında!';

  @override
  String errorSharing(String error) {
    return 'Paylaşma hatası: $error';
  }

  @override
  String get playerCount => 'Oyuncu Sayısı';

  @override
  String get users => 'Kullanıcılar';

  @override
  String get enterUserName => 'Kullanıcı adını girin';

  @override
  String total(String score) {
    return 'Toplam: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Rauntlar: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults =>
      'Çok oyunculu spinner oyunu sonuçlarımıza bakın!';

  @override
  String get allItemsUsed => 'Tüm doğruluk ve cesaret öğeleri kullanıldı!';

  @override
  String errorLoadingData(String error) {
    return 'Veri yükleme hatası: $error';
  }

  @override
  String get dice1 => 'Zar 1';

  @override
  String get dice2 => 'Zar 2';

  @override
  String get resultUppercase => 'SONUÇ';

  @override
  String score(String score) {
    return 'Skor: $score';
  }

  @override
  String turn(String user) {
    return '$user Sırası';
  }
}
