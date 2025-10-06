import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_bloc.dart';
import 'package:inkstreak/routes/app_router.dart';
import 'package:inkstreak/core/themes/app_theme.dart';

void main() {
  runApp(const InkStreakApp());
}

class InkStreakApp extends StatelessWidget {
  const InkStreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = AuthBloc();

    return BlocProvider(
      create: (context) => authBloc,
      child: MaterialApp.router(
        title: 'InkStreak',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.createRouter(authBloc),
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.noScaling,
            ),
            child: child!,
          );
        },
      ),
    );
  }
}
