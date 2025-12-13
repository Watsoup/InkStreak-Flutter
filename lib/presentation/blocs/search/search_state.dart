import 'package:equatable/equatable.dart';
import 'package:inkstreak/presentation/blocs/search/search_filters.dart';

import '../../../data/models/post_models.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {
  const SearchInitial();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<Post> posts;
  final List<String> suggestions;
  final SearchFilters appliedFilters;

  const SearchLoaded({
    required this.posts,
    this.suggestions = const [],
    required this.appliedFilters,
  });

  @override
  List<Object?> get props => [posts, suggestions, appliedFilters];
}

class SearchEmpty extends SearchState {
  final String message;

  const SearchEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}