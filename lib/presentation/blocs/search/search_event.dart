import 'package:equatable/equatable.dart';
import 'package:inkstreak/presentation/blocs/search/search_filters.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchQueryChanged extends SearchEvent {
  final String query;

  const SearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchFiltersApplied extends SearchEvent {
  final SearchFilters filters;

  const SearchFiltersApplied(this.filters);

  @override
  List<Object?> get props => [filters];
}

class SearchCleared extends SearchEvent {
  const SearchCleared();
}

class SearchSuggestionRequested extends SearchEvent {
  final String query;

  const SearchSuggestionRequested(this.query);

  @override
  List<Object?> get props => [query];
}