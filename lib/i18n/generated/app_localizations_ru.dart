// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'Цветовая тема';

  @override
  String get pieceTheme => 'Тема фигур';

  @override
  String get serverSettings => 'Настройки сервера';

  @override
  String get engineLevel => 'Уровень движка';

  @override
  String get moveTime => 'Время на ход';

  @override
  String get searchDepth => 'Глубина поиска';

  @override
  String get enginePath => 'Путь к движку';

  @override
  String get showAnalysisArrows => 'Показывать стрелки анализа';

  @override
  String get language => 'Язык';

  @override
  String get insufficientMaterial => 'Недостаточно материала, ничья';

  @override
  String get threefoldRepetition => 'Троекратное повторение, ничья';

  @override
  String get draw => 'Ничья';

  @override
  String failedToLoadFile(String error) {
    return 'Не удалось загрузить файл: $error';
  }

  @override
  String get newGame => 'Новая игра';

  @override
  String get undo => 'Отменить';

  @override
  String get engineInitializationFailed => 'Ошибка инициализации движка!';

  @override
  String get hint => 'Подсказка';

  @override
  String get analyzing => 'Анализ...';

  @override
  String get dontBeDiscouraged => 'Не отчаивайтесь, продолжайте пробовать!';

  @override
  String get congratulations => 'Поздравляем с победой над соперником!';

  @override
  String get youWon => 'Вы победили!';

  @override
  String get youLost => 'Вы проиграли!';

  @override
  String get engineCannotFindValidMove => 'Движок не может найти допустимый ход';

  @override
  String engineMoveError(String error) {
    return 'Ошибка хода движка: $error';
  }

  @override
  String get chooseYourColor => 'Выберите цвет';

  @override
  String get white => 'Белые';

  @override
  String get black => 'Чёрные';

  @override
  String get chooseSaveLocation => 'Выберите место сохранения';

  @override
  String get gameSaved => 'Игра сохранена';

  @override
  String get saveFailed => 'Ошибка сохранения, попробуйте снова';

  @override
  String get analysisFailed => 'Ошибка анализа, попробуйте снова';

  @override
  String get humanVsAi => 'Человек против ИИ';

  @override
  String get ai => 'ИИ';

  @override
  String get you => 'Вы';

  @override
  String get computer => 'Компьютер';

  @override
  String get player => 'Игрок';

  @override
  String get confirmDraw => 'Подтвердить ничью?';

  @override
  String get areYouSureYouWantToProposeADraw => 'Вы уверены, что хотите предложить ничью?';

  @override
  String get takeback => 'Вернуть ход';

  @override
  String get accept => 'Принять';

  @override
  String get reject => 'Отклонить';

  @override
  String get ok => 'OK';

  @override
  String get takebackDeclined => 'Возврат хода отклонён';

  @override
  String get drawDeclined => 'Ничья отклонена';

  @override
  String get opponentRequestsTakeback => 'Соперник просит вернуть ход, согласны?';

  @override
  String get opponentProposesDraw => 'Соперник предлагает ничью, согласны?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get areYouSureYouWantToRequestATakeback => 'Вы уверены, что хотите попросить вернуть ход?';

  @override
  String get confirmTakeback => 'Подтвердить возврат хода?';

  @override
  String get areYouSureYouWantToResign => 'Вы уверены, что хотите сдаться?';

  @override
  String get confirmResign => 'Подтвердить сдачу?';

  @override
  String get searchingForAnOpponent => 'Поиск соперника...';

  @override
  String get playOnline => 'Играть онлайн';

  @override
  String get connect => 'Подключиться';

  @override
  String get match => 'Партия';

  @override
  String get proposeDraw => 'Предложить ничью';

  @override
  String get cancel => 'Отмена';

  @override
  String get resign => 'Сдаться';

  @override
  String get takeBack => 'Вернуть ход';

  @override
  String get promotion => 'Превращение';

  @override
  String get fullEmpty => 'Полная / Пустая';

  @override
  String get playWithAI => 'Играть с ИИ';

  @override
  String get dragAndDropToRemove => 'Перетащите сюда для удаления';

  @override
  String get invalidPosition => 'Недопустимая позиция, проверьте:\n1. У каждой стороны должен быть один король\n2. Пешки не могут находиться на первой или восьмой горизонтали';

  @override
  String get setupBoard => 'Расставить позицию';

  @override
  String get allGames => 'Все партии';

  @override
  String get favorites => 'Избранное';

  @override
  String get noFavoriteGamesAvailable => 'Нет избранных партий';

  @override
  String get searchGames => 'Поиск партий...';

  @override
  String get games => 'Партии';

  @override
  String failedToLoadGamesList(String error) {
    return 'Не удалось загрузить список партий: $error';
  }

  @override
  String comments(String comments) {
    return 'Комментарии: $comments';
  }

  @override
  String get branchSelection => 'Выбор варианта';

  @override
  String get chessViewer => 'Просмотр партий';

  @override
  String get start => 'Начало';

  @override
  String get previous => 'Назад';

  @override
  String get next => 'Вперёд';

  @override
  String get end => 'Конец';

  @override
  String get addedToFavorites => 'Добавлено в избранное';

  @override
  String get removedFromFavorites => 'Удалено из избранного';

  @override
  String get serverAddress => 'Адрес сервера';

  @override
  String get setServerAddress => 'Установить адрес сервера';

  @override
  String get pleaseEnterTheServerAddress => 'Пожалуйста, введите адрес сервера';

  @override
  String get settings => 'Настройки';

  @override
  String get engineSettings => 'Настройки движка';

  @override
  String get thinkingTime => 'Время на размышление';

  @override
  String get limitTime => 'Ограничение времени';

  @override
  String get limitDepth => 'Ограничение глубины';

  @override
  String get timeControlMode => 'Режим контроля времени';

  @override
  String get useTimeControl => 'Использовать контроль времени';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'Показывать предполагаемые ходы во время размышления движка';

  @override
  String get languageSettings => 'Настройки языка';

  @override
  String get layers => 'слои';

  @override
  String get current => 'Текущий';

  @override
  String get browse => 'Обзор';

  @override
  String get confirm => 'Подтвердить';

  @override
  String get selectPieceTheme => 'Выбрать тему фигур';

  @override
  String get selectThemeColor => 'Выбрать цвет темы';

  @override
  String get setEngineLevel => 'Установить уровень движка';

  @override
  String get setThinkingTime => 'Установить время на размышление';

  @override
  String get setSearchDepth => 'Установить глубину поиска';

  @override
  String get setEnginePath => 'Установить путь к движку';

  @override
  String get pleaseEnterTheEnginePath => 'Пожалуйста, введите путь к движку';

  @override
  String get viewGames => 'Просмотр партий';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'Исследуйте бесконечные возможности шахмат';

  @override
  String get checkmated => 'Мат';

  @override
  String get opponentOutOfTime => 'У соперника закончилось время';

  @override
  String get opponentResigned => 'Соперник сдался';

  @override
  String get opponentLeft => 'Соперник покинул игру';

  @override
  String get outOfTime => 'Время истекло';

  @override
  String get resigned => 'Сдался';

  @override
  String get stalemate => 'Пат';

  @override
  String get consensus => 'По согласию';

  @override
  String get timeControl => 'Контроль времени';

  @override
  String get chessClock => 'Шахматные часы';

  @override
  String get openingExplorer => 'Исследователь дебютов';

  @override
  String get save => 'Сохранить';
}
