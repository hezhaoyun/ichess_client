// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'Motyw kolorystyczny';

  @override
  String get pieceTheme => 'Styl figur';

  @override
  String get serverSettings => 'Ustawienia serwera';

  @override
  String get engineLevel => 'Poziom silnika';

  @override
  String get moveTime => 'Czas na ruch';

  @override
  String get searchDepth => 'Głębokość przeszukiwania';

  @override
  String get enginePath => 'Ścieżka do silnika';

  @override
  String get showAnalysisArrows => 'Pokaż strzałki analizy';

  @override
  String get language => 'Język';

  @override
  String get insufficientMaterial => 'Niewystarczający materiał, remis';

  @override
  String get threefoldRepetition => 'Trzykrotne powtórzenie pozycji, remis';

  @override
  String get draw => 'Remis';

  @override
  String failedToLoadFile(String error) {
    return 'Nie udało się załadować pliku: $error';
  }

  @override
  String get newGame => 'Nowa gra';

  @override
  String get undo => 'Cofnij';

  @override
  String get engineInitializationFailed => 'Inicjalizacja silnika nie powiodła się!';

  @override
  String get hint => 'Podpowiedź';

  @override
  String get analyzing => 'Analizowanie...';

  @override
  String get dontBeDiscouraged => 'Nie zniechęcaj się, próbuj dalej!';

  @override
  String get congratulations => 'Gratulacje za zwycięstwo!';

  @override
  String get youWon => 'Wygrałeś!';

  @override
  String get youLost => 'Przegrałeś!';

  @override
  String get engineCannotFindValidMove => 'Silnik nie może znaleźć prawidłowego ruchu';

  @override
  String engineMoveError(String error) {
    return 'Błąd ruchu silnika: $error';
  }

  @override
  String get chooseYourColor => 'Wybierz swój kolor';

  @override
  String get white => 'Białe';

  @override
  String get black => 'Czarne';

  @override
  String get chooseSaveLocation => 'Wybierz miejsce zapisu';

  @override
  String get gameSaved => 'Gra zapisana';

  @override
  String get saveFailed => 'Zapis nie powiódł się, spróbuj ponownie';

  @override
  String get analysisFailed => 'Analiza nie powiodła się, spróbuj ponownie';

  @override
  String get humanVsAi => 'Człowiek vs SI';

  @override
  String get ai => 'SI';

  @override
  String get you => 'Ty';

  @override
  String get computer => 'Komputer';

  @override
  String get player => 'Gracz';

  @override
  String get confirmDraw => 'Potwierdzić remis?';

  @override
  String get areYouSureYouWantToProposeADraw => 'Czy na pewno chcesz zaproponować remis?';

  @override
  String get takeback => 'Cofnij ruch';

  @override
  String get accept => 'Akceptuj';

  @override
  String get reject => 'Odrzuć';

  @override
  String get ok => 'OK';

  @override
  String get takebackDeclined => 'Cofnięcie ruchu odrzucone';

  @override
  String get drawDeclined => 'Remis odrzucony';

  @override
  String get opponentRequestsTakeback => 'Przeciwnik prosi o cofnięcie ruchu, zgadzasz się?';

  @override
  String get opponentProposesDraw => 'Przeciwnik proponuje remis, zgadzasz się?';

  @override
  String get yes => 'Tak';

  @override
  String get no => 'Nie';

  @override
  String get areYouSureYouWantToRequestATakeback => 'Czy na pewno chcesz poprosić o cofnięcie ruchu?';

  @override
  String get confirmTakeback => 'Potwierdzić cofnięcie ruchu?';

  @override
  String get areYouSureYouWantToResign => 'Czy na pewno chcesz się poddać?';

  @override
  String get confirmResign => 'Potwierdzić poddanie?';

  @override
  String get searchingForAnOpponent => 'Szukanie przeciwnika...';

  @override
  String get playOnline => 'Graj online';

  @override
  String get connect => 'Połącz';

  @override
  String get match => 'Partia';

  @override
  String get proposeDraw => 'Zaproponuj remis';

  @override
  String get cancel => 'Anuluj';

  @override
  String get resign => 'Poddaj się';

  @override
  String get takeBack => 'Cofnij ruch';

  @override
  String get promotion => 'Promocja';

  @override
  String get fullEmpty => 'Pełny / Pusty';

  @override
  String get playWithAI => 'Graj z SI';

  @override
  String get dragAndDropToRemove => 'Przeciągnij i upuść tutaj, aby usunąć';

  @override
  String get invalidPosition => 'Nieprawidłowa pozycja, sprawdź:\n1. Każda strona musi mieć króla\n2. Piony nie mogą znajdować się na pierwszej ani ostatniej linii';

  @override
  String get setupBoard => 'Ustaw szachownicę';

  @override
  String get allGames => 'Wszystkie partie';

  @override
  String get favorites => 'Ulubione';

  @override
  String get noFavoriteGamesAvailable => 'Brak ulubionych partii';

  @override
  String get searchGames => 'Szukaj partii...';

  @override
  String get games => 'Partie';

  @override
  String failedToLoadGamesList(String error) {
    return 'Nie udało się załadować listy partii: $error';
  }

  @override
  String comments(String comments) {
    return 'Komentarze: $comments';
  }

  @override
  String get branchSelection => 'Wybór wariantu';

  @override
  String get chessViewer => 'Przeglądarka szachowa';

  @override
  String get start => 'Start';

  @override
  String get previous => 'Poprzedni';

  @override
  String get next => 'Następny';

  @override
  String get end => 'Koniec';

  @override
  String get addedToFavorites => 'Dodano do ulubionych';

  @override
  String get removedFromFavorites => 'Usunięto z ulubionych';

  @override
  String get serverAddress => 'Adres serwera';

  @override
  String get setServerAddress => 'Ustaw adres serwera';

  @override
  String get pleaseEnterTheServerAddress => 'Wprowadź adres serwera';

  @override
  String get settings => 'Ustawienia';

  @override
  String get engineSettings => 'Ustawienia silnika';

  @override
  String get thinkingTime => 'Czas na myślenie';

  @override
  String get limitTime => 'Limit czasu';

  @override
  String get limitDepth => 'Limit głębokości';

  @override
  String get timeControlMode => 'Tryb kontroli czasu';

  @override
  String get useTimeControl => 'Użyj kontroli czasu';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'Pokaż przewidywane ruchy podczas myślenia silnika';

  @override
  String get languageSettings => 'Ustawienia języka';

  @override
  String get layers => 'Warstwy';

  @override
  String get current => 'Obecny';

  @override
  String get browse => 'Przeglądaj';

  @override
  String get confirm => 'Potwierdź';

  @override
  String get selectPieceTheme => 'Wybierz styl figur';

  @override
  String get selectThemeColor => 'Wybierz motyw kolorystyczny';

  @override
  String get setEngineLevel => 'Ustaw poziom silnika';

  @override
  String get setThinkingTime => 'Ustaw czas na myślenie';

  @override
  String get setSearchDepth => 'Ustaw głębokość przeszukiwania';

  @override
  String get setEnginePath => 'Ustaw ścieżkę silnika';

  @override
  String get pleaseEnterTheEnginePath => 'Wprowadź ścieżkę do silnika';

  @override
  String get viewGames => 'Zobacz partie';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'Odkryj nieskończone możliwości szachów';

  @override
  String get checkmated => 'Mat';

  @override
  String get opponentOutOfTime => 'Przeciwnik przekroczył czas';

  @override
  String get opponentResigned => 'Przeciwnik się poddał';

  @override
  String get opponentLeft => 'Przeciwnik opuścił grę';

  @override
  String get outOfTime => 'Przekroczenie czasu';

  @override
  String get resigned => 'Poddana';

  @override
  String get stalemate => 'Pat';

  @override
  String get consensus => 'Zgoda';

  @override
  String get timeControl => 'Kontrola czasu';

  @override
  String get chessClock => 'Szachowe zegary';

  @override
  String get openingExplorer => 'Eksplorator otwarć';

  @override
  String get save => 'Zapisz';
}
