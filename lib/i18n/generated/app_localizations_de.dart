// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'Farbthema';

  @override
  String get pieceTheme => 'Figurendesign';

  @override
  String get serverSettings => 'Servereinstellungen';

  @override
  String get engineLevel => 'Engine-Stufe';

  @override
  String get moveTime => 'Zugzeit';

  @override
  String get searchDepth => 'Suchtiefe';

  @override
  String get enginePath => 'Engine-Pfad';

  @override
  String get showAnalysisArrows => 'Analysepfeile anzeigen';

  @override
  String get language => 'Sprache';

  @override
  String get insufficientMaterial => 'Unzureichendes Material, Remis';

  @override
  String get threefoldRepetition => 'Dreimalige Wiederholung, Remis';

  @override
  String get draw => 'Remis';

  @override
  String failedToLoadFile(String error) {
    return 'Fehler beim Laden der Datei: $error';
  }

  @override
  String get newGame => 'Neues Spiel';

  @override
  String get undo => 'Rückgängig';

  @override
  String get engineInitializationFailed => 'Engine-Initialisierung fehlgeschlagen!';

  @override
  String get hint => 'Tipp';

  @override
  String get analyzing => 'Analysiere...';

  @override
  String get dontBeDiscouraged => 'Lass dich nicht entmutigen, bleib dran!';

  @override
  String get congratulations => 'Herzlichen Glückwunsch zum Sieg!';

  @override
  String get youWon => 'Du hast gewonnen!';

  @override
  String get youLost => 'Du hast verloren!';

  @override
  String get engineCannotFindValidMove => 'Engine findet keinen gültigen Zug';

  @override
  String engineMoveError(String error) {
    return 'Engine-Zugfehler: $error';
  }

  @override
  String get chooseYourColor => 'Wähle deine Farbe';

  @override
  String get white => 'Weiß';

  @override
  String get black => 'Schwarz';

  @override
  String get chooseSaveLocation => 'Speicherort wählen';

  @override
  String get gameSaved => 'Spiel gespeichert';

  @override
  String get saveFailed => 'Speichern fehlgeschlagen, bitte erneut versuchen';

  @override
  String get analysisFailed => 'Analyse fehlgeschlagen, bitte erneut versuchen';

  @override
  String get humanVsAi => 'Mensch gegen KI';

  @override
  String get ai => 'KI';

  @override
  String get you => 'Du';

  @override
  String get computer => 'Computer';

  @override
  String get player => 'Spieler';

  @override
  String get confirmDraw => 'Remis bestätigen?';

  @override
  String get areYouSureYouWantToProposeADraw => 'Möchtest du wirklich ein Remis vorschlagen?';

  @override
  String get takeback => 'Zurücknehmen';

  @override
  String get accept => 'Annehmen';

  @override
  String get reject => 'Ablehnen';

  @override
  String get ok => 'OK';

  @override
  String get takebackDeclined => 'Zurücknahme abgelehnt';

  @override
  String get drawDeclined => 'Remis abgelehnt';

  @override
  String get opponentRequestsTakeback => 'Gegner möchte einen Zug zurücknehmen, einverstanden?';

  @override
  String get opponentProposesDraw => 'Gegner schlägt Remis vor, einverstanden?';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get areYouSureYouWantToRequestATakeback => 'Möchtest du wirklich eine Zugzurücknahme beantragen?';

  @override
  String get confirmTakeback => 'Zurücknahme bestätigen?';

  @override
  String get areYouSureYouWantToResign => 'Möchtest du wirklich aufgeben?';

  @override
  String get confirmResign => 'Aufgabe bestätigen?';

  @override
  String get searchingForAnOpponent => 'Suche nach einem Gegner...';

  @override
  String get playOnline => 'Online spielen';

  @override
  String get connect => 'Verbinden';

  @override
  String get match => 'Partie';

  @override
  String get proposeDraw => 'Remis vorschlagen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get resign => 'Aufgeben';

  @override
  String get takeBack => 'Zurücknehmen';

  @override
  String get promotion => 'Umwandlung';

  @override
  String get fullEmpty => 'Voll / Leer';

  @override
  String get playWithAI => 'Gegen KI spielen';

  @override
  String get dragAndDropToRemove => 'Zum Entfernen hierher ziehen';

  @override
  String get invalidPosition => 'Ungültige Position, bitte prüfen:\n1. Jede Seite hat einen König\n2. Bauern können nicht auf der ersten oder achten Reihe stehen';

  @override
  String get setupBoard => 'Brett aufbauen';

  @override
  String get allGames => 'Alle Partien';

  @override
  String get favorites => 'Favoriten';

  @override
  String get noFavoriteGamesAvailable => 'Keine Favoriten verfügbar';

  @override
  String get searchGames => 'Partien suchen...';

  @override
  String get games => 'Partien';

  @override
  String failedToLoadGamesList(String error) {
    return 'Fehler beim Laden der Partieliste: $error';
  }

  @override
  String comments(String comments) {
    return 'Kommentare: $comments';
  }

  @override
  String get branchSelection => 'Variantenauswahl';

  @override
  String get chessViewer => 'Partieansicht';

  @override
  String get start => 'Start';

  @override
  String get previous => 'Zurück';

  @override
  String get next => 'Weiter';

  @override
  String get end => 'Ende';

  @override
  String get addedToFavorites => 'Zu Favoriten hinzugefügt';

  @override
  String get removedFromFavorites => 'Aus Favoriten entfernt';

  @override
  String get serverAddress => 'Serveradresse';

  @override
  String get setServerAddress => 'Serveradresse festlegen';

  @override
  String get pleaseEnterTheServerAddress => 'Bitte gib die Serveradresse ein';

  @override
  String get settings => 'Einstellungen';

  @override
  String get engineSettings => 'Engine-Einstellungen';

  @override
  String get thinkingTime => 'Bedenkzeit';

  @override
  String get limitTime => 'Zeitlimit';

  @override
  String get limitDepth => 'Tiefenlimit';

  @override
  String get timeControlMode => 'Zeitkontrolle';

  @override
  String get useTimeControl => 'Zeitkontrolle verwenden';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'Vorhergesagte Züge während der Engine-Analyse anzeigen';

  @override
  String get languageSettings => 'Spracheinstellungen';

  @override
  String get layers => 'Ebenen';

  @override
  String get current => 'Aktuell';

  @override
  String get browse => 'Durchsuchen';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get selectPieceTheme => 'Figurendesign wählen';

  @override
  String get selectThemeColor => 'Farbthema wählen';

  @override
  String get setEngineLevel => 'Engine-Stufe einstellen';

  @override
  String get setThinkingTime => 'Bedenkzeit einstellen';

  @override
  String get setSearchDepth => 'Suchtiefe einstellen';

  @override
  String get setEnginePath => 'Engine-Pfad einstellen';

  @override
  String get pleaseEnterTheEnginePath => 'Bitte gib den Engine-Pfad ein';

  @override
  String get viewGames => 'Partien ansehen';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'Entdecke die unendlichen Möglichkeiten des Schachspiels';

  @override
  String get checkmated => 'Matt';

  @override
  String get opponentOutOfTime => 'Gegner Zeit abgelaufen';

  @override
  String get opponentResigned => 'Gegner hat aufgegeben';

  @override
  String get opponentLeft => 'Gegner hat verlassen';

  @override
  String get outOfTime => 'Zeit abgelaufen';

  @override
  String get resigned => 'Aufgegeben';

  @override
  String get stalemate => 'Patt';

  @override
  String get consensus => 'Einverständnis';

  @override
  String get timeControl => 'Zeitkontrolle';

  @override
  String get chessClock => 'Schachuhr';

  @override
  String get openingExplorer => 'Opening Explorer';

  @override
  String get save => 'Speichern';
}
