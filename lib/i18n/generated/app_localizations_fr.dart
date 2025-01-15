// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Chess Road';

  @override
  String get colorTheme => 'Thème de couleur';

  @override
  String get pieceTheme => 'Style des pièces';

  @override
  String get serverSettings => 'Paramètres du serveur';

  @override
  String get engineLevel => 'Niveau du moteur';

  @override
  String get moveTime => 'Temps par coup';

  @override
  String get searchDepth => 'Profondeur de recherche';

  @override
  String get enginePath => 'Chemin du moteur';

  @override
  String get showAnalysisArrows => 'Afficher les flèches d\'analyse';

  @override
  String get language => 'Langue';

  @override
  String get insufficientMaterial => 'Matériel insuffisant, nulle';

  @override
  String get threefoldRepetition => 'Triple répétition, nulle';

  @override
  String get draw => 'Nulle';

  @override
  String failedToLoadFile(String error) {
    return 'Échec du chargement du fichier : $error';
  }

  @override
  String get newGame => 'Nouvelle partie';

  @override
  String get undo => 'Annuler';

  @override
  String get engineInitializationFailed => 'Échec de l\'initialisation du moteur !';

  @override
  String get hint => 'Indice';

  @override
  String get analyzing => 'Analyse en cours...';

  @override
  String get dontBeDiscouraged => 'Ne vous découragez pas, continuez d\'essayer !';

  @override
  String get congratulations => 'Félicitations pour votre victoire !';

  @override
  String get youWon => 'Vous avez gagné !';

  @override
  String get youLost => 'Vous avez perdu !';

  @override
  String get engineCannotFindValidMove => 'Le moteur ne trouve pas de coup valide';

  @override
  String engineMoveError(String error) {
    return 'Erreur de coup du moteur : $error';
  }

  @override
  String get chooseYourColor => 'Choisissez votre couleur';

  @override
  String get white => 'Blancs';

  @override
  String get black => 'Noirs';

  @override
  String get chooseSaveLocation => 'Choisir l\'emplacement de sauvegarde';

  @override
  String get gameSaved => 'Partie sauvegardée';

  @override
  String get saveFailed => 'Échec de la sauvegarde, veuillez réessayer';

  @override
  String get analysisFailed => 'Échec de l\'analyse, veuillez réessayer';

  @override
  String get humanVsAi => 'Humain vs IA';

  @override
  String get ai => 'IA';

  @override
  String get you => 'Vous';

  @override
  String get computer => 'Ordinateur';

  @override
  String get player => 'Joueur';

  @override
  String get confirmDraw => 'Confirmer la nulle ?';

  @override
  String get areYouSureYouWantToProposeADraw => 'Êtes-vous sûr de vouloir proposer la nulle ?';

  @override
  String get takeback => 'Reprendre';

  @override
  String get accept => 'Accepter';

  @override
  String get reject => 'Refuser';

  @override
  String get ok => 'OK';

  @override
  String get takebackDeclined => 'Reprise refusée';

  @override
  String get drawDeclined => 'Nulle refusée';

  @override
  String get opponentRequestsTakeback => 'L\'adversaire demande une reprise, acceptez-vous ?';

  @override
  String get opponentProposesDraw => 'L\'adversaire propose la nulle, acceptez-vous ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get areYouSureYouWantToRequestATakeback => 'Êtes-vous sûr de vouloir demander une reprise ?';

  @override
  String get confirmTakeback => 'Confirmer la reprise ?';

  @override
  String get areYouSureYouWantToResign => 'Êtes-vous sûr de vouloir abandonner ?';

  @override
  String get confirmResign => 'Confirmer l\'abandon ?';

  @override
  String get searchingForAnOpponent => 'Recherche d\'un adversaire...';

  @override
  String get playOnline => 'Jouer en ligne';

  @override
  String get connect => 'Connecter';

  @override
  String get match => 'Partie';

  @override
  String get proposeDraw => 'Proposer la nulle';

  @override
  String get cancel => 'Annuler';

  @override
  String get resign => 'Abandonner';

  @override
  String get takeBack => 'Reprendre';

  @override
  String get promotion => 'Promotion';

  @override
  String get fullEmpty => 'Plein / Vide';

  @override
  String get playWithAI => 'Jouer contre l\'IA';

  @override
  String get dragAndDropToRemove => 'Glisser-déposer ici pour supprimer';

  @override
  String get invalidPosition => 'Position invalide, veuillez vérifier :\n1. Chaque camp doit avoir un roi\n2. Les pions ne peuvent pas être sur la première ou dernière rangée';

  @override
  String get setupBoard => 'Configuration de l\'échiquier';

  @override
  String get allGames => 'Toutes les parties';

  @override
  String get favorites => 'Favoris';

  @override
  String get noFavoriteGamesAvailable => 'Aucune partie favorite disponible';

  @override
  String get searchGames => 'Rechercher des parties...';

  @override
  String get games => 'Parties';

  @override
  String failedToLoadGamesList(String error) {
    return 'Échec du chargement de la liste des parties : $error';
  }

  @override
  String comments(String comments) {
    return 'Commentaires : $comments';
  }

  @override
  String get branchSelection => 'Sélection de variante';

  @override
  String get chessViewer => 'Visualiseur d\'échecs';

  @override
  String get start => 'Début';

  @override
  String get previous => 'Précédent';

  @override
  String get next => 'Suivant';

  @override
  String get end => 'Fin';

  @override
  String get addedToFavorites => 'Ajouté aux favoris';

  @override
  String get removedFromFavorites => 'Retiré des favoris';

  @override
  String get serverAddress => 'Adresse du serveur';

  @override
  String get setServerAddress => 'Définir l\'adresse du serveur';

  @override
  String get pleaseEnterTheServerAddress => 'Veuillez entrer l\'adresse du serveur';

  @override
  String get settings => 'Paramètres';

  @override
  String get engineSettings => 'Paramètres du moteur';

  @override
  String get thinkingTime => 'Temps de réflexion';

  @override
  String get limitTime => 'Limite de temps';

  @override
  String get limitDepth => 'Limite de profondeur';

  @override
  String get timeControlMode => 'Mode de contrôle du temps';

  @override
  String get useTimeControl => 'Utiliser le contrôle du temps';

  @override
  String get showPredictedMovesWhenTheEngineIsThinking => 'Afficher les coups prédits pendant la réflexion du moteur';

  @override
  String get languageSettings => 'Paramètres de langue';

  @override
  String get layers => 'Couches';

  @override
  String get current => 'Actuel';

  @override
  String get browse => 'Parcourir';

  @override
  String get confirm => 'Confirmer';

  @override
  String get selectPieceTheme => 'Sélectionner le style des pièces';

  @override
  String get selectThemeColor => 'Sélectionner le thème de couleur';

  @override
  String get setEngineLevel => 'Définir le niveau du moteur';

  @override
  String get setThinkingTime => 'Définir le temps de réflexion';

  @override
  String get setSearchDepth => 'Définir la profondeur de recherche';

  @override
  String get setEnginePath => 'Définir le chemin du moteur';

  @override
  String get pleaseEnterTheEnginePath => 'Veuillez entrer le chemin du moteur';

  @override
  String get viewGames => 'Voir les parties';

  @override
  String get exploreTheInfinitePossibilitiesOfChess => 'Explorez les possibilités infinies des échecs';

  @override
  String get checkmated => 'Échec et mat';

  @override
  String get opponentOutOfTime => 'Temps écoulé pour l\'adversaire';

  @override
  String get opponentResigned => 'L\'adversaire a abandonné';

  @override
  String get opponentLeft => 'L\'adversaire est parti';

  @override
  String get outOfTime => 'Temps écoulé';

  @override
  String get resigned => 'Abandonné';

  @override
  String get stalemate => 'Pat';

  @override
  String get consensus => 'Consensus';

  @override
  String get timeControl => 'Temps de contrôle';

  @override
  String get chessClock => 'Reloj de ajedrez';

  @override
  String get openingExplorer => 'Explorador de aperturas';

  @override
  String get save => 'Sauvegarder';
}
