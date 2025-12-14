// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'InkStreak';

  @override
  String get homeLoading => 'Loading...';

  @override
  String get homeNoTheme => 'No theme today';

  @override
  String get homeTodaysThemePrefix => 'Today\'s theme is...';

  @override
  String get homeStartDrawing => 'Start Drawing';

  @override
  String get homeTodaysDrawings => 'Today\'s Drawings';

  @override
  String get homeNoDrawings => 'No drawings yet today';

  @override
  String get homeBeFirstToShare => 'Be the first to share your artwork!';

  @override
  String get navHome => 'Home';

  @override
  String get navDraw => 'Draw';

  @override
  String get navCommunity => 'Community';

  @override
  String get drawerHome => 'Home';

  @override
  String get drawerCommunity => 'Community';

  @override
  String get drawerProfile => 'Profile';

  @override
  String get drawerSettings => 'Settings';

  @override
  String get drawerAbout => 'About';

  @override
  String get drawerLogout => 'Logout';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutConfirm => 'Are you sure you want to logout?';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionLogout => 'Logout';

  @override
  String get feedTitle => 'Community';

  @override
  String get feedEveryone => 'Everyone';

  @override
  String get feedFollowed => 'Followed';

  @override
  String get feedSortBy => 'Sort by:';

  @override
  String get feedSortBest => 'Best';

  @override
  String get feedSortRandom => 'Random';

  @override
  String get feedNoPosts => 'No posts yet';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchHint => 'Search posts, users, themes...';

  @override
  String get searchFiltersLabel => 'Filters:';

  @override
  String get searchClearAll => 'Clear all';

  @override
  String get searchPopularToday => 'Popular today';

  @override
  String get searchRecentPosts => 'Recent posts';

  @override
  String get searchInitialIntro => 'Search for posts, users, or themes';

  @override
  String get searchTryQuickFilters => 'Try using the quick filters';

  @override
  String get searchTryAdjustFilters =>
      'Try adjusting your filters or search terms';

  @override
  String get searchClearFilters => 'Clear filters';

  @override
  String searchResultsFound(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count results found',
      one: '$count result found',
      zero: 'No results found',
    );
    return '$_temp0';
  }

  @override
  String uploadFailedPickImage(Object error) {
    return 'Failed to pick image: $error';
  }

  @override
  String get uploadTitle => 'Upload Drawing';

  @override
  String get uploadTodaysTheme => 'Today\'s theme';

  @override
  String get uploadYourPostToday => 'Your post today';

  @override
  String get uploadChooseHow => 'Choose how to add your drawing';

  @override
  String get uploadGallery => 'Gallery';

  @override
  String get uploadCamera => 'Camera';

  @override
  String get uploadChangeImage => 'Change Image';

  @override
  String get uploadCaptionLabel => 'Caption (optional)';

  @override
  String get uploadCaptionHint => 'Add a caption to your drawing...';

  @override
  String get uploadPostDrawing => 'Post Drawing';

  @override
  String get uploadUploading => 'Uploading your drawing...';

  @override
  String get uploadSuccessPosted => 'Posted successfully!';

  @override
  String get uploadRedirecting => 'Redirecting to home...';

  @override
  String get uploadFailedTitle => 'Upload failed';

  @override
  String uploadErrorLoadingImage(Object error) {
    return 'Error loading image: $error';
  }

  @override
  String get authWelcomeSnack => 'Welcome to InkStreak!';

  @override
  String get authWelcomeTitle => 'Welcome to InkStreak';

  @override
  String get authDescription =>
      'Login or create an account\n(the account will be created if the username does not already exist)';

  @override
  String get authUsernameHint => 'Username';

  @override
  String get authUsernameRequired => 'Please enter a username';

  @override
  String get authUsernameMinLength => 'Username must be at least 3 characters';

  @override
  String get authPasswordHint => 'Password';

  @override
  String get authPasswordRequired => 'Please enter a password';

  @override
  String get authPasswordMinLength => 'Password must be at least 6 characters';

  @override
  String get authLoginButton => 'Start drawing !';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileNoUser => 'No user logged in';

  @override
  String profileMemberSince(Object date) {
    return 'Member since $date';
  }

  @override
  String get profileStatistics => 'Statistics';

  @override
  String get profileCalendar => 'Calendar';

  @override
  String get statsCurrentStreak => 'Current Streak';

  @override
  String get statsMaxStreak => 'Max Streak';

  @override
  String get statsTotalDrawings => 'Total Drawings';

  @override
  String get statsTotalYeahs => 'Total Yeahs';

  @override
  String get profileViewFailedLoad => 'Failed to load user profile';

  @override
  String get profileViewGenericError => 'An error occurred';

  @override
  String get profileViewNotFound => 'User not found';

  @override
  String get profileViewFollow => 'Follow';

  @override
  String get profileViewUnfollow => 'Unfollow';

  @override
  String get followersLabel => 'Followers';

  @override
  String get followingLabel => 'Following';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsNoComments => 'No comments yet';

  @override
  String get commentsBeFirst => 'Be the first to comment!';

  @override
  String get commentsFailedLoad => 'Failed to load comments';

  @override
  String get commentsPosting => 'Posting...';

  @override
  String get commentsAddHint => 'Add a comment...';

  @override
  String get calendarFailedLoad => 'Failed to load calendar';

  @override
  String get dayPostsNoPosts => 'No posts on this day';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutDescription =>
      'InkStreak is a creative community app that encourages daily drawing practice. Share your artwork, build streaks, connect with fellow artists, and watch your creativity flourish one drawing at a time.';

  @override
  String get aboutFeatures => 'Features';

  @override
  String get aboutDevelopment => 'Development';

  @override
  String get aboutCredits => 'Credits';

  @override
  String get aboutLibraries => 'Open Source Libraries';

  @override
  String get aboutDevelopedBy => 'Developed by';

  @override
  String get aboutPlatform => 'Platform';

  @override
  String get aboutLicense => 'License';

  @override
  String get aboutFeatureDailyStreaksTitle => 'Daily Streaks';

  @override
  String get aboutFeatureDailyStreaksDesc =>
      'Track your drawing consistency and build streaks';

  @override
  String get aboutFeatureCommunityTitle => 'Artist Community';

  @override
  String get aboutFeatureCommunityDesc =>
      'Connect with artists and share your work';

  @override
  String get aboutFeatureEngagementTitle => 'Engagement';

  @override
  String get aboutFeatureEngagementDesc =>
      'Give and receive \"Yeahs\" to support fellow artists';

  @override
  String get aboutFeatureConversationsTitle => 'Conversations';

  @override
  String get aboutFeatureConversationsDesc =>
      'Chat with other artists and get feedback';

  @override
  String get aboutFeatureCalendarTitle => 'Calendar View';

  @override
  String get aboutFeatureCalendarDesc =>
      'Browse your artwork history with visual previews';

  @override
  String get shareFailedBoundary => 'Failed to find RepaintBoundary';

  @override
  String get shareShareText => 'Check out this post from InkStreak!';

  @override
  String shareFailedShare(Object error) {
    return 'Failed to share post: $error';
  }

  @override
  String get errorPageNotFoundTitle => 'Page not found';

  @override
  String get errorPageNotFoundMessage =>
      'The page you are looking for does not exist.';

  @override
  String get actionGoHome => 'Go Home';

  @override
  String get editProfileDefaultUser => 'User';

  @override
  String get actionRetry => 'Retry';

  @override
  String get postNoCaption => 'No caption';

  @override
  String get imageFailedLoad => 'Failed to load image';

  @override
  String get countdownPostedToday => 'Posted today ✓';

  @override
  String get countdownNotPostedYet => 'Not posted yet';

  @override
  String get countdownNextThemeIn => 'Next theme in:';
}
