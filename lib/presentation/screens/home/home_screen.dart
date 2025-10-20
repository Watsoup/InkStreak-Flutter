import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_bloc.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_event.dart';
import 'package:inkstreak/presentation/blocs/post/post_bloc.dart';
import 'package:inkstreak/presentation/blocs/post/post_event.dart';
import 'package:inkstreak/presentation/blocs/post/post_state.dart';
import 'package:inkstreak/presentation/blocs/theme/theme_bloc.dart';
import 'package:inkstreak/presentation/blocs/theme/theme_event.dart';
import 'package:inkstreak/presentation/blocs/theme/theme_state.dart';
import 'package:inkstreak/presentation/widgets/post/post_card.dart';

class HomeScreen extends StatefulWidget {
  final bool isInPageView;

  const HomeScreen({super.key, this.isInPageView = false});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load theme on init
    context.read<ThemeBloc>().add(const ThemeLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: _buildDrawer(context),
        body: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<PostBloc, PostState>(
              builder: (context, postState) {
                // Get theme text
                final String themeText = themeState is ThemeLoaded
                    ? themeState.theme.name
                    : themeState is ThemeLoading
                        ? "Loading..."
                        : "No theme today";

                return CustomScrollView(
                  slivers: [
                    // Collapsing SliverAppBar with Theme
                    SliverAppBar(
                      expandedHeight: 264.0,
                      floating: false,
                      pinned: true,
                      snap: false,
                      leading: Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.person),
                          onPressed: () => context.go('/profile'),
                        ),
                      ],
                      flexibleSpace: LayoutBuilder(
                        builder: (BuildContext context, BoxConstraints constraints) {
                          // Calculate collapse progress (0.0 = expanded, 1.0 = collapsed)
                          final double top = constraints.biggest.height;
                          final double collapsedHeight = MediaQuery.of(context).padding.top + kToolbarHeight;
                          final double expandedHeight = 220.0;
                          final double shrinkOffset = expandedHeight - top;
                          final double collapseProgress = (shrinkOffset / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

                          return FlexibleSpaceBar(
                            centerTitle: true,
                            title: AnimatedOpacity(
                              duration: const Duration(milliseconds: 100),
                              opacity: collapseProgress > 0.5 ? 1.0 : 0.0,
                              child: Text(
                                themeText,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            background: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primaryContainer,
                                    Theme.of(context).colorScheme.surface,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(24.0, 60.0, 24.0, 16.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 200),
                                        opacity: 1.0 - collapseProgress,
                                        child: Text(
                                          "Today's theme is...",
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                color: Colors.grey[700],
                                              ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 200),
                                        opacity: 1.0 - collapseProgress,
                                        child: themeState is ThemeLoading
                                            ? const CircularProgressIndicator()
                                            : Text(
                                                themeText,
                                                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                textAlign: TextAlign.center,
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                      ),
                                      if (themeState is ThemeLoaded && themeState.theme.description != null) ...[
                                        const SizedBox(height: 8),
                                        AnimatedOpacity(
                                          duration: const Duration(milliseconds: 200),
                                          opacity: 1.0 - collapseProgress,
                                          child: Text(
                                            themeState.theme.description!,
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                  color: Colors.grey[700],
                                                ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 16),
                                      AnimatedOpacity(
                                        duration: const Duration(milliseconds: 200),
                                        opacity: 1.0 - (collapseProgress * 2).clamp(0.0, 1.0),
                                        child: ElevatedButton.icon(
                                          onPressed: collapseProgress < 0.8 && themeState is ThemeLoaded
                                              ? () => context.go('/upload')
                                              : null,
                                          icon: const Icon(Icons.create),
                                          label: const Text('Start Drawing'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 32,
                                              vertical: 16,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                // Today's Posts Section Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
                    child: Text(
                      "Today's Drawings",
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ),

                // Posts List
                if (postState is PostLoading)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (postState is PostError)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(postState.message),
                    ),
                  )
                else if (postState is PostLoaded)
                  postState.posts.isEmpty
                      ? SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            padding: const EdgeInsets.all(24.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.draw_outlined,
                                  size: 64,
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No drawings yet today',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.onSurface,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to share your artwork!',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final post = postState.posts[index];
                                return PostCard(
                                  post: post,
                                  onYeahTap: () {
                                    context.read<PostBloc>().add(
                                          PostYeahToggled(postId: post.id),
                                        );
                                  },
                                  onCommentTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Comments feature coming soon!'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                );
                              },
                              childCount: postState.posts.length,
                            ),
                          ),
                        ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: widget.isInPageView ? null : BottomNavigationBar(
          currentIndex: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.create),
              label: 'Draw',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Community',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 1:
                context.go('/upload');
                break;
              case 2:
                context.go('/feed');
                break;
            }
          },
        ),
      );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(
                  Icons.brush,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(height: 8),
                Text(
                  'InkStreak',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              context.go('/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text('Community'),
            onTap: () {
              Navigator.pop(context);
              context.go('/feed');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              context.go('/profile');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              Navigator.pop(context);
              context.go('/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('About coming soon!'),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<AuthBloc>().add(const AuthLogoutRequested());
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
