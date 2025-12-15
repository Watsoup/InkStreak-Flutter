import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'InkStreak'**
  String get appTitle;

  /// No description provided for @homeLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get homeLoading;

  /// No description provided for @homeNoTheme.
  ///
  /// In en, this message translates to:
  /// **'No theme today'**
  String get homeNoTheme;

  /// No description provided for @homeTodaysThemePrefix.
  ///
  /// In en, this message translates to:
  /// **'Today\'s theme is...'**
  String get homeTodaysThemePrefix;

  /// No description provided for @homeStartDrawing.
  ///
  /// In en, this message translates to:
  /// **'Start Drawing'**
  String get homeStartDrawing;

  /// No description provided for @homeTodaysDrawings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Drawings'**
  String get homeTodaysDrawings;

  /// No description provided for @homeNoDrawings.
  ///
  /// In en, this message translates to:
  /// **'No drawings yet today'**
  String get homeNoDrawings;

  /// No description provided for @homeBeFirstToShare.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your artwork!'**
  String get homeBeFirstToShare;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get navDraw;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @drawerHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get drawerHome;

  /// No description provided for @drawerCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get drawerCommunity;

  /// No description provided for @drawerProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get drawerProfile;

  /// No description provided for @drawerSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawerSettings;

  /// No description provided for @drawerAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get drawerAbout;

  /// No description provided for @drawerLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get drawerLogout;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutConfirm;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get actionLogout;

  /// No description provided for @feedTitle.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get feedTitle;

  /// No description provided for @feedEveryone.
  ///
  /// In en, this message translates to:
  /// **'Everyone'**
  String get feedEveryone;

  /// No description provided for @feedFollowed.
  ///
  /// In en, this message translates to:
  /// **'Followed'**
  String get feedFollowed;

  /// No description provided for @feedSortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by:'**
  String get feedSortBy;

  /// No description provided for @feedSortBest.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get feedSortBest;

  /// No description provided for @feedSortRandom.
  ///
  /// In en, this message translates to:
  /// **'Random'**
  String get feedSortRandom;

  /// No description provided for @feedNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts yet'**
  String get feedNoPosts;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search posts, users, themes...'**
  String get searchHint;

  /// No description provided for @searchFiltersLabel.
  ///
  /// In en, this message translates to:
  /// **'Filters:'**
  String get searchFiltersLabel;

  /// No description provided for @searchClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get searchClearAll;

  /// No description provided for @searchPopularToday.
  ///
  /// In en, this message translates to:
  /// **'Popular today'**
  String get searchPopularToday;

  /// No description provided for @searchRecentPosts.
  ///
  /// In en, this message translates to:
  /// **'Recent posts'**
  String get searchRecentPosts;

  /// No description provided for @searchInitialIntro.
  ///
  /// In en, this message translates to:
  /// **'Search for posts, users, or themes'**
  String get searchInitialIntro;

  /// No description provided for @searchTryQuickFilters.
  ///
  /// In en, this message translates to:
  /// **'Try using the quick filters'**
  String get searchTryQuickFilters;

  /// No description provided for @searchTryAdjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your filters or search terms'**
  String get searchTryAdjustFilters;

  /// No description provided for @searchClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get searchClearFilters;

  /// No description provided for @searchResultsFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No results found} =1{{count} result found} other{{count} results found}}'**
  String searchResultsFound(num count);

  /// No description provided for @uploadFailedPickImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to pick image: {error}'**
  String uploadFailedPickImage(Object error);

  /// No description provided for @uploadTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload Drawing'**
  String get uploadTitle;

  /// No description provided for @uploadTodaysTheme.
  ///
  /// In en, this message translates to:
  /// **'Today\'s theme'**
  String get uploadTodaysTheme;

  /// No description provided for @uploadYourPostToday.
  ///
  /// In en, this message translates to:
  /// **'Your post today'**
  String get uploadYourPostToday;

  /// No description provided for @uploadChooseHow.
  ///
  /// In en, this message translates to:
  /// **'Choose how to add your drawing'**
  String get uploadChooseHow;

  /// No description provided for @uploadGallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get uploadGallery;

  /// No description provided for @uploadCamera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get uploadCamera;

  /// No description provided for @uploadChangeImage.
  ///
  /// In en, this message translates to:
  /// **'Change Image'**
  String get uploadChangeImage;

  /// No description provided for @uploadCaptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Caption (optional)'**
  String get uploadCaptionLabel;

  /// No description provided for @uploadCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Add a caption to your drawing...'**
  String get uploadCaptionHint;

  /// No description provided for @uploadPostDrawing.
  ///
  /// In en, this message translates to:
  /// **'Post Drawing'**
  String get uploadPostDrawing;

  /// No description provided for @uploadUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading your drawing...'**
  String get uploadUploading;

  /// No description provided for @uploadSuccessPosted.
  ///
  /// In en, this message translates to:
  /// **'Posted successfully!'**
  String get uploadSuccessPosted;

  /// No description provided for @uploadRedirecting.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to home...'**
  String get uploadRedirecting;

  /// No description provided for @uploadFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Upload failed'**
  String get uploadFailedTitle;

  /// No description provided for @uploadErrorLoadingImage.
  ///
  /// In en, this message translates to:
  /// **'Error loading image: {error}'**
  String uploadErrorLoadingImage(Object error);

  /// No description provided for @authWelcomeSnack.
  ///
  /// In en, this message translates to:
  /// **'Welcome to InkStreak!'**
  String get authWelcomeSnack;

  /// No description provided for @authWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to InkStreak'**
  String get authWelcomeTitle;

  /// No description provided for @authDescription.
  ///
  /// In en, this message translates to:
  /// **'Login or create an account\n(the account will be created if the username does not already exist)'**
  String get authDescription;

  /// No description provided for @authUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get authUsernameHint;

  /// No description provided for @authUsernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a username'**
  String get authUsernameRequired;

  /// No description provided for @authUsernameMinLength.
  ///
  /// In en, this message translates to:
  /// **'Username must be at least 3 characters'**
  String get authUsernameMinLength;

  /// No description provided for @authPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordHint;

  /// No description provided for @authPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a password'**
  String get authPasswordRequired;

  /// No description provided for @authPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get authPasswordMinLength;

  /// No description provided for @authLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Start drawing !'**
  String get authLoginButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// No description provided for @profileNoUser.
  ///
  /// In en, this message translates to:
  /// **'No user logged in'**
  String get profileNoUser;

  /// No description provided for @profileMemberSince.
  ///
  /// In en, this message translates to:
  /// **'Member since {date}'**
  String profileMemberSince(Object date);

  /// No description provided for @profileStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get profileStatistics;

  /// No description provided for @profileCalendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get profileCalendar;

  /// No description provided for @statsCurrentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get statsCurrentStreak;

  /// No description provided for @statsMaxStreak.
  ///
  /// In en, this message translates to:
  /// **'Max Streak'**
  String get statsMaxStreak;

  /// No description provided for @statsTotalDrawings.
  ///
  /// In en, this message translates to:
  /// **'Total Drawings'**
  String get statsTotalDrawings;

  /// No description provided for @statsTotalYeahs.
  ///
  /// In en, this message translates to:
  /// **'Total Yeahs'**
  String get statsTotalYeahs;

  /// No description provided for @profileViewFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load user profile'**
  String get profileViewFailedLoad;

  /// No description provided for @profileViewGenericError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get profileViewGenericError;

  /// No description provided for @profileViewNotFound.
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get profileViewNotFound;

  /// No description provided for @profileViewFollow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get profileViewFollow;

  /// No description provided for @profileViewUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow'**
  String get profileViewUnfollow;

  /// No description provided for @followersLabel.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followersLabel;

  /// No description provided for @followingLabel.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingLabel;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @commentsNoComments.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get commentsNoComments;

  /// No description provided for @commentsBeFirst.
  ///
  /// In en, this message translates to:
  /// **'Be the first to comment!'**
  String get commentsBeFirst;

  /// No description provided for @commentsFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load comments'**
  String get commentsFailedLoad;

  /// No description provided for @commentsPosting.
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get commentsPosting;

  /// No description provided for @commentsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get commentsAddHint;

  /// No description provided for @calendarFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load calendar'**
  String get calendarFailedLoad;

  /// No description provided for @dayPostsNoPosts.
  ///
  /// In en, this message translates to:
  /// **'No posts on this day'**
  String get dayPostsNoPosts;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'InkStreak is a creative community app that encourages daily drawing practice. Share your artwork, build streaks, connect with fellow artists, and watch your creativity flourish one drawing at a time.'**
  String get aboutDescription;

  /// No description provided for @aboutFeatures.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get aboutFeatures;

  /// No description provided for @aboutDevelopment.
  ///
  /// In en, this message translates to:
  /// **'Development'**
  String get aboutDevelopment;

  /// No description provided for @aboutCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get aboutCredits;

  /// No description provided for @aboutLibraries.
  ///
  /// In en, this message translates to:
  /// **'Open Source Libraries'**
  String get aboutLibraries;

  /// No description provided for @aboutDevelopedBy.
  ///
  /// In en, this message translates to:
  /// **'Developed by'**
  String get aboutDevelopedBy;

  /// No description provided for @aboutPlatform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get aboutPlatform;

  /// No description provided for @aboutLicense.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get aboutLicense;

  /// No description provided for @aboutFeatureDailyStreaksTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Streaks'**
  String get aboutFeatureDailyStreaksTitle;

  /// No description provided for @aboutFeatureDailyStreaksDesc.
  ///
  /// In en, this message translates to:
  /// **'Track your drawing consistency and build streaks'**
  String get aboutFeatureDailyStreaksDesc;

  /// No description provided for @aboutFeatureCommunityTitle.
  ///
  /// In en, this message translates to:
  /// **'Artist Community'**
  String get aboutFeatureCommunityTitle;

  /// No description provided for @aboutFeatureCommunityDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect with artists and share your work'**
  String get aboutFeatureCommunityDesc;

  /// No description provided for @aboutFeatureEngagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Engagement'**
  String get aboutFeatureEngagementTitle;

  /// No description provided for @aboutFeatureEngagementDesc.
  ///
  /// In en, this message translates to:
  /// **'Give and receive \"Yeahs\" to support fellow artists'**
  String get aboutFeatureEngagementDesc;

  /// No description provided for @aboutFeatureConversationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversations'**
  String get aboutFeatureConversationsTitle;

  /// No description provided for @aboutFeatureConversationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Chat with other artists and get feedback'**
  String get aboutFeatureConversationsDesc;

  /// No description provided for @aboutFeatureCalendarTitle.
  ///
  /// In en, this message translates to:
  /// **'Calendar View'**
  String get aboutFeatureCalendarTitle;

  /// No description provided for @aboutFeatureCalendarDesc.
  ///
  /// In en, this message translates to:
  /// **'Browse your artwork history with visual previews'**
  String get aboutFeatureCalendarDesc;

  /// No description provided for @shareFailedBoundary.
  ///
  /// In en, this message translates to:
  /// **'Failed to find RepaintBoundary'**
  String get shareFailedBoundary;

  /// No description provided for @shareShareText.
  ///
  /// In en, this message translates to:
  /// **'Check out this post from InkStreak!'**
  String get shareShareText;

  /// No description provided for @shareFailedShare.
  ///
  /// In en, this message translates to:
  /// **'Failed to share post: {error}'**
  String shareFailedShare(Object error);

  /// No description provided for @errorPageNotFoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Page not found'**
  String get errorPageNotFoundTitle;

  /// No description provided for @errorPageNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for does not exist.'**
  String get errorPageNotFoundMessage;

  /// No description provided for @actionGoHome.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get actionGoHome;

  /// No description provided for @editProfileDefaultUser.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get editProfileDefaultUser;

  /// No description provided for @actionRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get actionRetry;

  /// No description provided for @postNoCaption.
  ///
  /// In en, this message translates to:
  /// **'No caption'**
  String get postNoCaption;

  /// No description provided for @imageFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageFailedLoad;

  /// No description provided for @countdownPostedToday.
  ///
  /// In en, this message translates to:
  /// **'Posted today ✓'**
  String get countdownPostedToday;

  /// No description provided for @countdownNotPostedYet.
  ///
  /// In en, this message translates to:
  /// **'Not posted yet'**
  String get countdownNotPostedYet;

  /// No description provided for @countdownNextThemeIn.
  ///
  /// In en, this message translates to:
  /// **'Next theme in:'**
  String get countdownNextThemeIn;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
