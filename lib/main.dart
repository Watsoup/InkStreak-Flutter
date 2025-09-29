import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:inkstreak/presentation/providers/auth_provider.dart';
import 'package:inkstreak/routes/app_router.dart';
import 'package:inkstreak/core/themes/app_theme.dart';

void main() {
  runApp(const InkStreakApp());
}

class InkStreakApp extends StatelessWidget {
  const InkStreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthProvider(),
        ),
        // Add other providers here as needed
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'InkStreak',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: AppRouter.createRouter(),
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
