// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'Tema de color';

  @override
  String get pieceTheme => 'Estilo de piezas';

  @override
  String get serverSettings => 'Configuración del servidor';

  @override
  String get engineLevel => 'Nivel del motor';

  @override
  String get moveTime => 'Tiempo por movimiento';

  @override
  String get searchDepth => 'Profundidad de búsqueda';

  @override
  String get enginePath => 'Ruta del motor';

  @override
  String get showAnalysisArrows => 'Mostrar flechas de análisis';

  @override
  String get language => 'Idioma';

  @override
  String get insufficientMaterial => 'Material insuficiente, tablas';

  @override
  String get threefoldRepetition => 'Triple repetición, tablas';

  @override
  String get draw => 'Tablas';

  @override
  String failedToLoadFile(String error) {
    return 'Error al cargar el archivo: $error';
  }

  @override
  String get newGame => 'Nueva partida';

  @override
  String get undo => 'Deshacer';

  @override
  String get redo => 'Repetir';

  @override
  String get engineInitializationFailed => '¡Falló la inicialización del motor!';

  @override
  String get hint => 'Pista';

  @override
  String get analyzing => 'Analizando...';

  @override
  String get dontBeDiscouraged => '¡No te desanimes, sigue intentándolo!';

  @override
  String get congratulations => '¡Felicitaciones por tu victoria!';

  @override
  String get youWon => '¡Has ganado!';

  @override
  String get youLost => '¡Has perdido!';

  @override
  String get engineCannotFindValidMove => 'El motor no puede encontrar un movimiento válido';

  @override
  String engineMoveError(String error) {
    return 'Error en movimiento del motor: $error';
  }

  @override
  String get chooseYourColor => 'Elige tu color';

  @override
  String get white => 'Blancas';

  @override
  String get black => 'Negras';

  @override
  String get chooseSaveLocation => 'Elegir ubicación para guardar';

  @override
  String get gameSaved => 'Partida guardada';

  @override
  String get saveFailed => 'Error al guardar, por favor intenta de nuevo';

  @override
  String get analysisFailed => 'Error en el análisis, por favor intenta de nuevo';

  @override
  String get humanVsAi => 'Humano vs IA';

  @override
  String get ai => 'IA';

  @override
  String get you => 'Tú';

  @override
  String get computer => 'Computadora';

  @override
  String get player => 'Jugador';

  @override
  String get confirmDraw => '¿Confirmar tablas?';

  @override
  String get areYouSureYouWantToProposeADraw => '¿Estás seguro de que quieres proponer tablas?';

  @override
  String get takeback => 'Retroceder';

  @override
  String get accept => 'Aceptar';

  @override
  String get reject => 'Rechazar';

  @override
  String get ok => 'OK';

  @override
  String get takebackDeclined => 'Retroceso rechazado';

  @override
  String get drawDeclined => 'Tablas rechazadas';

  @override
  String get opponentRequestsTakeback => 'El oponente solicita retroceder, ¿aceptas?';

  @override
  String get opponentProposesDraw => 'El oponente propone tablas, ¿aceptas?';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get areYouSureYouWantToRequestATakeback => '¿Estás seguro de que quieres solicitar un retroceso?';

  @override
  String get confirmTakeback => '¿Confirmar retroceso?';

  @override
  String get areYouSureYouWantToResign => '¿Estás seguro de que quieres abandonar?';

  @override
  String get confirmResign => '¿Confirmar abandono?';

  @override
  String get searchingForAnOpponent => 'Buscando oponente...';

  @override
  String get playOnline => 'Jugar en línea';

  @override
  String get connect => 'Conectar';

  @override
  String get match => 'Partida';

  @override
  String get proposeDraw => 'Proponer tablas';

  @override
  String get cancel => 'Cancelar';

  @override
  String get resign => 'Abandonar';

  @override
  String get takeBack => 'Retroceder';

  @override
  String get promotion => 'Promoción';

  @override
  String get fullEmpty => 'Lleno / Vacío';

  @override
  String get playWithAI => 'Jugar contra la IA';

  @override
  String get dragAndDropToRemove => 'Arrastra y suelta aquí para eliminar';

  @override
  String get invalidPosition => 'Posición inválida, por favor verifica:\n1. Cada lado debe tener un rey\n2. Los peones no pueden estar en la primera ni última fila';

  @override
  String get setupBoard => 'Configurar tablero';

  @override
  String get allGames => 'Todas las partidas';

  @override
  String get favorites => 'Favoritos';

  @override
  String get noFavoriteGamesAvailable => 'No hay partidas favoritas disponibles';

  @override
  String get searchGames => 'Buscar partidas...';

  @override
  String get games => 'Partidas';

  @override
  String failedToLoadGamesList(String error) {
    return 'Error al cargar la lista de partidas: $error';
  }

  @override
  String comments(String comments) {
    return 'Comentarios: $comments';
  }

  @override
  String get branchSelection => 'Selección de variante';

  @override
  String get chessViewer => 'Visor de ajedrez';

  @override
  String get start => 'Inicio';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Siguiente';

  @override
  String get end => 'Final';

  @override
  String get addedToFavorites => 'Añadido a favoritos';

  @override
  String get removedFromFavorites => 'Eliminado de favoritos';

  @override
  String get serverAddress => 'Dirección del servidor';

  @override
  String get setServerAddress => 'Establecer dirección del servidor';

  @override
  String get pleaseEnterTheServerAddress => 'Por favor, ingresa la dirección del servidor';

  @override
  String get settings => 'Configuración';

  @override
  String get engineSettings => 'Configuración del motor';

  @override
  String get thinkingTime => 'Tiempo de pensamiento';

  @override
  String get limitTime => 'Límite de tiempo';

  @override
  String get limitDepth => 'Límite de profundidad';

  @override
  String get timeControlMode => 'Modo de control de tiempo';

  @override
  String get useTimeControl => 'Usar control de tiempo';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'Mostrar movimientos predichos mientras el motor piensa';

  @override
  String get languageSettings => 'Configuración de idioma';

  @override
  String get layers => 'Capas';

  @override
  String get current => 'Actual';

  @override
  String get browse => 'Explorar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get selectPieceTheme => 'Seleccionar estilo de piezas';

  @override
  String get selectThemeColor => 'Seleccionar tema de color';

  @override
  String get setEngineLevel => 'Establecer nivel del motor';

  @override
  String get setThinkingTime => 'Establecer tiempo de pensamiento';

  @override
  String get setSearchDepth => 'Establecer profundidad de búsqueda';

  @override
  String get setEnginePath => 'Establecer ruta del motor';

  @override
  String get pleaseEnterTheEnginePath => 'Por favor, ingresa la ruta del motor';

  @override
  String get viewGames => 'Ver partidas';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'Explora las infinitas posibilidades del ajedrez';

  @override
  String get checkmated => 'Jaque mate';

  @override
  String get opponentOutOfTime => 'Tiempo agotado del oponente';

  @override
  String get opponentResigned => 'El oponente abandonó';

  @override
  String get opponentLeft => 'El oponente se fue';

  @override
  String get outOfTime => 'Tiempo agotado';

  @override
  String get resigned => 'Abandonó';

  @override
  String get stalemate => 'Ahogado';

  @override
  String get consensus => 'Consenso';

  @override
  String get timeControl => 'Tiempo de control';

  @override
  String get chessClock => 'Reloj de ajedrez';

  @override
  String get openingExplorer => 'Explorador de aperturas';

  @override
  String get save => 'Guardar';
}
