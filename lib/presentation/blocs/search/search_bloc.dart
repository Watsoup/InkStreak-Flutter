import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:inkstreak/data/models/post_models.dart';
import 'package:inkstreak/data/models/user_models.dart' as api_models;
import 'package:inkstreak/data/services/api_service.dart';
import 'package:inkstreak/core/utils/dio_client.dart';
import 'search_event.dart';
import 'search_state.dart';
import 'search_filters.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final ApiService _apiService;
  List<api_models.Post> _cachedPosts = [];
  List<api_models.User> _cachedUsers = [];

  SearchBloc()
      : _apiService = ApiService(DioClient.createDio()),
        super(const SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<SearchFiltersApplied>(_onSearchFiltersApplied);
    on<SearchCleared>(_onSearchCleared);
    on<SearchSuggestionRequested>(_onSearchSuggestionRequested);
  }

  Future<void> _onSearchQueryChanged(
      SearchQueryChanged event,
      Emitter<SearchState> emit,
      ) async {
    if (event.query.isEmpty) {
      emit(const SearchInitial());
      return;
    }

    emit(const SearchLoading());

    try {
      // Créer des filtres avec la query
      final filters = const SearchFilters().copyWith(query: event.query);

      // Rechercher les posts
      final posts = await _searchPosts(filters);

      if (posts.isEmpty) {
        emit(const SearchEmpty('No results found'));
      } else {
        emit(SearchLoaded(
          posts: posts,
          appliedFilters: filters,
        ));
      }
    } catch (e) {
      debugPrint('Search error: $e');
      emit(SearchError('Search failed: $e'));
    }
  }

  Future<void> _onSearchFiltersApplied(
      SearchFiltersApplied event,
      Emitter<SearchState> emit,
      ) async {
    emit(const SearchLoading());

    try {
      final posts = await _searchPosts(event.filters);

      if (posts.isEmpty) {
        emit(const SearchEmpty('No results matching filters'));
      } else {
        emit(SearchLoaded(
          posts: posts,
          appliedFilters: event.filters,
        ));
      }
    } catch (e) {
      debugPrint('Filter error: $e');
      emit(SearchError('Failed to apply filters: $e'));
    }
  }

  Future<void> _onSearchCleared(
      SearchCleared event,
      Emitter<SearchState> emit,
      ) async {
    emit(const SearchInitial());
    _cachedPosts.clear();
    _cachedUsers.clear();
  }

  Future<void> _onSearchSuggestionRequested(
      SearchSuggestionRequested event,
      Emitter<SearchState> emit,
      ) async {
    try {
      // Rechercher les users
      final users = await _apiService.searchUsers(event.query);

      // Créer des suggestions basées sur les usernames
      final suggestions = users.map((u) => u.username).take(5).toList();

      if (state is SearchLoaded) {
        final currentState = state as SearchLoaded;
        emit(SearchLoaded(
          posts: currentState.posts,
          suggestions: suggestions,
          appliedFilters: currentState.appliedFilters,
        ));
      } else {
        emit(SearchLoaded(
          posts: const [],
          suggestions: suggestions,
          appliedFilters: const SearchFilters(),
        ));
      }
    } catch (e) {
      debugPrint('Suggestion error: $e');
      // Ne pas changer l'état en cas d'erreur de suggestions
    }
  }

  /// Recherche les posts selon les filtres
  /// Utilise getAllPosts puis filtre côté client
  Future<List<Post>> _searchPosts(SearchFilters filters) async {
    // Récupérer tous les posts si pas en cache
    if (_cachedPosts.isEmpty) {
      _cachedPosts = await _apiService.getAllPosts();
    }

    var filteredPosts = _cachedPosts;

    // Filtrer par username si spécifié
    if (filters.username != null && filters.username!.isNotEmpty) {
      filteredPosts = filteredPosts
          .where((p) => p.author.username.toLowerCase()
          .contains(filters.username!.toLowerCase()))
          .toList();
    }

    // Filtrer par query (caption)
    if (filters.query != null && filters.query!.isNotEmpty) {
      final query = filters.query!.toLowerCase();
      filteredPosts = filteredPosts.where((p) {
        final captionMatch = p.caption?.toLowerCase().contains(query) ?? false;
        final usernameMatch = p.author.username.toLowerCase().contains(query);
        final themeMatch = p.themeName?.toLowerCase().contains(query) ?? false;
        return captionMatch || usernameMatch || themeMatch;
      }).toList();
    }

    // Filtrer par thème
    if (filters.themeId != null && filters.themeId!.isNotEmpty) {
      // On suppose que themeId contient le nom du thème
      filteredPosts = filteredPosts
          .where((p) => p.themeName?.toLowerCase() == filters.themeId!.toLowerCase())
          .toList();
    }

    // Filtrer par date
    if (filters.startDate != null) {
      filteredPosts = filteredPosts
          .where((p) => p.createdAt.isAfter(filters.startDate!))
          .toList();
    }
    if (filters.endDate != null) {
      filteredPosts = filteredPosts
          .where((p) => p.createdAt.isBefore(filters.endDate!))
          .toList();
    }

    // Filtrer par tags
    if (filters.tags.isNotEmpty) {
      filteredPosts = filteredPosts.where((p) {
        final caption = p.caption?.toLowerCase() ?? '';
        return filters.tags.any((tag) => caption.contains('#${tag.toLowerCase()}'));
      }).toList();
    }

    // tri
    switch (filters.sortType) {
      case SearchSortType.relevance:
      // Pas de tri particulier (ordre de l'API)
        break;
      case SearchSortType.recent:
        filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SearchSortType.popular:
        filteredPosts.sort((a, b) => b.yeahCount.compareTo(a.yeahCount));
        break;
      case SearchSortType.oldest:
        filteredPosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    // Convertir en UI Posts
    return filteredPosts.map((apiPost) => _convertApiPostToUiPost(apiPost)).toList();
  }

  /// Convertir API Post en UI Post
  Post _convertApiPostToUiPost(api_models.Post apiPost) {
    return Post(
      id: apiPost.id.toString(),
      userId: apiPost.author.id.toString(),
      username: apiPost.author.username,
      avatarUrl: apiPost.author.profilePicture,
      imageUrl: apiPost.picture,
      caption: apiPost.caption,
      theme: apiPost.themeName,
      yeahCount: apiPost.yeahCount,
      commentCount: apiPost.commentCount,
      createdAt: apiPost.createdAt,
      streakDay: apiPost.artistStreak,
      isYeahed: false,
    );
  }
}