// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'الدوار';

  @override
  String get languages => 'اللغات';

  @override
  String get continueButton => 'متابعة';

  @override
  String get save => 'حفظ';

  @override
  String get changeLanguage => 'تغيير اللغة';

  @override
  String get randomPicker => 'دوار القرارات';

  @override
  String get randomPickerDescription => 'أنشئ دوارًا مخصصًا بعناصرك الخاصة';

  @override
  String get multiplayer => 'معركة الدوران';

  @override
  String get multiplayerDescription => 'العب مع الأصدقاء وتنافس في الجولات';

  @override
  String get dice => 'النرد';

  @override
  String get diceDescription => 'ارمي نردتين وشاهد المجموع';

  @override
  String get whoFirst => 'سباق إلى 10';

  @override
  String get whoFirstDescription => 'العب مع الأصدقاء وتنافس في الجولات';

  @override
  String get adsOn => 'الإعلانات مفعلة';

  @override
  String get adsOff => 'الإعلانات معطلة';

  @override
  String get vibrationOn => 'الاهتزاز مفعل';

  @override
  String get vibrationOff => 'الاهتزاز معطل';

  @override
  String get soundOn => 'الصوت مفعل';

  @override
  String get soundOff => 'الصوت معطل';

  @override
  String get spinnerTitle => 'عنوان الدوار';

  @override
  String get enterSpinnerTitle => 'أدخل عنوان الدوار';

  @override
  String get start => 'ابدأ';

  @override
  String get addItem => 'إضافة عنصر';

  @override
  String get gameMode => 'وضع اللعبة';

  @override
  String get singlePlayer => 'لاعب واحد';

  @override
  String get multiplayerMode => 'متعدد اللاعبين';

  @override
  String get howManyRounds => 'كم عدد الجولات؟';

  @override
  String get players => 'اللاعبون';

  @override
  String get addPlayer => 'إضافة لاعب';

  @override
  String get enterPlayerName => 'أدخل اسم اللاعب';

  @override
  String get truthDare => 'الحقيقة والجرأة';

  @override
  String get close => 'إغلاق';

  @override
  String get edit => 'تعديل';

  @override
  String get reset => 'إعادة تعيين';

  @override
  String get share => 'مشاركة';

  @override
  String get truth => 'الحقيقة';

  @override
  String get dare => 'الجرأة';

  @override
  String get earned => 'مكتسب';

  @override
  String get selected => 'محدد';

  @override
  String get you => 'أنت';

  @override
  String get computer => 'الكمبيوتر';

  @override
  String get round => 'جولة';

  @override
  String get leave => 'مغادرة';

  @override
  String get leaveGame => 'مغادرة اللعبة؟';

  @override
  String get leaveGameMessage => 'هل أنت متأكد أنك تريد مغادرة اللعبة؟';

  @override
  String get cancel => 'إلغاء';

  @override
  String get gameResults => 'نتائج اللعبة';

  @override
  String get gold => 'ذهبي';

  @override
  String get silver => 'فضي';

  @override
  String get bronze => 'برونزي';

  @override
  String get watchAd => 'شاهد الإعلان';

  @override
  String get toUnlock => 'للفتح';

  @override
  String get twoDice => 'نردتان';

  @override
  String get multiplication => 'الضرب';

  @override
  String get result => 'النتيجة';

  @override
  String get spin => 'دور';

  @override
  String get randomPickerTitle => 'دوار القرارات';

  @override
  String get spinner => 'الدوار';

  @override
  String get level => 'المستوى';

  @override
  String get easy => 'سهل';

  @override
  String get medium => 'متوسط';

  @override
  String get hard => 'صعب';

  @override
  String get selectLevel => 'اختر المستوى';

  @override
  String get mathSpinner => 'تحدي الرياضيات';

  @override
  String get mathSpinnerDescription =>
      'تدرب على الرياضيات مع تحديات دوار ممتعة';

  @override
  String get spinnerItems => 'عناصر الدوار';

  @override
  String get enterItemName => 'أدخل اسم العنصر';

  @override
  String get noItems => 'لا توجد عناصر. انقر \"إضافة عنصر\" لإضافة عناصر.';

  @override
  String get pleaseAddAtLeastOneItem => 'يرجى إضافة عنصر واحد على الأقل';

  @override
  String duplicateItemName(String item) {
    return 'اسم عنصر مكرر: \"$item\". يرجى استخدام أسماء فريدة.';
  }

  @override
  String get pleaseAddAtLeastOneUser => 'يرجى إضافة مستخدم واحد على الأقل';

  @override
  String duplicateUserName(String user) {
    return 'اسم مستخدم مكرر: \"$user\". يرجى استخدام أسماء فريدة.';
  }

  @override
  String get mathSpinnerComingSoon => 'صفحة تحدي الرياضيات قريباً!';

  @override
  String errorSharing(String error) {
    return 'خطأ في المشاركة: $error';
  }

  @override
  String get playerCount => 'عدد اللاعبين';

  @override
  String get users => 'المستخدمون';

  @override
  String get enterUserName => 'أدخل اسم المستخدم';

  @override
  String total(String score) {
    return 'المجموع: $score';
  }

  @override
  String rounds(String roundsList) {
    return 'الجولات: $roundsList';
  }

  @override
  String roundScore(String round, String score) {
    return 'ج$round: $score';
  }

  @override
  String get checkOutResults => 'تحقق من نتائج لعبة الدوار معركة الدوران!';

  @override
  String get allItemsUsed => 'تم استخدام جميع عناصر الحقيقة والجرأة!';

  @override
  String errorLoadingData(String error) {
    return 'خطأ في تحميل البيانات: $error';
  }

  @override
  String get dice1 => 'النرد 1';

  @override
  String get dice2 => 'النرد 2';

  @override
  String get resultUppercase => 'النتيجة';

  @override
  String score(String score) {
    return 'النقاط: $score';
  }

  @override
  String turn(String user) {
    return 'دور $user';
  }
}
