// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'InkStreak';

  @override
  String get homeLoading => 'Chargement...';

  @override
  String get homeNoTheme => 'Aucun thème aujourd’hui';

  @override
  String get homeTodaysThemePrefix => 'Le thème du jour est...';

  @override
  String get homeStartDrawing => 'Commencer à dessiner';

  @override
  String get homeTodaysDrawings => 'Dessins du jour';

  @override
  String get homeNoDrawings => 'Aucun dessin aujourd’hui';

  @override
  String get homeBeFirstToShare => 'Soyez le premier à partager votre œuvre !';

  @override
  String get navHome => 'Accueil';

  @override
  String get navDraw => 'Dessiner';

  @override
  String get navCommunity => 'Communauté';

  @override
  String get drawerHome => 'Accueil';

  @override
  String get drawerCommunity => 'Communauté';

  @override
  String get drawerProfile => 'Profil';

  @override
  String get drawerSettings => 'Paramètres';

  @override
  String get drawerAbout => 'À propos';

  @override
  String get drawerLogout => 'Se déconnecter';

  @override
  String get logoutTitle => 'Déconnexion';

  @override
  String get logoutConfirm => 'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get actionCancel => 'Annuler';

  @override
  String get actionLogout => 'Se déconnecter';

  @override
  String get feedTitle => 'Communauté';

  @override
  String get feedEveryone => 'Tout le monde';

  @override
  String get feedFollowed => 'Abonnements';

  @override
  String get feedSortBy => 'Trier par :';

  @override
  String get feedSortBest => 'Meilleurs';

  @override
  String get feedSortRandom => 'Aléatoire';

  @override
  String get feedNoPosts => 'Aucune publication';

  @override
  String get searchTitle => 'Recherche';

  @override
  String get searchHint =>
      'Rechercher des publications, utilisateurs, thèmes...';

  @override
  String get searchFiltersLabel => 'Filtres :';

  @override
  String get searchClearAll => 'Tout effacer';

  @override
  String get searchPopularToday => 'Populaire aujourd’hui';

  @override
  String get searchRecentPosts => 'Publications récentes';

  @override
  String get searchInitialIntro =>
      'Recherchez des publications, des utilisateurs ou des thèmes';

  @override
  String get searchTryQuickFilters => 'Essayez les filtres rapides';

  @override
  String get searchTryAdjustFilters =>
      'Essayez d’ajuster vos filtres ou termes de recherche';

  @override
  String get searchClearFilters => 'Effacer les filtres';

  @override
  String searchResultsFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count résultats trouvés',
      one: '$count résultat trouvé',
      zero: 'Aucun résultat trouvé',
    );
    return '$_temp0';
  }

  @override
  String uploadFailedPickImage(Object error) {
    return 'Impossible de sélectionner l’image : $error';
  }

  @override
  String get uploadTitle => 'Importer un dessin';

  @override
  String get uploadTodaysTheme => 'Thème du jour';

  @override
  String get uploadYourPostToday => 'Votre publication du jour';

  @override
  String get uploadChooseHow => 'Choisissez comment ajouter votre dessin';

  @override
  String get uploadGallery => 'Galerie';

  @override
  String get uploadCamera => 'Appareil photo';

  @override
  String get uploadChangeImage => 'Changer l’image';

  @override
  String get uploadCaptionLabel => 'Légende (optionnelle)';

  @override
  String get uploadCaptionHint => 'Ajoutez une légende à votre dessin...';

  @override
  String get uploadPostDrawing => 'Publier le dessin';

  @override
  String get uploadUploading => 'Envoi de votre dessin...';

  @override
  String get uploadSuccessPosted => 'Publié avec succès !';

  @override
  String get uploadRedirecting => 'Retour à l’accueil...';

  @override
  String get uploadFailedTitle => 'Échec de l’envoi';

  @override
  String uploadErrorLoadingImage(Object error) {
    return 'Erreur lors du chargement de l’image : $error';
  }

  @override
  String get authWelcomeSnack => 'Bienvenue sur InkStreak !';

  @override
  String get authWelcomeTitle => 'Bienvenue sur InkStreak';

  @override
  String get authDescription =>
      'Connectez-vous ou créez un compte\n(le compte sera créé si le nom d’utilisateur n’existe pas encore)';

  @override
  String get authUsernameHint => 'Nom d’utilisateur';

  @override
  String get authUsernameRequired => 'Veuillez entrer un nom d’utilisateur';

  @override
  String get authUsernameMinLength =>
      'Le nom d’utilisateur doit contenir au moins 3 caractères';

  @override
  String get authPasswordHint => 'Mot de passe';

  @override
  String get authPasswordRequired => 'Veuillez entrer un mot de passe';

  @override
  String get authPasswordMinLength =>
      'Le mot de passe doit contenir au moins 6 caractères';

  @override
  String get authLoginButton => 'Commencer à dessiner !';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileNoUser => 'Aucun utilisateur connecté';

  @override
  String profileMemberSince(Object date) {
    return 'Membre depuis $date';
  }

  @override
  String get profileStatistics => 'Statistiques';

  @override
  String get profileCalendar => 'Calendrier';

  @override
  String get statsCurrentStreak => 'Série en cours';

  @override
  String get statsMaxStreak => 'Série maximale';

  @override
  String get statsTotalDrawings => 'Dessins totaux';

  @override
  String get statsTotalYeahs => 'Yeahs totaux';

  @override
  String get profileViewFailedLoad =>
      'Impossible de charger le profil utilisateur';

  @override
  String get profileViewGenericError => 'Une erreur est survenue';

  @override
  String get profileViewNotFound => 'Utilisateur introuvable';

  @override
  String get profileViewFollow => 'Suivre';

  @override
  String get profileViewUnfollow => 'Ne plus suivre';

  @override
  String get followersLabel => 'Abonnés';

  @override
  String get followingLabel => 'Abonnements';

  @override
  String get commentsTitle => 'Commentaires';

  @override
  String get commentsNoComments => 'Aucun commentaire';

  @override
  String get commentsBeFirst => 'Soyez le premier à commenter !';

  @override
  String get commentsFailedLoad => 'Impossible de charger les commentaires';

  @override
  String get commentsPosting => 'Publication...';

  @override
  String get commentsAddHint => 'Ajouter un commentaire...';

  @override
  String get calendarFailedLoad => 'Impossible de charger le calendrier';

  @override
  String get dayPostsNoPosts => 'Aucune publication ce jour-là';

  @override
  String get aboutTitle => 'À propos';

  @override
  String get aboutDescription =>
      'InkStreak est une application communautaire créative qui encourage la pratique quotidienne du dessin. Partagez vos œuvres, maintenez des séries, connectez-vous avec d’autres artistes et laissez votre créativité s’épanouir, un dessin à la fois.';

  @override
  String get aboutFeatures => 'Fonctionnalités';

  @override
  String get aboutDevelopment => 'Développement';

  @override
  String get aboutCredits => 'Crédits';

  @override
  String get aboutLibraries => 'Bibliothèques open source';

  @override
  String get aboutDevelopedBy => 'Développé par';

  @override
  String get aboutPlatform => 'Plateforme';

  @override
  String get aboutLicense => 'Licence';

  @override
  String get aboutFeatureDailyStreaksTitle => 'Séries quotidiennes';

  @override
  String get aboutFeatureDailyStreaksDesc =>
      'Suivez votre régularité de dessin et construisez des séries';

  @override
  String get aboutFeatureCommunityTitle => 'Communauté d’artistes';

  @override
  String get aboutFeatureCommunityDesc =>
      'Connectez-vous avec des artistes et partagez votre travail';

  @override
  String get aboutFeatureEngagementTitle => 'Engagement';

  @override
  String get aboutFeatureEngagementDesc =>
      'Donnez et recevez des « Yeahs » pour soutenir les autres artistes';

  @override
  String get aboutFeatureConversationsTitle => 'Discussions';

  @override
  String get aboutFeatureConversationsDesc =>
      'Discutez avec d’autres artistes et recevez des retours';

  @override
  String get aboutFeatureCalendarTitle => 'Vue calendrier';

  @override
  String get aboutFeatureCalendarDesc =>
      'Parcourez l’historique de vos œuvres avec des aperçus visuels';

  @override
  String get shareFailedBoundary => 'Impossible de trouver le RepaintBoundary';

  @override
  String get shareShareText => 'Découvrez cette publication sur InkStreak !';

  @override
  String shareFailedShare(Object error) {
    return 'Échec du partage de la publication : $error';
  }

  @override
  String get errorPageNotFoundTitle => 'Page introuvable';

  @override
  String get errorPageNotFoundMessage =>
      'La page que vous recherchez n’existe pas.';

  @override
  String get actionGoHome => 'Retour à l’accueil';

  @override
  String get editProfileDefaultUser => 'Utilisateur';

  @override
  String get actionRetry => 'Réessayer';

  @override
  String get postNoCaption => 'Aucune légende';

  @override
  String get imageFailedLoad => 'Échec du chargement de l\'image';

  @override
  String get countdownPostedToday => 'Publié aujourd\'hui ✓';

  @override
  String get countdownNotPostedYet => 'Pas encore publié';

  @override
  String get countdownNextThemeIn => 'Prochain thème dans :';
}
