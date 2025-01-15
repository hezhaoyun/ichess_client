// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => '체스 로드';

  @override
  String get colorTheme => '색상 테마';

  @override
  String get pieceTheme => '체스말 테마';

  @override
  String get serverSettings => '서버 설정';

  @override
  String get engineLevel => '엔진 레벨';

  @override
  String get moveTime => '이동 시간';

  @override
  String get searchDepth => '탐색 깊이';

  @override
  String get enginePath => '엔진 경로';

  @override
  String get showAnalysisArrows => '분석 화살표 표시';

  @override
  String get language => '언어';

  @override
  String get insufficientMaterial => '부족한 말로 인한 무승부';

  @override
  String get threefoldRepetition => '동일 수 3회 반복으로 인한 무승부';

  @override
  String get draw => '무승부';

  @override
  String failedToLoadFile(String error) {
    return '파일 로드 실패: $error';
  }

  @override
  String get newGame => '새 게임';

  @override
  String get undo => '실행 취소';

  @override
  String get redo => '다시 실행';

  @override
  String get engineInitializationFailed => '엔진 초기화 실패!';

  @override
  String get hint => '힌트';

  @override
  String get analyzing => '분석 중...';

  @override
  String get dontBeDiscouraged => '실망하지 마세요, 계속 도전하세요!';

  @override
  String get congratulations => '상대를 이긴 것을 축하합니다!';

  @override
  String get youWon => '승리했습니다!';

  @override
  String get youLost => '패배했습니다!';

  @override
  String get engineCannotFindValidMove => '엔진이 유효한 수를 찾을 수 없습니다';

  @override
  String engineMoveError(String error) {
    return '엔진 이동 오류: $error';
  }

  @override
  String get chooseYourColor => '색상 선택';

  @override
  String get white => '백';

  @override
  String get black => '흑';

  @override
  String get chooseSaveLocation => '저장 위치 선택';

  @override
  String get gameSaved => '게임이 저장되었습니다';

  @override
  String get saveFailed => '저장 실패, 다시 시도해주세요';

  @override
  String get analysisFailed => '분석 실패, 다시 시도해주세요';

  @override
  String get humanVsAi => '사람 vs AI';

  @override
  String get ai => 'AI';

  @override
  String get you => '나';

  @override
  String get computer => '컴퓨터';

  @override
  String get player => '플레이어';

  @override
  String get confirmDraw => '무승부 확인';

  @override
  String get areYouSureYouWantToProposeADraw => '무승부를 제안하시겠습니까?';

  @override
  String get takeback => '무르기';

  @override
  String get accept => '수락';

  @override
  String get reject => '거절';

  @override
  String get ok => '확인';

  @override
  String get takebackDeclined => '무르기 거절됨';

  @override
  String get drawDeclined => '무승부 거절됨';

  @override
  String get opponentRequestsTakeback => '상대가 무르기를 요청했습니다. 수락하시겠습니까?';

  @override
  String get opponentProposesDraw => '상대가 무승부를 제안했습니다. 수락하시겠습니까?';

  @override
  String get yes => '예';

  @override
  String get no => '아니오';

  @override
  String get areYouSureYouWantToRequestATakeback => '무르기를 요청하시겠습니까?';

  @override
  String get confirmTakeback => '무르기 확인';

  @override
  String get areYouSureYouWantToResign => '기권하시겠습니까?';

  @override
  String get confirmResign => '기권 확인';

  @override
  String get searchingForAnOpponent => '상대를 찾는 중...';

  @override
  String get playOnline => '온라인 플레이';

  @override
  String get connect => '연결';

  @override
  String get match => '매치';

  @override
  String get proposeDraw => '무승부 제안';

  @override
  String get cancel => '취소';

  @override
  String get resign => '기권';

  @override
  String get takeBack => '무르기';

  @override
  String get promotion => '승진';

  @override
  String get fullEmpty => '전체 / 비우기';

  @override
  String get playWithAI => 'AI와 플레이';

  @override
  String get dragAndDropToRemove => '여기에 드래그 앤 드롭하여 제거';

  @override
  String get invalidPosition => '잘못된 위치입니다. 다음을 확인하세요:\n1. 각 진영에 킹이 하나씩 있어야 합니다\n2. 폰은 첫 줄이나 마지막 줄에 있을 수 없습니다';

  @override
  String get freeBoard => '보드 설정';

  @override
  String get allGames => '모든 게임';

  @override
  String get favorites => '즐겨찾기';

  @override
  String get noFavoriteGamesAvailable => '즐겨찾기한 게임이 없습니다';

  @override
  String get searchGames => '게임 검색...';

  @override
  String get games => '게임';

  @override
  String failedToLoadGamesList(String error) {
    return '게임 목록 로드 실패: $error';
  }

  @override
  String comments(String comments) {
    return '댓글: $comments';
  }

  @override
  String get branchSelection => '분기 선택';

  @override
  String get chessViewer => '체스 뷰어';

  @override
  String get start => '시작';

  @override
  String get previous => '이전';

  @override
  String get next => '다음';

  @override
  String get end => '끝';

  @override
  String get addedToFavorites => '즐겨찾기에 추가됨';

  @override
  String get removedFromFavorites => '즐겨찾기에서 제거됨';

  @override
  String get serverAddress => '서버 주소';

  @override
  String get setServerAddress => '서버 주소 설정';

  @override
  String get pleaseEnterTheServerAddress => '서버 주소를 입력하세요';

  @override
  String get settings => '설정';

  @override
  String get engineSettings => '엔진 설정';

  @override
  String get thinkingTime => '사고 시간';

  @override
  String get limitTime => '제한 시간';

  @override
  String get limitDepth => '제한 깊이';

  @override
  String get timeControlMode => '시간 제어 모드';

  @override
  String get useTimeControl => '시간 제어 사용';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => '엔진이 생각할 때 예상 수 표시';

  @override
  String get languageSettings => '언어 설정';

  @override
  String get layers => '레이어';

  @override
  String get current => '현재';

  @override
  String get browse => '찾아보기';

  @override
  String get confirm => '확인';

  @override
  String get selectPieceTheme => '체스말 테마 선택';

  @override
  String get selectThemeColor => '테마 색상 선택';

  @override
  String get setEngineLevel => '엔진 레벨 설정';

  @override
  String get setThinkingTime => '사고 시간 설정';

  @override
  String get setSearchDepth => '탐색 깊이 설정';

  @override
  String get setEnginePath => '엔진 경로 설정';

  @override
  String get pleaseEnterTheEnginePath => '엔진 경로를 입력하세요';

  @override
  String get viewGames => '게임 보기';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => '체스의 무한한 가능성을 탐험하세요';

  @override
  String get checkmated => '체크메이트';

  @override
  String get opponentOutOfTime => '상대방 시간 초과';

  @override
  String get opponentResigned => '상대방 기권';

  @override
  String get opponentLeft => '상대방 퇴장';

  @override
  String get outOfTime => '시간 초과';

  @override
  String get resigned => '기권';

  @override
  String get stalemate => '스테일메이트';

  @override
  String get consensus => '합의';

  @override
  String get timeControl => '시간 제어';

  @override
  String get chessClock => '체스 시계';

  @override
  String get openingExplorer => '체스 오픈 탐색기';

  @override
  String get save => '저장';

  @override
  String get flipBoard => '보드 뒤집기';
}
