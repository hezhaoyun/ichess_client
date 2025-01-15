// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'रंग थीम';

  @override
  String get pieceTheme => 'मोहरों की थीम';

  @override
  String get serverSettings => 'सर्वर सेटिंग्स';

  @override
  String get engineLevel => 'इंजन स्तर';

  @override
  String get moveTime => 'चाल का समय';

  @override
  String get searchDepth => 'खोज की गहराई';

  @override
  String get enginePath => 'इंजन पथ';

  @override
  String get showAnalysisArrows => 'विश्लेषण तीर दिखाएं';

  @override
  String get language => 'भाषा';

  @override
  String get insufficientMaterial => 'अपर्याप्त सामग्री, ड्रॉ';

  @override
  String get threefoldRepetition => 'तीन बार दोहराव, ड्रॉ';

  @override
  String get draw => 'ड्रॉ';

  @override
  String failedToLoadFile(String error) {
    return 'फ़ाइल लोड करने में विफल: $error';
  }

  @override
  String get newGame => 'नया खेल';

  @override
  String get undo => 'वापस लें';

  @override
  String get redo => 'फिर करें';

  @override
  String get engineInitializationFailed => 'इंजन प्रारंभ करने में विफल!';

  @override
  String get hint => 'संकेत';

  @override
  String get analyzing => 'विश्लेषण कर रहा है...';

  @override
  String get dontBeDiscouraged => 'निराश मत हों, प्रयास जारी रखें!';

  @override
  String get congratulations => 'जीत की बधाई!';

  @override
  String get youWon => 'आप जीत गए!';

  @override
  String get youLost => 'आप हार गए!';

  @override
  String get engineCannotFindValidMove => 'इंजन वैध चाल नहीं ढूंढ पा रहा है';

  @override
  String engineMoveError(String error) {
    return 'इंजन चाल त्रुटि: $error';
  }

  @override
  String get chooseYourColor => 'अपना रंग चुनें';

  @override
  String get white => 'सफेद';

  @override
  String get black => 'काला';

  @override
  String get chooseSaveLocation => 'सहेजने का स्थान चुनें';

  @override
  String get gameSaved => 'खेल सहेजा गया';

  @override
  String get saveFailed => 'सहेजना विफल, कृपया पुनः प्रयास करें';

  @override
  String get analysisFailed => 'विश्लेषण विफल, कृपया पुनः प्रयास करें';

  @override
  String get humanVsAi => 'मानव बनाम एआई';

  @override
  String get ai => 'एआई';

  @override
  String get you => 'आप';

  @override
  String get computer => 'कंप्यूटर';

  @override
  String get player => 'खिलाड़ी';

  @override
  String get confirmDraw => 'ड्रॉ की पुष्टि करें?';

  @override
  String get areYouSureYouWantToProposeADraw => 'क्या आप वाकई ड्रॉ प्रस्तावित करना चाहते हैं?';

  @override
  String get takeback => 'चाल वापस लें';

  @override
  String get accept => 'स्वीकार करें';

  @override
  String get reject => 'अस्वीकार करें';

  @override
  String get ok => 'ठीक है';

  @override
  String get takebackDeclined => 'चाल वापस लेने से इनकार';

  @override
  String get drawDeclined => 'ड्रॉ अस्वीकृत';

  @override
  String get opponentRequestsTakeback => 'प्रतिद्वंद्वी चाल वापस लेना चाहता है, क्या आप स्वीकार करते हैं?';

  @override
  String get opponentProposesDraw => 'प्रतिद्वंद्वी ड्रॉ प्रस्तावित करता है, क्या आप स्वीकार करते हैं?';

  @override
  String get yes => 'हाँ';

  @override
  String get no => 'नहीं';

  @override
  String get areYouSureYouWantToRequestATakeback => 'क्या आप वाकई चाल वापस लेने का अनुरोध करना चाहते हैं?';

  @override
  String get confirmTakeback => 'चाल वापस लेने की पुष्टि करें?';

  @override
  String get areYouSureYouWantToResign => 'क्या आप वाकई हार मानना चाहते हैं?';

  @override
  String get confirmResign => 'हार मानने की पुष्टि करें?';

  @override
  String get searchingForAnOpponent => 'प्रतिद्वंद्वी की खोज जारी...';

  @override
  String get playOnline => 'ऑनलाइन खेलें';

  @override
  String get connect => 'कनेक्ट करें';

  @override
  String get match => 'मैच';

  @override
  String get proposeDraw => 'ड्रॉ प्रस्तावित करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get resign => 'हार मानें';

  @override
  String get takeBack => 'वापस लें';

  @override
  String get promotion => 'पदोन्नति';

  @override
  String get fullEmpty => 'पूर्ण / खाली';

  @override
  String get playWithAI => 'एआई के साथ खेलें';

  @override
  String get dragAndDropToRemove => 'हटाने के लिए यहाँ खींचें और छोड़ें';

  @override
  String get invalidPosition => 'अमान्य स्थिति, कृपया जाँचें:\n1. प्रत्येक पक्ष का एक राजा होना चाहिए\n2. प्यादे पहली या आखिरी पंक्ति पर नहीं हो सकते';

  @override
  String get freeBoard => 'बोर्ड सेट करें';

  @override
  String get allGames => 'सभी खेल';

  @override
  String get favorites => 'पसंदीदा';

  @override
  String get noFavoriteGamesAvailable => 'कोई पसंदीदा खेल उपलब्ध नहीं';

  @override
  String get searchGames => 'खेल खोजें...';

  @override
  String get games => 'खेल';

  @override
  String failedToLoadGamesList(String error) {
    return 'खेलों की सूची लोड करने में विफल: $error';
  }

  @override
  String comments(String comments) {
    return 'टिप्पणियाँ: $comments';
  }

  @override
  String get branchSelection => 'वैरिएंट चयन';

  @override
  String get chessViewer => 'शतरंज व्यूअर';

  @override
  String get start => 'शुरू';

  @override
  String get previous => 'पिछला';

  @override
  String get next => 'अगला';

  @override
  String get end => 'समाप्त';

  @override
  String get addedToFavorites => 'पसंदीदा में जोड़ा गया';

  @override
  String get removedFromFavorites => 'पसंदीदा से हटाया गया';

  @override
  String get serverAddress => 'सर्वर पता';

  @override
  String get setServerAddress => 'सर्वर पता सेट करें';

  @override
  String get pleaseEnterTheServerAddress => 'कृपया सर्वर पता दर्ज करें';

  @override
  String get settings => 'सेटिंग्स';

  @override
  String get engineSettings => 'इंजन सेटिंग्स';

  @override
  String get thinkingTime => 'सोचने का समय';

  @override
  String get limitTime => 'समय सीमा';

  @override
  String get limitDepth => 'गहराई सीमा';

  @override
  String get timeControlMode => 'समय नियंत्रण मोड';

  @override
  String get useTimeControl => 'समय नियंत्रण का उपयोग करें';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'इंजन के सोचने के दौरान अनुमानित चालें दिखाएं';

  @override
  String get languageSettings => 'भाषा सेटिंग्स';

  @override
  String get layers => 'परतें';

  @override
  String get current => 'वर्तमान';

  @override
  String get browse => 'ब्राउज़ करें';

  @override
  String get confirm => 'पुष्टि करें';

  @override
  String get selectPieceTheme => 'मोहरों की थीम चुनें';

  @override
  String get selectThemeColor => 'रंग थीम चुनें';

  @override
  String get setEngineLevel => 'इंजन स्तर सेट करें';

  @override
  String get setThinkingTime => 'सोचने का समय सेट करें';

  @override
  String get setSearchDepth => 'खोज की गहराई सेट करें';

  @override
  String get setEnginePath => 'इंजन पथ सेट करें';

  @override
  String get pleaseEnterTheEnginePath => 'कृपया इंजन पथ दर्ज करें';

  @override
  String get viewGames => 'खेल देखें';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'शतरंज की असीमित संभावनाओं की खोज करें';

  @override
  String get checkmated => 'शह और मात';

  @override
  String get opponentOutOfTime => 'प्रतिद्वंद्वी का समय समाप्त';

  @override
  String get opponentResigned => 'प्रतिद्वंद्वी ने हार मान ली';

  @override
  String get opponentLeft => 'प्रतिद्वंद्वी चला गया';

  @override
  String get outOfTime => 'समय समाप्त';

  @override
  String get resigned => 'हार मान ली';

  @override
  String get stalemate => 'पात';

  @override
  String get consensus => 'सहमति';

  @override
  String get timeControl => 'समय नियंत्रण';

  @override
  String get chessClock => 'शतरंज घड़ी';

  @override
  String get openingExplorer => 'खोलने का खोजकर्ता';

  @override
  String get save => 'सहेजें';

  @override
  String get flipBoard => 'टोपी बदलें';
}
