import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('hi'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('ru'),
    Locale('zh')
  ];

  /// The application name
  ///
  /// In en, this message translates to:
  /// **'Chess Road'**
  String get appName;

  /// Title for color theme settings
  ///
  /// In en, this message translates to:
  /// **'Color Theme'**
  String get colorTheme;

  /// Title for chess piece theme settings
  ///
  /// In en, this message translates to:
  /// **'Piece Theme'**
  String get pieceTheme;

  /// Title for server settings
  ///
  /// In en, this message translates to:
  /// **'Server Settings'**
  String get serverSettings;

  /// Title for AI engine level settings
  ///
  /// In en, this message translates to:
  /// **'Engine Level'**
  String get engineLevel;

  /// Title for move time settings
  ///
  /// In en, this message translates to:
  /// **'Move Time'**
  String get moveTime;

  /// Title for search depth settings
  ///
  /// In en, this message translates to:
  /// **'Search Depth'**
  String get searchDepth;

  /// Title for engine path settings
  ///
  /// In en, this message translates to:
  /// **'Engine Path'**
  String get enginePath;

  /// Title for show analysis arrows settings
  ///
  /// In en, this message translates to:
  /// **'Show Analysis Arrows'**
  String get showAnalysisArrows;

  /// Title for language settings
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Message for insufficient material draw
  ///
  /// In en, this message translates to:
  /// **'Insufficient material, draw'**
  String get insufficientMaterial;

  /// Message for threefold repetition draw
  ///
  /// In en, this message translates to:
  /// **'Threefold repetition, draw'**
  String get threefoldRepetition;

  /// Message for draw
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get draw;

  /// Message shown when file loading fails
  ///
  /// In en, this message translates to:
  /// **'Failed to load file: {error}'**
  String failedToLoadFile(String error);

  /// New game button text
  ///
  /// In en, this message translates to:
  /// **'New Game'**
  String get newGame;

  /// Undo move button text
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Redo move button text
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// Message shown when engine initialization fails
  ///
  /// In en, this message translates to:
  /// **'Engine initialization failed!'**
  String get engineInitializationFailed;

  /// Hint button text
  ///
  /// In en, this message translates to:
  /// **'Hint'**
  String get hint;

  /// Analyzing message
  ///
  /// In en, this message translates to:
  /// **'Analyzing...'**
  String get analyzing;

  /// Message shown when player loses
  ///
  /// In en, this message translates to:
  /// **'Don’t be discouraged, keep trying!'**
  String get dontBeDiscouraged;

  /// Message shown when player wins
  ///
  /// In en, this message translates to:
  /// **'Congratulations on defeating your opponent!'**
  String get congratulations;

  /// Message shown when player wins
  ///
  /// In en, this message translates to:
  /// **'You won!'**
  String get youWon;

  /// Message shown when player loses
  ///
  /// In en, this message translates to:
  /// **'You lost!'**
  String get youLost;

  /// Message shown when engine cannot find valid move
  ///
  /// In en, this message translates to:
  /// **'Engine cannot find valid move'**
  String get engineCannotFindValidMove;

  /// Message shown when engine move error
  ///
  /// In en, this message translates to:
  /// **'Engine move error: {error}'**
  String engineMoveError(String error);

  /// Title for choose your color
  ///
  /// In en, this message translates to:
  /// **'Choose your color'**
  String get chooseYourColor;

  /// White color
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// Black color
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// Title for choose save location
  ///
  /// In en, this message translates to:
  /// **'Choose save location'**
  String get chooseSaveLocation;

  /// Message shown when game is saved
  ///
  /// In en, this message translates to:
  /// **'Game saved'**
  String get gameSaved;

  /// Message shown when save fails
  ///
  /// In en, this message translates to:
  /// **'Save failed, please try again'**
  String get saveFailed;

  /// Message shown when analysis fails
  ///
  /// In en, this message translates to:
  /// **'Analysis failed, please try again'**
  String get analysisFailed;

  /// Title for human vs AI
  ///
  /// In en, this message translates to:
  /// **'Human vs AI'**
  String get humanVsAi;

  /// AI
  ///
  /// In en, this message translates to:
  /// **'AI'**
  String get ai;

  /// You
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get you;

  /// Computer
  ///
  /// In en, this message translates to:
  /// **'Computer'**
  String get computer;

  /// Player
  ///
  /// In en, this message translates to:
  /// **'Player'**
  String get player;

  /// Title for confirm draw
  ///
  /// In en, this message translates to:
  /// **'Confirm Draw?'**
  String get confirmDraw;

  /// Message for confirm draw
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to propose a draw?'**
  String get areYouSureYouWantToProposeADraw;

  /// Takeback
  ///
  /// In en, this message translates to:
  /// **'Takeback'**
  String get takeback;

  /// Accept
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// Reject
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get reject;

  /// OK
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Message for takeback declined
  ///
  /// In en, this message translates to:
  /// **'Takeback Declined'**
  String get takebackDeclined;

  /// Message for draw declined
  ///
  /// In en, this message translates to:
  /// **'Draw Declined'**
  String get drawDeclined;

  /// Message for opponent requests takeback
  ///
  /// In en, this message translates to:
  /// **'Opponent requests a takeback, do you accept?'**
  String get opponentRequestsTakeback;

  /// Message for opponent proposes draw
  ///
  /// In en, this message translates to:
  /// **'Opponent proposes a draw, do you accept?'**
  String get opponentProposesDraw;

  /// Yes
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// Message for are you sure you want to request a takeback
  ///
  /// In en, this message translates to:
  /// **'Are y ou sure you want to request a takeback?'**
  String get areYouSureYouWantToRequestATakeback;

  /// Title for confirm takeback
  ///
  /// In en, this message translates to:
  /// **'Confirm Takeback?'**
  String get confirmTakeback;

  /// Message for are you sure you want to resign
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to resign?'**
  String get areYouSureYouWantToResign;

  /// Title for confirm resign
  ///
  /// In en, this message translates to:
  /// **'Confirm Resign?'**
  String get confirmResign;

  /// Message for searching for an opponent
  ///
  /// In en, this message translates to:
  /// **'Searching for an opponent...'**
  String get searchingForAnOpponent;

  /// Title for play online
  ///
  /// In en, this message translates to:
  /// **'Play Online'**
  String get playOnline;

  /// Connect
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Match
  ///
  /// In en, this message translates to:
  /// **'Match'**
  String get match;

  /// Propose Draw
  ///
  /// In en, this message translates to:
  /// **'Propose Draw'**
  String get proposeDraw;

  /// Cancel
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Resign
  ///
  /// In en, this message translates to:
  /// **'Resign'**
  String get resign;

  /// Take Back
  ///
  /// In en, this message translates to:
  /// **'Take Back'**
  String get takeBack;

  /// Promotion
  ///
  /// In en, this message translates to:
  /// **'Promotion'**
  String get promotion;

  /// Full / Empty
  ///
  /// In en, this message translates to:
  /// **'Full / Empty'**
  String get fullEmpty;

  /// Play with AI
  ///
  /// In en, this message translates to:
  /// **'Play with AI'**
  String get playWithAI;

  /// Drag & drop here to remove
  ///
  /// In en, this message translates to:
  /// **'Drag & drop here to remove'**
  String get dragAndDropToRemove;

  /// Invalid position
  ///
  /// In en, this message translates to:
  /// **'Invalid position, please check:\n1. Each side has one king\n2. Pawns cannot be on the first or eighth rank'**
  String get invalidPosition;

  /// Setup Board
  ///
  /// In en, this message translates to:
  /// **'Setup Board'**
  String get setupBoard;

  /// All Games
  ///
  /// In en, this message translates to:
  /// **'All Games'**
  String get allGames;

  /// Favorites
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No favorite games available
  ///
  /// In en, this message translates to:
  /// **'No favorite games available'**
  String get noFavoriteGamesAvailable;

  /// Search games
  ///
  /// In en, this message translates to:
  /// **'Search games...'**
  String get searchGames;

  /// Games
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// Failed to load games list
  ///
  /// In en, this message translates to:
  /// **'Failed to load games list: {error}'**
  String failedToLoadGamesList(String error);

  /// Comments
  ///
  /// In en, this message translates to:
  /// **'Comments: {comments}'**
  String comments(String comments);

  /// Branch Selection
  ///
  /// In en, this message translates to:
  /// **'Branch Selection'**
  String get branchSelection;

  /// Chess Viewer
  ///
  /// In en, this message translates to:
  /// **'Chess Viewer'**
  String get chessViewer;

  /// Start
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// Previous
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// Next
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// End
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// Added to favorites
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// Removed from favorites
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// Server Address
  ///
  /// In en, this message translates to:
  /// **'Server Address'**
  String get serverAddress;

  /// Set Server Address
  ///
  /// In en, this message translates to:
  /// **'Set Server Address'**
  String get setServerAddress;

  /// Please enter the server address
  ///
  /// In en, this message translates to:
  /// **'Please enter the server address'**
  String get pleaseEnterTheServerAddress;

  /// Settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Engine Settings
  ///
  /// In en, this message translates to:
  /// **'Engine Settings'**
  String get engineSettings;

  /// Thinking Time
  ///
  /// In en, this message translates to:
  /// **'Thinking Time'**
  String get thinkingTime;

  /// Limit Time
  ///
  /// In en, this message translates to:
  /// **'Limit Time'**
  String get limitTime;

  /// Limit Depth
  ///
  /// In en, this message translates to:
  /// **'Limit Depth'**
  String get limitDepth;

  /// Time Control Mode
  ///
  /// In en, this message translates to:
  /// **'Time Control Mode'**
  String get timeControlMode;

  /// Use Time Control
  ///
  /// In en, this message translates to:
  /// **'Use Time Control'**
  String get useTimeControl;

  /// Show predicted moves when the engine is thinking
  ///
  /// In en, this message translates to:
  /// **'Show predicted moves when the engine is thinking'**
  String get showPredictedMovesWhenTheEngineIsThinking;

  /// Language Settings
  ///
  /// In en, this message translates to:
  /// **'Language Settings'**
  String get languageSettings;

  /// Layers
  ///
  /// In en, this message translates to:
  /// **'layers'**
  String get layers;

  /// Current
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// Browse
  ///
  /// In en, this message translates to:
  /// **'Browse'**
  String get browse;

  /// Confirm
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Select Piece Theme
  ///
  /// In en, this message translates to:
  /// **'Select Piece Theme'**
  String get selectPieceTheme;

  /// Select Theme Color
  ///
  /// In en, this message translates to:
  /// **'Select Theme Color'**
  String get selectThemeColor;

  /// Set Engine Level
  ///
  /// In en, this message translates to:
  /// **'Set Engine Level'**
  String get setEngineLevel;

  /// Set Thinking Time
  ///
  /// In en, this message translates to:
  /// **'Set Thinking Time'**
  String get setThinkingTime;

  /// Set Search Depth
  ///
  /// In en, this message translates to:
  /// **'Set Search Depth'**
  String get setSearchDepth;

  /// Set Engine Path
  ///
  /// In en, this message translates to:
  /// **'Set Engine Path'**
  String get setEnginePath;

  /// Please enter the engine path
  ///
  /// In en, this message translates to:
  /// **'Please enter the engine path'**
  String get pleaseEnterTheEnginePath;

  /// View Games
  ///
  /// In en, this message translates to:
  /// **'View Games'**
  String get viewGames;

  /// Explore the infinite possibilities of chess
  ///
  /// In en, this message translates to:
  /// **'Explore the infinite possibilities of chess'**
  String get exploreTheInfinitePossibilitiesOfChess;

  /// Checkmated
  ///
  /// In en, this message translates to:
  /// **'Checkmated'**
  String get checkmated;

  /// Opponent Out of Time
  ///
  /// In en, this message translates to:
  /// **'Opponent Out of Time'**
  String get opponentOutOfTime;

  /// Opponent Resigned
  ///
  /// In en, this message translates to:
  /// **'Opponent Resigned'**
  String get opponentResigned;

  /// Opponent Left
  ///
  /// In en, this message translates to:
  /// **'Opponent Left'**
  String get opponentLeft;

  /// Out of Time
  ///
  /// In en, this message translates to:
  /// **'Out of Time'**
  String get outOfTime;

  /// Resigned
  ///
  /// In en, this message translates to:
  /// **'Resigned'**
  String get resigned;

  /// Stalemate
  ///
  /// In en, this message translates to:
  /// **'Stalemate'**
  String get stalemate;

  /// Consensus
  ///
  /// In en, this message translates to:
  /// **'Consensus'**
  String get consensus;

  /// Time Control
  ///
  /// In en, this message translates to:
  /// **'Time Control'**
  String get timeControl;

  /// Chess Clock
  ///
  /// In en, this message translates to:
  /// **'Chess Clock'**
  String get chessClock;

  /// Opening Explorer
  ///
  /// In en, this message translates to:
  /// **'Opening Explorer'**
  String get openingExplorer;

  /// Save
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fr', 'hi', 'it', 'ja', 'ko', 'pl', 'ru', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fr': return AppLocalizationsFr();
    case 'hi': return AppLocalizationsHi();
    case 'it': return AppLocalizationsIt();
    case 'ja': return AppLocalizationsJa();
    case 'ko': return AppLocalizationsKo();
    case 'pl': return AppLocalizationsPl();
    case 'ru': return AppLocalizationsRu();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
