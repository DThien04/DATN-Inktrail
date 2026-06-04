import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/search/domain/entities/tag_filter_entity.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchState {
  final List<TagFilterEntity> tagFilters;
  final List<StoryEntity> results;
  final String? selectedTagId;
  final bool isLoadingTags;
  final SearchStatus status;
  final bool hasSearched;
  final String? errorMessage;

  const SearchState({
    this.tagFilters = const [],
    this.results = const [],
    this.selectedTagId,
    this.isLoadingTags = true,
    this.status = SearchStatus.initial,
    this.hasSearched = false,
    this.errorMessage,
  });

  bool get isLoadingResults => status == SearchStatus.loading;

  SearchState copyWith({
    List<TagFilterEntity>? tagFilters,
    List<StoryEntity>? results,
    Object? selectedTagId = _sentinel,
    bool? isLoadingTags,
    SearchStatus? status,
    bool? hasSearched,
    Object? errorMessage = _sentinel,
  }) {
    return SearchState(
      tagFilters: tagFilters ?? this.tagFilters,
      results: results ?? this.results,
      selectedTagId: identical(selectedTagId, _sentinel)
          ? this.selectedTagId
          : selectedTagId as String?,
      isLoadingTags: isLoadingTags ?? this.isLoadingTags,
      status: status ?? this.status,
      hasSearched: hasSearched ?? this.hasSearched,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _sentinel = Object();
