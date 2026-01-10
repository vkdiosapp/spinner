// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Spinner';

  @override
  String get languages => 'Bahasa';

  @override
  String get continueButton => 'Lanjutkan';

  @override
  String get save => 'Simpan';

  @override
  String get changeLanguage => 'Ubah Bahasa';

  @override
  String get randomPicker => 'Pemilih Acak';

  @override
  String get randomPickerDescription =>
      'Buat spinner kustom dengan item Anda sendiri';

  @override
  String get multiplayer => 'Multiplayer';

  @override
  String get multiplayerDescription =>
      'Bermain dengan teman dan bersaing dalam putaran';

  @override
  String get dice => 'Dadu';

  @override
  String get diceDescription => 'Lempar dua dadu dan lihat totalnya';

  @override
  String get whoFirst => 'Siapa Pertama';

  @override
  String get whoFirstDescription =>
      'Bermain dengan teman dan bersaing dalam putaran';

  @override
  String get adsOn => 'Iklan Aktif';

  @override
  String get adsOff => 'Iklan Nonaktif';

  @override
  String get vibrationOn => 'Getaran Aktif';

  @override
  String get vibrationOff => 'Getaran Nonaktif';

  @override
  String get soundOn => 'Suara Aktif';

  @override
  String get soundOff => 'Suara Nonaktif';

  @override
  String get spinnerTitle => 'Judul Spinner';

  @override
  String get enterSpinnerTitle => 'Masukkan judul spinner';

  @override
  String get start => 'Mulai';

  @override
  String get addItem => 'Tambah Item';

  @override
  String get gameMode => 'Mode Permainan';

  @override
  String get singlePlayer => 'Pemain Tunggal';

  @override
  String get multiplayerMode => 'Multiplayer';

  @override
  String get howManyRounds => 'Berapa Banyak Putaran?';

  @override
  String get players => 'Pemain';

  @override
  String get addPlayer => 'Tambah Pemain';

  @override
  String get enterPlayerName => 'Masukkan nama pemain';

  @override
  String get truthDare => 'Truth & Dare';

  @override
  String get close => 'Tutup';

  @override
  String get edit => 'Edit';

  @override
  String get reset => 'Reset';

  @override
  String get share => 'Bagikan';

  @override
  String get truth => 'Truth';

  @override
  String get dare => 'Dare';

  @override
  String get earned => 'DIPEROLEH';

  @override
  String get selected => 'DIPILIH';

  @override
  String get you => 'Anda';

  @override
  String get computer => 'Komputer';

  @override
  String get round => 'Putaran';

  @override
  String get leave => 'Keluar';

  @override
  String get leaveGame => 'Keluar dari Permainan?';

  @override
  String get leaveGameMessage =>
      'Apakah Anda yakin ingin keluar dari permainan?';

  @override
  String get cancel => 'Batal';

  @override
  String get gameResults => 'Hasil Permainan';

  @override
  String get gold => 'Emas';

  @override
  String get silver => 'Perak';

  @override
  String get bronze => 'Perunggu';

  @override
  String get watchAd => 'Tonton Iklan';

  @override
  String get toUnlock => 'untuk membuka';

  @override
  String get twoDice => 'Dua Dadu';

  @override
  String get multiplication => 'Perkalian';

  @override
  String get result => 'Hasil';

  @override
  String get spin => 'Putar';

  @override
  String get randomPickerTitle => 'Pemilih Acak';

  @override
  String get spinner => 'Spinner';

  @override
  String get level => 'Level';

  @override
  String get easy => 'Mudah';

  @override
  String get medium => 'Sedang';

  @override
  String get hard => 'Sulit';

  @override
  String get selectLevel => 'Pilih Level';

  @override
  String get mathSpinner => 'Spinner Matematika';

  @override
  String get mathSpinnerDescription =>
      'Berlatih matematika dengan tantangan spinner yang menyenangkan';

  @override
  String get spinnerItems => 'Item Spinner';

  @override
  String get enterItemName => 'Masukkan nama item';

  @override
  String get noItems =>
      'Tidak ada item. Klik \"Add Item\" untuk menambahkan item.';

  @override
  String get pleaseAddAtLeastOneItem => 'Harap tambahkan setidaknya satu item';

  @override
  String duplicateItemName(String item) {
    return 'Nama item duplikat: \"$item\". Harap gunakan nama yang unik.';
  }

  @override
  String get pleaseAddAtLeastOneUser =>
      'Harap tambahkan setidaknya satu pengguna';

  @override
  String duplicateUserName(String user) {
    return 'Nama pengguna duplikat: \"$user\". Harap gunakan nama yang unik.';
  }

  @override
  String get mathSpinnerComingSoon =>
      'Halaman Spinner Matematika akan segera hadir!';

  @override
  String errorSharing(String error) {
    return 'Kesalahan saat berbagi: $error';
  }

  @override
  String get playerCount => 'Jumlah Pemain';

  @override
  String get users => 'Pengguna';

  @override
  String get enterUserName => 'Masukkan nama pengguna';

  @override
  String total(String score) {
    return 'Total: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'Ronde: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults =>
      'Lihat hasil permainan spinner multiplayer kami!';

  @override
  String get allItemsUsed => 'Semua item truth dan dare telah digunakan!';

  @override
  String errorLoadingData(String error) {
    return 'Kesalahan saat memuat data: $error';
  }

  @override
  String get dice1 => 'Dadu 1';

  @override
  String get dice2 => 'Dadu 2';

  @override
  String get resultUppercase => 'HASIL';

  @override
  String score(String score) {
    return 'Skor: $score';
  }

  @override
  String turn(String user) {
    return 'Giliran $user';
  }
}
