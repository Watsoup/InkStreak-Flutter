import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/presentation/blocs/post/post_bloc.dart';
import 'package:inkstreak/presentation/blocs/post/post_event.dart';
import 'package:inkstreak/presentation/blocs/post/post_state.dart';
import 'package:inkstreak/presentation/blocs/post/post_filters.dart';
import 'package:inkstreak/presentation/widgets/post/post_card.dart';

class FeedScreen extends StatefulWidget {
  final bool isInPageView;

  const FeedScreen({super.key, this.isInPageView = false});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SortType _sortType = SortType.best;
  TimePeriod _timePeriod = TimePeriod.today;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Load initial data
    _loadPosts();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      _loadPosts();
    }
  }

  void _loadPosts() {
    final feedType = _tabController.index == 0 ? FeedType.everyone : FeedType.followed;
    context.read<PostBloc>().add(
          PostLoadByFilter(
            feedType: feedType,
            sortType: _sortType,
            timePeriod: _timePeriod,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isInPageView
          ? AppBar(
              title: const Text('Community'),
              centerTitle: false,
              automaticallyImplyLeading: false,
              bottom: _buildTabBar(),
            )
          : AppBar(
              title: const Text('Community'),
              centerTitle: false,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/home'),
              ),
              bottom: _buildTabBar(),
            ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPostsList(),
                _buildPostsList(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.isInPageView
          ? null
          : BottomNavigationBar(
              currentIndex: 2,
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
                  case 0:
                    context.go('/home');
                    break;
                  case 1:
                    context.go('/upload');
                    break;
                  case 2:
                    // Already on feed screen
                    break;
                }
              },
            ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'Everyone'),
        Tab(text: 'Followed'),
      ],
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[300]!,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<SortType>(
              value: _sortType,
              isExpanded: true,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: SortType.best,
                  child: Text('Best'),
                ),
                DropdownMenuItem(
                  value: SortType.random,
                  child: Text('Random'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _sortType = value;
                  });
                  _loadPosts();
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: DropdownButton<TimePeriod>(
              value: _timePeriod,
              isExpanded: true,
              underline: const SizedBox(),
              items: TimePeriod.values.map((period) {
                return DropdownMenuItem(
                  value: period,
                  child: Text(period.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _timePeriod = value;
                  });
                  _loadPosts();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostsList() {
    return BlocBuilder<PostBloc, PostState>(
        builder: (context, state) {
          if (state is PostLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is PostError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<PostBloc>().add(const PostLoadRequested());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is PostLoaded) {
            if (state.posts.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No posts yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(const PostRefreshRequested());
                // Wait for the state to update
                await Future.delayed(const Duration(milliseconds: 500));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
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
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
  }
}
