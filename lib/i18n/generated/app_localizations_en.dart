// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'Color Theme';

  @override
  String get pieceTheme => 'Piece Theme';

  @override
  String get serverSettings => 'Server Settings';

  @override
  String get engineLevel => 'Engine Level';

  @override
  String get moveTime => 'Move Time';

  @override
  String get searchDepth => 'Search Depth';

  @override
  String get enginePath => 'Engine Path';

  @override
  String get showAnalysisArrows => 'Show Analysis Arrows';

  @override
  String get language => 'Language';

  @override
  String get insufficientMaterial => 'Insufficient material, draw';

  @override
  String get threefoldRepetition => 'Threefold repetition, draw';

  @override
  String get draw => 'Draw';

  @override
  String failedToLoadFile(String error) {
    return 'Failed to load file: $error';
  }

  @override
  String get newGame => 'New Game';

  @override
  String get undo => 'Undo';

  @override
  String get redo => 'Redo';

  @override
  String get engineInitializationFailed => 'Engine initialization failed!';

  @override
  String get hint => 'Hint';

  @override
  String get analyzing => 'Analyzing...';

  @override
  String get dontBeDiscouraged => 'Don’t be discouraged, keep trying!';

  @override
  String get congratulations => 'Congratulations on defeating your opponent!';

  @override
  String get youWon => 'You won!';

  @override
  String get youLost => 'You lost!';

  @override
  String get engineCannotFindValidMove => 'Engine cannot find valid move';

  @override
  String engineMoveError(String error) {
    return 'Engine move error: $error';
  }

  @override
  String get chooseYourColor => 'Choose your color';

  @override
  String get white => 'White';

  @override
  String get black => 'Black';

  @override
  String get chooseSaveLocation => 'Choose save location';

  @override
  String get gameSaved => 'Game saved';

  @override
  String get saveFailed => 'Save failed, please try again';

  @override
  String get analysisFailed => 'Analysis failed, please try again';

  @override
  String get humanVsAi => 'Human vs AI';

  @override
  String get ai => 'AI';

  @override
  String get you => 'You';

  @override
  String get computer => 'Computer';

  @override
  String get player => 'Player';

  @override
  String get confirmDraw => 'Confirm Draw?';

  @override
  String get areYouSureYouWantToProposeADraw => 'Are you sure you want to propose a draw?';

  @override
  String get takeback => 'Takeback';

  @override
  String get accept => 'Accept';

  @override
  String get reject => 'Reject';

  @override
  String get ok => 'OK';

  @override
  String get takebackDeclined => 'Takeback Declined';

  @override
  String get drawDeclined => 'Draw Declined';

  @override
  String get opponentRequestsTakeback => 'Opponent requests a takeback, do you accept?';

  @override
  String get opponentProposesDraw => 'Opponent proposes a draw, do you accept?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get areYouSureYouWantToRequestATakeback => 'Are y ou sure you want to request a takeback?';

  @override
  String get confirmTakeback => 'Confirm Takeback?';

  @override
  String get areYouSureYouWantToResign => 'Are you sure you want to resign?';

  @override
  String get confirmResign => 'Confirm Resign?';

  @override
  String get searchingForAnOpponent => 'Searching for an opponent...';

  @override
  String get playOnline => 'Play Online';

  @override
  String get connect => 'Connect';

  @override
  String get match => 'Match';

  @override
  String get proposeDraw => 'Propose Draw';

  @override
  String get cancel => 'Cancel';

  @override
  String get resign => 'Resign';

  @override
  String get takeBack => 'Take Back';

  @override
  String get promotion => 'Promotion';

  @override
  String get fullEmpty => 'Full / Empty';

  @override
  String get playWithAI => 'Play with AI';

  @override
  String get dragAndDropToRemove => 'Drag & drop here to remove';

  @override
  String get invalidPosition => 'Invalid position, please check:\n1. Each side has one king\n2. Pawns cannot be on the first or eighth rank';

  @override
  String get setupBoard => 'Setup Board';

  @override
  String get allGames => 'All Games';

  @override
  String get favorites => 'Favorites';

  @override
  String get noFavoriteGamesAvailable => 'No favorite games available';

  @override
  String get searchGames => 'Search games...';

  @override
  String get games => 'Games';

  @override
  String failedToLoadGamesList(String error) {
    return 'Failed to load games list: $error';
  }

  @override
  String comments(String comments) {
    return 'Comments: $comments';
  }

  @override
  String get branchSelection => 'Branch Selection';

  @override
  String get chessViewer => 'Chess Viewer';

  @override
  String get start => 'Start';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get end => 'End';

  @override
  String get addedToFavorites => 'Added to favorites';

  @override
  String get removedFromFavorites => 'Removed from favorites';

  @override
  String get serverAddress => 'Server Address';

  @override
  String get setServerAddress => 'Set Server Address';

  @override
  String get pleaseEnterTheServerAddress => 'Please enter the server address';

  @override
  String get settings => 'Settings';

  @override
  String get engineSettings => 'Engine Settings';

  @override
  String get thinkingTime => 'Thinking Time';

  @override
  String get limitTime => 'Limit Time';

  @override
  String get limitDepth => 'Limit Depth';

  @override
  String get timeControlMode => 'Time Control Mode';

  @override
  String get useTimeControl => 'Use Time Control';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'Show predicted moves when the engine is thinking';

  @override
  String get languageSettings => 'Language Settings';

  @override
  String get layers => 'layers';

  @override
  String get current => 'Current';

  @override
  String get browse => 'Browse';

  @override
  String get confirm => 'Confirm';

  @override
  String get selectPieceTheme => 'Select Piece Theme';

  @override
  String get selectThemeColor => 'Select Theme Color';

  @override
  String get setEngineLevel => 'Set Engine Level';

  @override
  String get setThinkingTime => 'Set Thinking Time';

  @override
  String get setSearchDepth => 'Set Search Depth';

  @override
  String get setEnginePath => 'Set Engine Path';

  @override
  String get pleaseEnterTheEnginePath => 'Please enter the engine path';

  @override
  String get viewGames => 'View Games';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'Explore the infinite possibilities of chess';

  @override
  String get checkmated => 'Checkmated';

  @override
  String get opponentOutOfTime => 'Opponent Out of Time';

  @override
  String get opponentResigned => 'Opponent Resigned';

  @override
  String get opponentLeft => 'Opponent Left';

  @override
  String get outOfTime => 'Out of Time';

  @override
  String get resigned => 'Resigned';

  @override
  String get stalemate => 'Stalemate';

  @override
  String get consensus => 'Consensus';

  @override
  String get timeControl => 'Time Control';

  @override
  String get chessClock => 'Chess Clock';

  @override
  String get openingExplorer => 'Opening Explorer';

  @override
  String get save => 'Save';

  @override
  String get flipBoard => 'Flip Board';
}
