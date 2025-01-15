// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'سمة الألوان';

  @override
  String get pieceTheme => 'سمة القطع';

  @override
  String get serverSettings => 'إعدادات الخادم';

  @override
  String get engineLevel => 'مستوى المحرك';

  @override
  String get moveTime => 'وقت النقلة';

  @override
  String get searchDepth => 'عمق البحث';

  @override
  String get enginePath => 'مسار المحرك';

  @override
  String get showAnalysisArrows => 'إظهار أسهم تحليل المحرك';

  @override
  String get language => 'اللغة';

  @override
  String get insufficientMaterial => 'مواد غير كافية، تعادل';

  @override
  String get threefoldRepetition => 'تكرار ثلاث مرات، تعادل';

  @override
  String get draw => 'تعادل';

  @override
  String failedToLoadFile(String error) {
    return 'فشل في تحميل الملف: $error';
  }

  @override
  String get newGame => 'لعبة جديدة';

  @override
  String get undo => 'تراجع';

  @override
  String get engineInitializationFailed => 'فشل في تهيئة المحرك!';

  @override
  String get hint => 'تلميح';

  @override
  String get analyzing => 'جاري التحليل...';

  @override
  String get dontBeDiscouraged => 'لا تيأس، واصل المحاولة!';

  @override
  String get congratulations => 'تهانينا على الفوز!';

  @override
  String get youWon => 'لقد فزت!';

  @override
  String get youLost => 'لقد خسرت!';

  @override
  String get engineCannotFindValidMove => 'لا يمكن للمحرك إيجاد نقلة صالحة';

  @override
  String engineMoveError(String error) {
    return 'خطأ في نقلة المحرك: $error';
  }

  @override
  String get chooseYourColor => 'اختر لونك';

  @override
  String get white => 'أبيض';

  @override
  String get black => 'أسود';

  @override
  String get chooseSaveLocation => 'اختر موقع الحفظ';

  @override
  String get gameSaved => 'تم حفظ اللعبة';

  @override
  String get saveFailed => 'فشل الحفظ، حاول مرة أخرى';

  @override
  String get analysisFailed => 'فشل التحليل، حاول مرة أخرى';

  @override
  String get humanVsAi => 'إنسان ضد الذكاء الاصطناعي';

  @override
  String get ai => 'ذكاء اصطناعي';

  @override
  String get you => 'أنت';

  @override
  String get computer => 'الحاسوب';

  @override
  String get player => 'لاعب';

  @override
  String get confirmDraw => 'تأكيد التعادل؟';

  @override
  String get areYouSureYouWantToProposeADraw => 'هل أنت متأكد من أنك تريد اقتراح التعادل؟';

  @override
  String get takeback => 'استعادة النقلة';

  @override
  String get accept => 'قبول';

  @override
  String get reject => 'رفض';

  @override
  String get ok => 'حسناً';

  @override
  String get takebackDeclined => 'تم رفض استعادة النقلة';

  @override
  String get drawDeclined => 'تم رفض التعادل';

  @override
  String get opponentRequestsTakeback => 'يطلب الخصم استعادة النقلة، هل تقبل؟';

  @override
  String get opponentProposesDraw => 'يقترح الخصم التعادل، هل تقبل؟';

  @override
  String get yes => 'نعم';

  @override
  String get no => 'لا';

  @override
  String get areYouSureYouWantToRequestATakeback => 'هل أنت متأكد من أنك تريد طلب استعادة النقلة؟';

  @override
  String get confirmTakeback => 'تأكيد استعادة النقلة؟';

  @override
  String get areYouSureYouWantToResign => 'هل أنت متأكد من أنك تريد الاستسلام؟';

  @override
  String get confirmResign => 'تأكيد الاستسلام؟';

  @override
  String get searchingForAnOpponent => 'جاري البحث عن خصم...';

  @override
  String get playOnline => 'اللعب عبر الإنترنت';

  @override
  String get connect => 'اتصال';

  @override
  String get match => 'مباراة';

  @override
  String get proposeDraw => 'اقتراح تعادل';

  @override
  String get cancel => 'إلغاء';

  @override
  String get resign => 'استسلام';

  @override
  String get takeBack => 'استعادة';

  @override
  String get promotion => 'ترقية';

  @override
  String get fullEmpty => 'كامل / فارغ';

  @override
  String get playWithAI => 'اللعب مع الذكاء الاصطناعي';

  @override
  String get dragAndDropToRemove => 'اسحب وأفلت هنا للإزالة';

  @override
  String get invalidPosition => 'وضع غير صالح، يرجى التحقق من:\n1. يجب أن يكون لكل جانب ملك واحد\n2. لا يمكن أن تكون البيادق في الصف الأول أو الأخير';

  @override
  String get setupBoard => 'إعداد الرقعة';

  @override
  String get allGames => 'جميع الألعاب';

  @override
  String get favorites => 'المفضلة';

  @override
  String get noFavoriteGamesAvailable => 'لا توجد ألعاب مفضلة';

  @override
  String get searchGames => 'البحث عن الألعاب...';

  @override
  String get games => 'الألعاب';

  @override
  String failedToLoadGamesList(String error) {
    return 'فشل في تحميل قائمة الألعاب: $error';
  }

  @override
  String comments(String comments) {
    return 'التعليقات: $comments';
  }

  @override
  String get branchSelection => 'اختيار الفرع';

  @override
  String get chessViewer => 'عارض الشطرنج';

  @override
  String get start => 'بداية';

  @override
  String get previous => 'السابق';

  @override
  String get next => 'التالي';

  @override
  String get end => 'النهاية';

  @override
  String get addedToFavorites => 'تمت الإضافة إلى المفضلة';

  @override
  String get removedFromFavorites => 'تمت الإزالة من المفضلة';

  @override
  String get serverAddress => 'عنوان الخادم';

  @override
  String get setServerAddress => 'تعيين عنوان الخادم';

  @override
  String get pleaseEnterTheServerAddress => 'الرجاء إدخال عنوان الخادم';

  @override
  String get settings => 'الإعدادات';

  @override
  String get engineSettings => 'إعدادات المحرك';

  @override
  String get thinkingTime => 'وقت التفكير';

  @override
  String get limitTime => 'تحديد الوقت';

  @override
  String get limitDepth => 'تحديد العمق';

  @override
  String get timeControlMode => 'وضع التحكم بالوقت';

  @override
  String get useTimeControl => 'استخدام التحكم بالوقت';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'إظهار النقلات المتوقعة أثناء تفكير المحرك';

  @override
  String get languageSettings => 'إعدادات اللغة';

  @override
  String get layers => 'الطبقات';

  @override
  String get current => 'الحالي';

  @override
  String get browse => 'تصفح';

  @override
  String get confirm => 'تأكيد';

  @override
  String get selectPieceTheme => 'اختيار سمة القطع';

  @override
  String get selectThemeColor => 'اختيار لون السمة';

  @override
  String get setEngineLevel => 'تعيين مستوى المحرك';

  @override
  String get setThinkingTime => 'تعيين وقت التفكير';

  @override
  String get setSearchDepth => 'تعيين عمق البحث';

  @override
  String get setEnginePath => 'تعيين مسار المحرك';

  @override
  String get pleaseEnterTheEnginePath => 'الرجاء إدخال مسار المحرك';

  @override
  String get viewGames => 'عرض الألعاب';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'اكتشف الإمكانيات اللانهائية للشطرنج';

  @override
  String get checkmated => 'كش مات';

  @override
  String get opponentOutOfTime => 'انتهى وقت الخصم';

  @override
  String get opponentResigned => 'استسلم الخصم';

  @override
  String get opponentLeft => 'غادر الخصم';

  @override
  String get outOfTime => 'انتهى الوقت';

  @override
  String get resigned => 'استسلم';

  @override
  String get stalemate => 'تعادل بالحصر';

  @override
  String get consensus => 'إجماع';

  @override
  String get timeControl => 'وقت التحكم';

  @override
  String get chessClock => 'ساعة الشطرنج';

  @override
  String get openingExplorer => 'مستكشف الفتحات';

  @override
  String get save => 'حفظ';
}
