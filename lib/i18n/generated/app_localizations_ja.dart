// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'カラーテーマ';

  @override
  String get pieceTheme => '駒のテーマ';

  @override
  String get serverSettings => 'サーバー設定';

  @override
  String get engineLevel => 'エンジンレベル';

  @override
  String get moveTime => '手の時間';

  @override
  String get searchDepth => '探索深さ';

  @override
  String get enginePath => 'エンジンパス';

  @override
  String get showAnalysisArrows => '解析の矢印を表示';

  @override
  String get language => '言語';

  @override
  String get insufficientMaterial => '詰まない駒組み合わせ、引き分け';

  @override
  String get threefoldRepetition => '同形三回、引き分け';

  @override
  String get draw => '引き分け';

  @override
  String failedToLoadFile(String error) {
    return 'ファイルの読み込みに失敗: $error';
  }

  @override
  String get newGame => '新しいゲーム';

  @override
  String get undo => '取り消し';

  @override
  String get redo => 'やり直し';

  @override
  String get engineInitializationFailed => 'エンジンの初期化に失敗しました！';

  @override
  String get hint => 'ヒント';

  @override
  String get analyzing => '解析中...';

  @override
  String get dontBeDiscouraged => '諦めないで、続けてみましょう！';

  @override
  String get congratulations => '勝利おめでとうございます！';

  @override
  String get youWon => '勝ちました！';

  @override
  String get youLost => '負けました！';

  @override
  String get engineCannotFindValidMove => 'エンジンが有効な手を見つけられません';

  @override
  String engineMoveError(String error) {
    return 'エンジンの手のエラー: $error';
  }

  @override
  String get chooseYourColor => '色を選択';

  @override
  String get white => '白';

  @override
  String get black => '黒';

  @override
  String get chooseSaveLocation => '保存場所を選択';

  @override
  String get gameSaved => 'ゲームを保存しました';

  @override
  String get saveFailed => '保存に失敗しました。もう一度お試しください';

  @override
  String get analysisFailed => '解析に失敗しました。もう一度お試しください';

  @override
  String get humanVsAi => '人間 vs AI';

  @override
  String get ai => 'AI';

  @override
  String get you => 'あなた';

  @override
  String get computer => 'コンピュータ';

  @override
  String get player => 'プレイヤー';

  @override
  String get confirmDraw => '引き分けの確認';

  @override
  String get areYouSureYouWantToProposeADraw => '本当に引き分けを提案しますか？';

  @override
  String get takeback => '待った';

  @override
  String get accept => '承諾';

  @override
  String get reject => '拒否';

  @override
  String get ok => 'OK';

  @override
  String get takebackDeclined => '待ったが拒否されました';

  @override
  String get drawDeclined => '引き分けが拒否されました';

  @override
  String get opponentRequestsTakeback => '相手が待ったを要求しています。承諾しますか？';

  @override
  String get opponentProposesDraw => '相手が引き分けを提案しています。承諾しますか？';

  @override
  String get yes => 'はい';

  @override
  String get no => 'いいえ';

  @override
  String get areYouSureYouWantToRequestATakeback => '本当に待ったを要求しますか？';

  @override
  String get confirmTakeback => '待ったの確認';

  @override
  String get areYouSureYouWantToResign => '本当に投了しますか？';

  @override
  String get confirmResign => '投了の確認';

  @override
  String get searchingForAnOpponent => '対戦相手を探しています...';

  @override
  String get playOnline => 'オンラインで対戦';

  @override
  String get connect => '接続';

  @override
  String get match => '対戦';

  @override
  String get proposeDraw => '引き分けを提案';

  @override
  String get cancel => 'キャンセル';

  @override
  String get resign => '投了';

  @override
  String get takeBack => '待った';

  @override
  String get promotion => '昇格';

  @override
  String get fullEmpty => '全て/空';

  @override
  String get playWithAI => 'AIと対戦';

  @override
  String get dragAndDropToRemove => 'ここにドラッグ＆ドロップで削除';

  @override
  String get invalidPosition => '無効な配置です。以下を確認してください：\n1. 各陣営にキングが1つずつ必要です\n2. ポーンは最初と最後の段に置けません';

  @override
  String get freeBoard => '盤面設定';

  @override
  String get allGames => '全てのゲーム';

  @override
  String get favorites => 'お気に入り';

  @override
  String get noFavoriteGamesAvailable => 'お気に入りのゲームがありません';

  @override
  String get searchGames => 'ゲームを検索...';

  @override
  String get games => 'ゲーム';

  @override
  String failedToLoadGamesList(String error) {
    return 'ゲームリストの読み込みに失敗: $error';
  }

  @override
  String comments(String comments) {
    return 'コメント: $comments';
  }

  @override
  String get branchSelection => '分岐選択';

  @override
  String get chessViewer => 'チェスビューワー';

  @override
  String get start => '開始';

  @override
  String get previous => '前へ';

  @override
  String get next => '次へ';

  @override
  String get end => '終了';

  @override
  String get addedToFavorites => 'お気に入りに追加しました';

  @override
  String get removedFromFavorites => 'お気に入りから削除しました';

  @override
  String get serverAddress => 'サーバーアドレス';

  @override
  String get setServerAddress => 'サーバーアドレスを設定';

  @override
  String get pleaseEnterTheServerAddress => 'サーバーアドレスを入力してください';

  @override
  String get settings => '設定';

  @override
  String get engineSettings => 'エンジン設定';

  @override
  String get thinkingTime => '思考時間';

  @override
  String get limitTime => '制限時間';

  @override
  String get limitDepth => '制限深さ';

  @override
  String get timeControlMode => '時間制御モード';

  @override
  String get useTimeControl => '時間制御を使用';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'エンジン思考中に予測手を表示';

  @override
  String get languageSettings => '言語設定';

  @override
  String get layers => 'レイヤー';

  @override
  String get current => '現在';

  @override
  String get browse => '参照';

  @override
  String get confirm => '確認';

  @override
  String get selectPieceTheme => '駒のテーマを選択';

  @override
  String get selectThemeColor => 'テーマカラーを選択';

  @override
  String get setEngineLevel => 'エンジンレベルを設定';

  @override
  String get setThinkingTime => '思考時間を設定';

  @override
  String get setSearchDepth => '探索深さを設定';

  @override
  String get setEnginePath => 'エンジンパスを設定';

  @override
  String get pleaseEnterTheEnginePath => 'エンジンパスを入力してください';

  @override
  String get viewGames => 'ゲームを表示';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'チェスの無限の可能性を探索しよう';

  @override
  String get checkmated => 'チェックメイト';

  @override
  String get opponentOutOfTime => '相手の時間切れ';

  @override
  String get opponentResigned => '相手が投了しました';

  @override
  String get opponentLeft => '相手が退出しました';

  @override
  String get outOfTime => '時間切れ';

  @override
  String get resigned => '投了';

  @override
  String get stalemate => 'ステイルメイト';

  @override
  String get consensus => '合意';

  @override
  String get timeControl => '時間制御';

  @override
  String get chessClock => 'チェスクロック';

  @override
  String get openingExplorer => '開幕エクスプローラー';

  @override
  String get save => '保存';

  @override
  String get flipBoard => '盤面を反転';
}
