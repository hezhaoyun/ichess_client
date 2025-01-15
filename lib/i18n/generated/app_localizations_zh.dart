// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => '象棋之路';

  @override
  String get colorTheme => '颜色主题';

  @override
  String get pieceTheme => '棋子主题';

  @override
  String get serverSettings => '服务器设置';

  @override
  String get engineLevel => '引擎等级';

  @override
  String get moveTime => '移动时间';

  @override
  String get searchDepth => '搜索深度';

  @override
  String get enginePath => '引擎路径';

  @override
  String get showAnalysisArrows => '显示分析箭头';

  @override
  String get language => '语言';

  @override
  String get insufficientMaterial => '子力不足，和棋';

  @override
  String get threefoldRepetition => '三次重复，和棋';

  @override
  String get draw => '和棋';

  @override
  String failedToLoadFile(String error) {
    return '加载文件失败：$error';
  }

  @override
  String get newGame => '新游戏';

  @override
  String get undo => '撤销';

  @override
  String get redo => '重做';

  @override
  String get engineInitializationFailed => '引擎初始化失败！';

  @override
  String get hint => '提示';

  @override
  String get analyzing => '分析中...';

  @override
  String get dontBeDiscouraged => '别灰心,继续努力！';

  @override
  String get congratulations => '恭喜你战胜对手！';

  @override
  String get youWon => '你赢了！';

  @override
  String get youLost => '你输了！';

  @override
  String get engineCannotFindValidMove => '引擎找不到有效移动';

  @override
  String engineMoveError(String error) {
    return '引擎移动错误: $error';
  }

  @override
  String get chooseYourColor => '选择你的颜色';

  @override
  String get white => '白方';

  @override
  String get black => '黑方';

  @override
  String get chooseSaveLocation => '选择保存位置';

  @override
  String get gameSaved => '游戏已保存';

  @override
  String get saveFailed => '保存失败，请重试';

  @override
  String get analysisFailed => '分析失败，请重试';

  @override
  String get humanVsAi => '人机对战';

  @override
  String get ai => 'AI';

  @override
  String get you => '你';

  @override
  String get computer => '电脑';

  @override
  String get player => '玩家';

  @override
  String get confirmDraw => '确认和棋？';

  @override
  String get areYouSureYouWantToProposeADraw => '你确定要提议和棋吗？';

  @override
  String get takeback => '悔棋';

  @override
  String get accept => '接受';

  @override
  String get reject => '拒绝';

  @override
  String get ok => '确定';

  @override
  String get takebackDeclined => '悔棋被拒绝';

  @override
  String get drawDeclined => '和棋被拒绝';

  @override
  String get opponentRequestsTakeback => '对手请求悔棋，你接受吗？';

  @override
  String get opponentProposesDraw => '对手提议和棋，你接受吗？';

  @override
  String get yes => '是';

  @override
  String get no => '否';

  @override
  String get areYouSureYouWantToRequestATakeback => '你确定要请求悔棋吗？';

  @override
  String get confirmTakeback => '确认悔棋？';

  @override
  String get areYouSureYouWantToResign => '你确定要认输吗？';

  @override
  String get confirmResign => '确认认输？';

  @override
  String get searchingForAnOpponent => '正在寻找对手...';

  @override
  String get playOnline => '在线对战';

  @override
  String get connect => '连接';

  @override
  String get match => '对局';

  @override
  String get proposeDraw => '提议和棋';

  @override
  String get cancel => '取消';

  @override
  String get resign => '认输';

  @override
  String get takeBack => '悔棋';

  @override
  String get promotion => '升变';

  @override
  String get fullEmpty => '全部/清空';

  @override
  String get playWithAI => '人机对战';

  @override
  String get dragAndDropToRemove => '拖放到此处删除';

  @override
  String get invalidPosition => '无效的位置，请检查：\n1. 双方各有一个王\n2. 兵不能在第一行或第八行';

  @override
  String get setupBoard => '设置棋盘';

  @override
  String get allGames => '所有对局';

  @override
  String get favorites => '收藏';

  @override
  String get noFavoriteGamesAvailable => '没有收藏的对局';

  @override
  String get searchGames => '搜索对局...';

  @override
  String get games => '对局';

  @override
  String failedToLoadGamesList(String error) {
    return '加载对局列表失败: $error';
  }

  @override
  String comments(String comments) {
    return '评论: $comments';
  }

  @override
  String get branchSelection => '变着选择';

  @override
  String get chessViewer => '棋谱浏览器';

  @override
  String get start => '开始';

  @override
  String get previous => '上一步';

  @override
  String get next => '下一步';

  @override
  String get end => '结束';

  @override
  String get addedToFavorites => '已添加到收藏';

  @override
  String get removedFromFavorites => '已从收藏中移除';

  @override
  String get serverAddress => '服务器地址';

  @override
  String get setServerAddress => '设置服务器地址';

  @override
  String get pleaseEnterTheServerAddress => '请输入服务器地址';

  @override
  String get settings => '设置';

  @override
  String get engineSettings => '引擎设置';

  @override
  String get thinkingTime => '思考时间';

  @override
  String get limitTime => '限制时间';

  @override
  String get limitDepth => '限制深度';

  @override
  String get timeControlMode => '时间控制模式';

  @override
  String get useTimeControl => '使用时间控制';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => '在引擎思考时显示预测着法';

  @override
  String get languageSettings => '语言设置';

  @override
  String get layers => '层';

  @override
  String get current => '当前';

  @override
  String get browse => '浏览';

  @override
  String get confirm => '确认';

  @override
  String get selectPieceTheme => '选择棋子主题';

  @override
  String get selectThemeColor => '选择主题颜色';

  @override
  String get setEngineLevel => '设置引擎等级';

  @override
  String get setThinkingTime => '设置思考时间';

  @override
  String get setSearchDepth => '设置搜索深度';

  @override
  String get setEnginePath => '设置引擎路径';

  @override
  String get pleaseEnterTheEnginePath => '请输入引擎路径';

  @override
  String get viewGames => '查看对局';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => '探索国际象棋的无限可能';

  @override
  String get checkmated => '将死';

  @override
  String get opponentOutOfTime => '对手超时';

  @override
  String get opponentResigned => '对手认输';

  @override
  String get opponentLeft => '对手离开';

  @override
  String get outOfTime => '超时';

  @override
  String get resigned => '认输';

  @override
  String get stalemate => '僵局';

  @override
  String get consensus => '共识';

  @override
  String get timeControl => '时间控制';

  @override
  String get chessClock => '象棋时钟';

  @override
  String get openingExplorer => '开局探索器';

  @override
  String get save => '保存';

  @override
  String get flipBoard => '翻转棋盘';
}
