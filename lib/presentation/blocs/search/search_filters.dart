class SearchFilters {
  final String? query;
  final String? themeId;
  final String? username;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<String> tags;
  final SearchSortType sortType;

  const SearchFilters({
    this.query,
    this.themeId,
    this.username,
    this.startDate,
    this.endDate,
    this.tags = const [],
    this.sortType = SearchSortType.relevance,
  });

  SearchFilters copyWith({
    String? query,
    String? themeId,
    String? username,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? tags,
    SearchSortType? sortType,
  }) {
    return SearchFilters(
      query: query ?? this.query,
      themeId: themeId ?? this.themeId,
      username: username ?? this.username,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      tags: tags ?? this.tags,
      sortType: sortType ?? this.sortType,
    );
  }

  bool get hasActiveFilters =>
      themeId != null ||
          username != null ||
          startDate != null ||
          endDate != null ||
          tags.isNotEmpty;
}

enum SearchSortType {
  relevance,
  recent,
  popular,
  oldest,
}