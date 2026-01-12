// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'スピナー';

  @override
  String get languages => '言語';

  @override
  String get continueButton => '続ける';

  @override
  String get save => '保存';

  @override
  String get changeLanguage => '言語を変更';

  @override
  String get randomPicker => '決定スピナー';

  @override
  String get randomPickerDescription => '独自のアイテムでカスタムスピナーを作成';

  @override
  String get multiplayer => 'スピンバトル';

  @override
  String get multiplayerDescription => '友達とプレイしてラウンドで競争';

  @override
  String get dice => 'サイコロ';

  @override
  String get diceDescription => '2つのサイコロを振って合計を確認';

  @override
  String get whoFirst => '10へのレース';

  @override
  String get whoFirstDescription => '友達とプレイしてラウンドで競争';

  @override
  String get adsOn => '広告オン';

  @override
  String get adsOff => '広告オフ';

  @override
  String get vibrationOn => '振動オン';

  @override
  String get vibrationOff => '振動オフ';

  @override
  String get soundOn => '音オン';

  @override
  String get soundOff => '音オフ';

  @override
  String get spinnerTitle => 'スピナータイトル';

  @override
  String get enterSpinnerTitle => 'スピナータイトルを入力';

  @override
  String get start => '開始';

  @override
  String get addItem => 'アイテムを追加';

  @override
  String get gameMode => 'ゲームモード';

  @override
  String get singlePlayer => 'シングルプレイヤー';

  @override
  String get multiplayerMode => 'マルチプレイヤー';

  @override
  String get howManyRounds => '何ラウンド？';

  @override
  String get players => 'プレイヤー';

  @override
  String get addPlayer => 'プレイヤーを追加';

  @override
  String get enterPlayerName => 'プレイヤー名を入力';

  @override
  String get truthDare => '真実か挑戦';

  @override
  String get close => '閉じる';

  @override
  String get edit => '編集';

  @override
  String get reset => 'リセット';

  @override
  String get share => '共有';

  @override
  String get truth => '真実';

  @override
  String get dare => '挑戦';

  @override
  String get earned => '獲得';

  @override
  String get selected => '選択済み';

  @override
  String get you => 'あなた';

  @override
  String get computer => 'コンピューター';

  @override
  String get round => 'ラウンド';

  @override
  String get leave => '退出';

  @override
  String get leaveGame => 'ゲームを退出しますか？';

  @override
  String get leaveGameMessage => 'ゲームを退出してもよろしいですか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get gameResults => 'ゲーム結果';

  @override
  String get gold => '金';

  @override
  String get silver => '銀';

  @override
  String get bronze => '銅';

  @override
  String get watchAd => '広告を見る';

  @override
  String get toUnlock => 'ロック解除するには';

  @override
  String get twoDice => '2つのサイコロ';

  @override
  String get multiplication => '掛け算';

  @override
  String get result => '結果';

  @override
  String get spin => '回転';

  @override
  String get randomPickerTitle => '決定スピナー';

  @override
  String get spinner => 'スピナー';

  @override
  String get level => 'レベル';

  @override
  String get easy => '簡単';

  @override
  String get medium => '中程度';

  @override
  String get hard => '難しい';

  @override
  String get selectLevel => 'レベルを選択';

  @override
  String get mathSpinner => '数学チャレンジ';

  @override
  String get mathSpinnerDescription => '楽しいスピナーチャレンジで数学を練習';

  @override
  String get spinnerItems => 'スピナーアイテム';

  @override
  String get enterItemName => 'アイテム名を入力';

  @override
  String get noItems => 'アイテムがありません。\"アイテムを追加\"をクリックしてアイテムを追加してください。';

  @override
  String get pleaseAddAtLeastOneItem => '少なくとも1つのアイテムを追加してください';

  @override
  String duplicateItemName(String item) {
    return '重複したアイテム名: \"$item\"。一意の名前を使用してください。';
  }

  @override
  String get pleaseAddAtLeastOneUser => '少なくとも1人のユーザーを追加してください';

  @override
  String duplicateUserName(String user) {
    return '重複したユーザー名: \"$user\"。一意の名前を使用してください。';
  }

  @override
  String get mathSpinnerComingSoon => '数学チャレンジページが間もなく公開されます！';

  @override
  String errorSharing(String error) {
    return '共有エラー: $error';
  }

  @override
  String get playerCount => 'プレイヤー数';

  @override
  String get users => 'ユーザー';

  @override
  String get enterUserName => 'ユーザー名を入力';

  @override
  String total(String score) {
    return '合計: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'ラウンド: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults => 'スピンバトルスピナーゲームの結果をチェックしてください！';

  @override
  String get allItemsUsed => 'すべての真実と挑戦のアイテムが使用されました！';

  @override
  String errorLoadingData(String error) {
    return 'データの読み込みエラー: $error';
  }

  @override
  String get dice1 => 'サイコロ1';

  @override
  String get dice2 => 'サイコロ2';

  @override
  String get resultUppercase => '結果';

  @override
  String score(String score) {
    return 'スコア: $score';
  }

  @override
  String turn(String user) {
    return '$userのターン';
  }
}
