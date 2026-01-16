// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '스피너';

  @override
  String get languages => '언어';

  @override
  String get continueButton => '계속';

  @override
  String get save => '저장';

  @override
  String get changeLanguage => '언어 변경';

  @override
  String get randomPicker => '결정 스피너';

  @override
  String get randomPickerDescription => '자신만의 항목으로 맞춤 스피너 만들기';

  @override
  String get multiplayer => '스핀 배틀';

  @override
  String get multiplayerDescription => '친구와 함께 플레이하고 라운드에서 경쟁';

  @override
  String get dice => '주사위';

  @override
  String get diceDescription => '두 개의 주사위를 굴려 합계 확인';

  @override
  String get whoFirst => '10까지 레이스';

  @override
  String get whoFirstDescription => '친구와 함께 플레이하고 라운드에서 경쟁';

  @override
  String get adsOn => '광고 켜기';

  @override
  String get adsOff => '광고 끄기';

  @override
  String get vibrationOn => '진동 켜기';

  @override
  String get vibrationOff => '진동 끄기';

  @override
  String get soundOn => '소리 켜기';

  @override
  String get soundOff => '소리 끄기';

  @override
  String get spinnerTitle => '스피너 제목';

  @override
  String get enterSpinnerTitle => '스피너 제목 입력';

  @override
  String get start => '시작';

  @override
  String get addItem => '항목 추가';

  @override
  String get gameMode => '게임 모드';

  @override
  String get singlePlayer => '싱글 플레이어';

  @override
  String get multiplayerMode => '멀티플레이어';

  @override
  String get howManyRounds => '몇 라운드?';

  @override
  String get players => '플레이어';

  @override
  String get addPlayer => '플레이어 추가';

  @override
  String get enterPlayerName => '플레이어 이름 입력';

  @override
  String get truthDare => '진실 또는 도전';

  @override
  String get close => '닫기';

  @override
  String get edit => '편집';

  @override
  String get reset => '재설정';

  @override
  String get share => '공유';

  @override
  String get truth => '진실';

  @override
  String get dare => '도전';

  @override
  String get earned => '획득';

  @override
  String get selected => '선택됨';

  @override
  String get you => '당신';

  @override
  String get computer => '컴퓨터';

  @override
  String get round => '라운드';

  @override
  String get leave => '나가기';

  @override
  String get leaveGame => '게임을 나가시겠습니까?';

  @override
  String get leaveGameMessage => '게임을 나가시겠습니까?';

  @override
  String get cancel => '취소';

  @override
  String get gameResults => '게임 결과';

  @override
  String get gold => '금';

  @override
  String get silver => '은';

  @override
  String get bronze => '동';

  @override
  String get watchAd => '광고 보기';

  @override
  String get toUnlock => '잠금 해제하려면';

  @override
  String get twoDice => '두 개의 주사위';

  @override
  String get multiplication => '곱셈';

  @override
  String get result => '결과';

  @override
  String get spin => '회전';

  @override
  String get randomPickerTitle => '결정 스피너';

  @override
  String get spinner => '스피너';

  @override
  String get level => '레벨';

  @override
  String get easy => '쉬움';

  @override
  String get medium => '보통';

  @override
  String get hard => '어려움';

  @override
  String get selectLevel => '레벨 선택';

  @override
  String get mathSpinner => '수학 챌린지';

  @override
  String get mathSpinnerDescription => '재미있는 스피너 도전으로 수학 연습';

  @override
  String get spinnerItems => '스피너 항목';

  @override
  String get enterItemName => '항목 이름 입력';

  @override
  String get noItems => '항목이 없습니다. \"항목 추가\"를 클릭하여 항목을 추가하세요.';

  @override
  String get pleaseAddAtLeastOneItem => '최소한 하나의 항목을 추가하세요';

  @override
  String duplicateItemName(String item) {
    return '중복된 항목 이름: \"$item\". 고유한 이름을 사용하세요.';
  }

  @override
  String get pleaseAddAtLeastOneUser => '최소한 한 명의 사용자를 추가하세요';

  @override
  String duplicateUserName(String user) {
    return '중복된 사용자 이름: \"$user\". 고유한 이름을 사용하세요.';
  }

  @override
  String get mathSpinnerComingSoon => '수학 챌린지 페이지가 곧 출시됩니다!';

  @override
  String errorSharing(String error) {
    return '공유 오류: $error';
  }

  @override
  String get playerCount => '플레이어 수';

  @override
  String get users => '사용자';

  @override
  String get enterUserName => '사용자 이름 입력';

  @override
  String total(String score) {
    return '총점: $score';
  }

  @override
  String rounds(String roundsList) {
    return '라운드: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'R$round: $score';
  }

  @override
  String get checkOutResults => '스핀 배틀 스피너 게임 결과를 확인하세요!';

  @override
  String get allItemsUsed => '모든 진실과 도전 항목이 사용되었습니다!';

  @override
  String errorLoadingData(String error) {
    return '데이터 로드 오류: $error';
  }

  @override
  String get dice1 => '주사위 1';

  @override
  String get dice2 => '주사위 2';

  @override
  String get resultUppercase => '결과';

  @override
  String score(String score) {
    return '점수: $score';
  }

  @override
  String turn(String user) {
    return '$user의 차례';
  }
}
