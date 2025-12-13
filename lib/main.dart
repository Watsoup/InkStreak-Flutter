import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_bloc.dart';
import 'package:inkstreak/presentation/blocs/profile/profile_bloc.dart';
import 'package:inkstreak/presentation/blocs/search/search_bloc.dart';
import 'package:inkstreak/presentation/blocs/theme/theme_bloc.dart';
import 'package:inkstreak/presentation/blocs/app_theme/app_theme_bloc.dart';
import 'package:inkstreak/presentation/blocs/app_theme/app_theme_event.dart';
import 'package:inkstreak/presentation/blocs/app_theme/app_theme_state.dart';
import 'package:inkstreak/presentation/blocs/comment/comment_bloc.dart';
import 'package:inkstreak/presentation/blocs/follow/follow_bloc.dart';
import 'package:inkstreak/routes/app_router.dart';
import 'package:inkstreak/core/themes/app_theme.dart';
import 'package:inkstreak/core/di/service_locator.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/firebase_options.dart';
import 'package:inkstreak/data/services/notification_service.dart';

// Global navigator key for navigation from notification service
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupServiceLocator();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await NotificationService().initialize();

  runApp(const InkStreakApp());
}

class InkStreakApp extends StatelessWidget {
  const InkStreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBloc(apiService: getIt<ApiService>());
    final appThemeBloc = AppThemeBloc()..add(const LoadThemePreference());

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => authBloc),
        BlocProvider(create: (context) => ProfileBloc(authBloc: authBloc, apiService: getIt<ApiService>())),
        BlocProvider(create: (context) => ThemeBloc(apiService: getIt<ApiService>())),
        BlocProvider(create: (context) => appThemeBloc),
        BlocProvider(create: (context) => CommentBloc(apiService: getIt<ApiService>())),
        BlocProvider(create: (context) => FollowBloc(apiService: getIt<ApiService>())),
        BlocProvider(
          create: (context) => SearchBloc(apiService: getIt<ApiService>()),
        ),
      ],
      child: BlocBuilder<AppThemeBloc, AppThemeState>(
        buildWhen: (previous, current) => previous.isDarkMode != current.isDarkMode,
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'InkStreak',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: AppRouter.createRouter(authBloc),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.noScaling,
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
