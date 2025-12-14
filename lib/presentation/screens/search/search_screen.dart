import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inkstreak/presentation/blocs/search/search_bloc.dart';
import 'package:inkstreak/presentation/blocs/search/search_event.dart';
import 'package:inkstreak/presentation/blocs/search/search_state.dart';
import 'package:inkstreak/presentation/blocs/search/search_filters.dart';
import 'package:inkstreak/presentation/widgets/post/post_card.dart';
//import 'package:inkstreak/presentation/screens/search/search_filters_sheet.dart';

import '../../../data/models/post_models.dart';
import '../../blocs/post/post_bloc.dart';
import '../../blocs/post/post_event.dart';
import 'package:inkstreak/l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _showSuggestions = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _showSuggestions = _searchFocusNode.hasFocus;
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.isNotEmpty) {
      _searchFocusNode.unfocus();
      _debounceTimer?.cancel();
      context.read<SearchBloc>().add(SearchQueryChanged(query));
    }
  }

  void _onSearchChanged(String query) {
    // Annuler le timer précédent
    _debounceTimer?.cancel();

    // Si le champ est vide, nettoyer la recherche
    if (query.isEmpty) {
      context.read<SearchBloc>().add(const SearchCleared());
      return;
    }

    // Créer un nouveau timer pour le debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.length >= 2) {
        // Lancer la recherche complète
        context.read<SearchBloc>().add(SearchQueryChanged(query));

        // Lancer aussi les suggestions
        context.read<SearchBloc>().add(SearchSuggestionRequested(query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop) {
          context.go('/feed');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).searchTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/feed'),
          ),
        ),
      body: Column(
        children: [
          // Search bar
          _buildSearchBar(),

          // filter chips
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchLoaded && state.appliedFilters.hasActiveFilters) {
                return _buildActiveFiltersChips(state.appliedFilters);
              }
              return const SizedBox.shrink();
            },
          ),

          // results or suggestions
          Expanded(
            child: BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (_showSuggestions && state is SearchLoaded && state.suggestions.isNotEmpty) {
                  return _buildSuggestionsList(state.suggestions);
                }

                if (state is SearchInitial) {
                  return _buildInitialState();
                }

                if (state is SearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SearchEmpty) {
                  return _buildEmptyState(state.message);
                }

                if (state is SearchError) {
                  return _buildErrorState(state.message);
                }

                if (state is SearchLoaded) {
                  return _buildResultsList(state.posts);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _debounceTimer?.cancel();
                    context.read<SearchBloc>().add(const SearchCleared());
                    setState(() {});
                  },
                )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.search,
              onChanged: _onSearchChanged,
              onSubmitted: _onSearchSubmitted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFiltersChips(SearchFilters filters) {
    final chips = <Widget>[];

    if (filters.themeId != null) {
      chips.add(_buildFilterChip('Theme: ${filters.themeId}', () {
        _removeFilter('theme');
      }));
    }

    if (filters.username != null) {
      chips.add(_buildFilterChip('User: ${filters.username}', () {
        _removeFilter('username');
      }));
    }

    if (filters.startDate != null || filters.endDate != null) {
      chips.add(_buildFilterChip('Date range', () {
        _removeFilter('date');
      }));
    }

    if (filters.tags.isNotEmpty) {
      for (final tag in filters.tags) {
        chips.add(_buildFilterChip('#$tag', () {
          _removeTag(tag);
        }));
      }
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
            child: Row(
          children: [
            Text(
              AppLocalizations.of(context).searchFiltersLabel,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            ...chips,
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                context.read<SearchBloc>().add(
                  SearchFiltersApplied(const SearchFilters()),
                );
              },
              icon: const Icon(Icons.close, size: 16),
              label: Text(AppLocalizations.of(context).searchClearAll),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, VoidCallback onDelete) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(label),
        onDeleted: onDelete,
        deleteIcon: const Icon(Icons.close, size: 16),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        labelStyle: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 12,
        ),
      ),
    );
  }

  void _removeFilter(String filterType) {
    final state = context.read<SearchBloc>().state;
    if (state is SearchLoaded) {
      SearchFilters newFilters;
      switch (filterType) {
        case 'theme':
          newFilters = state.appliedFilters.copyWith(themeId: null);
          break;
        case 'username':
          newFilters = state.appliedFilters.copyWith(username: null);
          break;
        case 'date':
          newFilters = state.appliedFilters.copyWith(
            startDate: null,
            endDate: null,
          );
          break;
        default:
          return;
      }
      context.read<SearchBloc>().add(SearchFiltersApplied(newFilters));
    }
  }

  void _removeTag(String tag) {
    final state = context.read<SearchBloc>().state;
    if (state is SearchLoaded) {
      final newTags = List<String>.from(state.appliedFilters.tags)
        ..remove(tag);
      final newFilters = state.appliedFilters.copyWith(tags: newTags);
      context.read<SearchBloc>().add(SearchFiltersApplied(newFilters));
    }
  }

  Widget _buildSuggestionsList(List<String> suggestions) {
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.people_alt_outlined),
          title: Text(suggestion),
          trailing: const Icon(Icons.north_west, size: 16),
          onTap: () {
            _searchController.text = suggestion;
            _onSearchSubmitted(suggestion);
          },
        );
      },
    );
  }

  Widget _buildInitialState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).searchInitialIntro,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).searchTryQuickFilters,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          _buildQuickFilters(),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Wrap(
      spacing: 8,
      children: [
        ActionChip(
          avatar: const Icon(Icons.trending_up, size: 18),
          label: Text(AppLocalizations.of(context).searchPopularToday),
          onPressed: () {
            final now = DateTime.now();
            final todayStart = DateTime(now.year, now.month, now.day);
            final todayEnd = todayStart.add(const Duration(days: 1));

            final filters = SearchFilters(
              startDate: todayStart,
              endDate: todayEnd,
              sortType: SearchSortType.popular,
            );

            _searchFocusNode.unfocus();
            context.read<SearchBloc>().add(SearchFiltersApplied(filters));
          },
        ),
        ActionChip(
          avatar: const Icon(Icons.new_releases, size: 18),
          label: Text(AppLocalizations.of(context).searchRecentPosts),
          onPressed: () {
            final filters = SearchFilters(
              sortType: SearchSortType.recent,
            );

            _searchFocusNode.unfocus();
            context.read<SearchBloc>().add(SearchFiltersApplied(filters));
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).searchTryAdjustFilters,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () {
              context.read<SearchBloc>().add(
                SearchFiltersApplied(const SearchFilters()),
              );
            },
            icon: const Icon(Icons.filter_alt_off),
            label: Text(AppLocalizations.of(context).searchClearFilters),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.red[300],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final query = _searchController.text;
              if (query.isNotEmpty) {
                context.read<SearchBloc>().add(SearchQueryChanged(query));
              }
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(List<Post> posts) {
    return RefreshIndicator(
      onRefresh: () async {
        final query = _searchController.text;
        if (query.isNotEmpty) {
          context.read<SearchBloc>().add(SearchQueryChanged(query));
        }
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length + 1, // +1 for results count header
        itemBuilder: (context, index) {
          if (index == 0) {
                return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                AppLocalizations.of(context).searchResultsFound(posts.length),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final post = posts[index - 1];
          return PostCard(
            post: post,
            onYeahTap: () {
              context.read<PostBloc>().add(
                PostYeahToggled(postId: post.id),
              );
            },
            onCommentTap: () {
              context.push('/comments/${post.id}');
            },
            onShareTap: () {
              // Share functionality will be handled by PostCard
            },
          );
        },
      ),
    );
  }
}