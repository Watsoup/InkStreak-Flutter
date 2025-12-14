import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inkstreak/core/di/service_locator.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/presentation/blocs/post/post_bloc.dart';
import 'package:inkstreak/presentation/blocs/post/post_event.dart';
import 'package:inkstreak/presentation/blocs/upload/upload_bloc.dart';
import 'package:inkstreak/presentation/blocs/upload/upload_event.dart';
import 'package:inkstreak/presentation/screens/home/home_screen.dart';
import 'package:inkstreak/l10n/app_localizations.dart';
import 'package:inkstreak/presentation/screens/upload/upload_screen.dart';
import 'package:inkstreak/presentation/screens/feed/feed_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialPage;

  const MainNavigationScreen({
    super.key,
    this.initialPage = 0,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onBottomNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          // Home Screen (index 0)
          _HomeWrapper(),

          // Upload/Draw Screen (index 1)
          _UploadWrapper(),

          // Community/Feed Screen (index 2)
          _FeedWrapper(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentPage,
        onTap: _onBottomNavTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: AppLocalizations.of(context).navHome,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.create),
            label: AppLocalizations.of(context).navDraw,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.people),
            label: AppLocalizations.of(context).navCommunity,
          ),
        ],
      ),
    );
  }
}

// Wrapper widgets to provide BLoC and avoid recreating them on swipe
class _HomeWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(apiService: getIt<ApiService>())..add(const PostLoadRequested()),
      child: const HomeScreen(isInPageView: true),
    );
  }
}

class _UploadWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UploadBloc(apiService: getIt<ApiService>())..add(const UploadCheckStatus()),
      child: const UploadScreen(isInPageView: true),
    );
  }
}

class _FeedWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PostBloc(apiService: getIt<ApiService>())..add(const PostLoadRequested()),
      child: const FeedScreen(isInPageView: true),
    );
  }
}
