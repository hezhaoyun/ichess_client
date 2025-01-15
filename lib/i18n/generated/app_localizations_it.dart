// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'Tema colore';

  @override
  String get pieceTheme => 'Stile dei pezzi';

  @override
  String get serverSettings => 'Impostazioni server';

  @override
  String get engineLevel => 'Livello motore';

  @override
  String get moveTime => 'Tempo per mossa';

  @override
  String get searchDepth => 'Profondità di ricerca';

  @override
  String get enginePath => 'Percorso motore';

  @override
  String get showAnalysisArrows => 'Mostra frecce analisi';

  @override
  String get language => 'Lingua';

  @override
  String get insufficientMaterial => 'Materiale insufficiente, patta';

  @override
  String get threefoldRepetition => 'Tripla ripetizione, patta';

  @override
  String get draw => 'Patta';

  @override
  String failedToLoadFile(String error) {
    return 'Caricamento file fallito: $error';
  }

  @override
  String get newGame => 'Nuova partita';

  @override
  String get undo => 'Annulla';

  @override
  String get redo => 'Ripeti';

  @override
  String get engineInitializationFailed => 'Inizializzazione motore fallita!';

  @override
  String get hint => 'Suggerimento';

  @override
  String get analyzing => 'Analisi in corso...';

  @override
  String get dontBeDiscouraged => 'Non scoraggiarti, continua a provare!';

  @override
  String get congratulations => 'Congratulazioni per la vittoria!';

  @override
  String get youWon => 'Hai vinto!';

  @override
  String get youLost => 'Hai perso!';

  @override
  String get engineCannotFindValidMove => 'Il motore non trova mosse valide';

  @override
  String engineMoveError(String error) {
    return 'Errore mossa motore: $error';
  }

  @override
  String get chooseYourColor => 'Scegli il tuo colore';

  @override
  String get white => 'Bianco';

  @override
  String get black => 'Nero';

  @override
  String get chooseSaveLocation => 'Scegli posizione di salvataggio';

  @override
  String get gameSaved => 'Partita salvata';

  @override
  String get saveFailed => 'Salvataggio fallito, riprova';

  @override
  String get analysisFailed => 'Analisi fallita, riprova';

  @override
  String get humanVsAi => 'Umano vs IA';

  @override
  String get ai => 'IA';

  @override
  String get you => 'Tu';

  @override
  String get computer => 'Computer';

  @override
  String get player => 'Giocatore';

  @override
  String get confirmDraw => 'Confermare patta?';

  @override
  String get areYouSureYouWantToProposeADraw => 'Sei sicuro di voler proporre la patta?';

  @override
  String get takeback => 'Riprendere';

  @override
  String get accept => 'Accetta';

  @override
  String get reject => 'Rifiuta';

  @override
  String get ok => 'OK';

  @override
  String get takebackDeclined => 'Ripresa rifiutata';

  @override
  String get drawDeclined => 'Patta rifiutata';

  @override
  String get opponentRequestsTakeback => 'L\'avversario chiede di riprendere, accetti?';

  @override
  String get opponentProposesDraw => 'L\'avversario propone la patta, accetti?';

  @override
  String get yes => 'Sì';

  @override
  String get no => 'No';

  @override
  String get areYouSureYouWantToRequestATakeback => 'Sei sicuro di voler chiedere di riprendere?';

  @override
  String get confirmTakeback => 'Confermare ripresa?';

  @override
  String get areYouSureYouWantToResign => 'Sei sicuro di voler abbandonare?';

  @override
  String get confirmResign => 'Confermare abbandono?';

  @override
  String get searchingForAnOpponent => 'Ricerca avversario...';

  @override
  String get playOnline => 'Gioca online';

  @override
  String get connect => 'Connetti';

  @override
  String get match => 'Partita';

  @override
  String get proposeDraw => 'Proponi patta';

  @override
  String get cancel => 'Annulla';

  @override
  String get resign => 'Abbandona';

  @override
  String get takeBack => 'Riprendi';

  @override
  String get promotion => 'Promozione';

  @override
  String get fullEmpty => 'Pieno / Vuoto';

  @override
  String get playWithAI => 'Gioca contro l\'IA';

  @override
  String get dragAndDropToRemove => 'Trascina qui per rimuovere';

  @override
  String get invalidPosition => 'Posizione non valida, controlla:\n1. Ogni lato deve avere un re\n2. I pedoni non possono stare sulla prima o ultima traversa';

  @override
  String get freeBoard => 'Imposta scacchiera';

  @override
  String get allGames => 'Tutte le partite';

  @override
  String get favorites => 'Preferiti';

  @override
  String get noFavoriteGamesAvailable => 'Nessuna partita preferita disponibile';

  @override
  String get searchGames => 'Cerca partite...';

  @override
  String get games => 'Partite';

  @override
  String failedToLoadGamesList(String error) {
    return 'Caricamento lista partite fallito: $error';
  }

  @override
  String comments(String comments) {
    return 'Commenti: $comments';
  }

  @override
  String get branchSelection => 'Selezione variante';

  @override
  String get chessViewer => 'Visualizzatore scacchi';

  @override
  String get start => 'Inizio';

  @override
  String get previous => 'Precedente';

  @override
  String get next => 'Successivo';

  @override
  String get end => 'Fine';

  @override
  String get addedToFavorites => 'Aggiunto ai preferiti';

  @override
  String get removedFromFavorites => 'Rimosso dai preferiti';

  @override
  String get serverAddress => 'Indirizzo server';

  @override
  String get setServerAddress => 'Imposta indirizzo server';

  @override
  String get pleaseEnterTheServerAddress => 'Inserisci l\'indirizzo del server';

  @override
  String get settings => 'Impostazioni';

  @override
  String get engineSettings => 'Impostazioni motore';

  @override
  String get thinkingTime => 'Tempo di riflessione';

  @override
  String get limitTime => 'Limite tempo';

  @override
  String get limitDepth => 'Limite profondità';

  @override
  String get timeControlMode => 'Modalità controllo tempo';

  @override
  String get useTimeControl => 'Usa controllo tempo';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'Mostra mosse previste durante l\'analisi del motore';

  @override
  String get languageSettings => 'Impostazioni lingua';

  @override
  String get layers => 'Livelli';

  @override
  String get current => 'Attuale';

  @override
  String get browse => 'Sfoglia';

  @override
  String get confirm => 'Conferma';

  @override
  String get selectPieceTheme => 'Seleziona stile pezzi';

  @override
  String get selectThemeColor => 'Seleziona tema colore';

  @override
  String get setEngineLevel => 'Imposta livello motore';

  @override
  String get setThinkingTime => 'Imposta tempo di riflessione';

  @override
  String get setSearchDepth => 'Imposta profondità di ricerca';

  @override
  String get setEnginePath => 'Imposta percorso motore';

  @override
  String get pleaseEnterTheEnginePath => 'Inserisci il percorso del motore';

  @override
  String get viewGames => 'Visualizza partite';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'Esplora le infinite possibilità degli scacchi';

  @override
  String get checkmated => 'Scacco matto';

  @override
  String get opponentOutOfTime => 'Tempo scaduto per l\'avversario';

  @override
  String get opponentResigned => 'L\'avversario ha abbandonato';

  @override
  String get opponentLeft => 'L\'avversario ha lasciato';

  @override
  String get outOfTime => 'Tempo scaduto';

  @override
  String get resigned => 'Abbandonato';

  @override
  String get stalemate => 'Stallo';

  @override
  String get consensus => 'Consenso';

  @override
  String get timeControl => 'Controllo tempo';

  @override
  String get chessClock => 'Reloj de ajedrez';

  @override
  String get openingExplorer => 'Esplora aperture';

  @override
  String get save => 'Salva';

  @override
  String get flipBoard => 'Invertire tablero';
}
