import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/data/models/user_models.dart' hide Theme;
import 'package:inkstreak/presentation/blocs/auth/auth_bloc.dart';
import 'package:inkstreak/presentation/blocs/auth/auth_state.dart';
import 'package:inkstreak/presentation/blocs/follow/follow_bloc.dart';
import 'package:inkstreak/presentation/blocs/follow/follow_event.dart';
import 'package:inkstreak/presentation/blocs/follow/follow_state.dart';
import 'package:inkstreak/presentation/blocs/calendar/calendar_bloc.dart';
import 'package:inkstreak/presentation/widgets/calendar/profile_calendar_widget.dart';
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'package:dio/dio.dart';

class UserProfileScreen extends StatefulWidget {
  final String username;

  const UserProfileScreen({
    super.key,
    required this.username,
  });

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final ApiService _apiService = ApiService(DioClient.createDio());
  User? _user;
  UserStats? _stats;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    // Load follow status after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<FollowBloc>().add(FollowStatusRequested(username: widget.username));
      }
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = await _apiService.getUser(widget.username);
      UserStats? stats;

      try {
        stats = await _apiService.getUserStats(widget.username);
      } catch (e) {
        debugPrint('Failed to load stats: $e');
      }

      if (mounted) {
        setState(() {
          _user = user;
          _stats = stats;
          _isLoading = false;
        });
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load user profile';
          _isLoading = false;
        });
      }
      debugPrint('Error loading user profile: ${e.message}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred';
          _isLoading = false;
        });
      }
      debugPrint('Error loading user profile: $e');
    }
  }

  bool _isOwnProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      return authState.user.username == widget.username;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // If this is the authenticated user's own profile, redirect to ProfileScreen
    if (_isOwnProfile()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/profile');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_user?.username ?? widget.username),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserProfile,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_user == null) {
      return const Center(child: Text('User not found'));
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Profile Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
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
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  backgroundImage: _user!.profilePicture != null
                      ? NetworkImage(_user!.profilePicture!)
                      : null,
                  child: _user!.profilePicture == null
                      ? Text(
                          _user!.username[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                Text(
                  _user!.username,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (_user!.bio != null && _user!.bio!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _user!.bio!,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Member since ${_formatDate(_user!.createdAt)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 16),

                // Follow button
                BlocConsumer<FollowBloc, FollowState>(
                  listener: (context, state) {
                    if (state is FollowError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.message),
                          backgroundColor: Colors.red,
                        ),
                      );
                      // Reload follow status
                      context.read<FollowBloc>().add(
                        FollowStatusRequested(username: widget.username),
                      );
                    }
                  },
                  builder: (context, state) {
                    bool isFollowing = false;
                    bool isLoading = state is FollowLoading;
                    bool isToggling = state is FollowToggling;

                    if (state is FollowStatusLoaded && state.username == widget.username) {
                      isFollowing = state.isFollowing;
                    } else if (state is FollowToggling && state.username == widget.username) {
                      isFollowing = state.targetIsFollowing;
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: (isLoading || isToggling)
                            ? null
                            : () {
                                context.read<FollowBloc>().add(
                                  FollowToggleRequested(username: widget.username),
                                );
                              },
                        icon: (isLoading || isToggling)
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(
                                isFollowing ? Icons.person_remove : Icons.person_add,
                              ),
                        label: Text(
                          isFollowing ? 'Unfollow' : 'Follow',
                          style: const TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing
                              ? Theme.of(context).colorScheme.surfaceContainerHighest
                              : Theme.of(context).colorScheme.primary,
                          foregroundColor: isFollowing
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Followers / Following counts
                BlocBuilder<FollowBloc, FollowState>(
                  builder: (context, state) {
                    int followerCount = _user!.followers?.length ?? 0;
                    int followingCount = _user!.following?.length ?? 0;

                    if (state is FollowStatusLoaded && state.username == widget.username) {
                      followerCount = state.followerCount;
                      followingCount = state.followingCount;
                    } else if (state is FollowToggling && state.username == widget.username) {
                      followerCount = state.followerCount;
                      followingCount = state.followingCount;
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFollowCount(
                          context,
                          count: followerCount,
                          label: 'Followers',
                          onTap: () {
                            // TODO: Show followers list
                          },
                        ),
                        const SizedBox(width: 32),
                        _buildFollowCount(
                          context,
                          count: followingCount,
                          label: 'Following',
                          onTap: () {
                            // TODO: Show following list
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Stats Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Statistics',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.local_fire_department,
                        label: 'Current Streak',
                        value: _stats?.currentStreak.toString(),
                        isLoading: _stats == null,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.star,
                        label: 'Max Streak',
                        value: _stats?.maxStreak.toString(),
                        isLoading: _stats == null,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.brush,
                        label: 'Total Drawings',
                        value: _stats?.totalPosts.toString(),
                        isLoading: _stats == null,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        icon: Icons.thumb_up,
                        label: 'Total Yeahs',
                        value: _stats?.totalYeahs.toString(),
                        isLoading: _stats == null,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Calendar',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                BlocProvider(
                  create: (context) => CalendarBloc(),
                  child: ProfileCalendarWidget(
                    username: widget.username,
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowCount(
    BuildContext context, {
    required int count,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            count.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    String? value,
    bool isLoading = false,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            isLoading
                ? SizedBox(
                    height: 32,
                    width: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: color,
                    ),
                  )
                : Text(
                    value ?? '0',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}
