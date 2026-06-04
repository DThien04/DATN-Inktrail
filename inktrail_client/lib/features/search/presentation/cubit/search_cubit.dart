import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/search/domain/entities/tag_filter_entity.dart';
import 'package:ink_trail_client/features/search/domain/usecases/get_search_tags_usecase.dart';
import 'package:ink_trail_client/features/search/domain/usecases/search_stories_usecase.dart';

import 'search_state.dart';

class SearchCubit extends Cubit<SearchState> {
  final GetSearchTagsUsecase _getTags;
  final SearchStoriesUsecase _searchStories;

  SearchCubit({
    required GetSearchTagsUsecase getTags,
    required SearchStoriesUsecase searchStories,
  }) : _getTags = getTags,
       _searchStories = searchStories,
       super(const SearchState());

  Future<void> loadInitial({
    required String query,
    required String? initialTagName,
    required String sort,
  }) async {
    await loadTags(initialTagName: initialTagName);
    await search(query: query, sort: sort, immediate: true);
  }

  Future<void> loadTags({String? initialTagName}) async {
    emit(state.copyWith(isLoadingTags: true));

    try {
      final tags = await _getTags();
      final matchedId = _matchInitialTagId(tags, initialTagName);
      emit(
        state.copyWith(
          tagFilters: tags,
          selectedTagId: matchedId,
          isLoadingTags: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingTags: false));
    }
  }

  void selectTagFilter(String? tagId) {
    emit(state.copyWith(selectedTagId: tagId));
  }

  Future<void> search({
    required String query,
    required String sort,
    bool immediate = false,
  }) async {
    final normalizedQuery = query.trim();

    if (state.isLoadingTags) return;

    if (!immediate &&
        normalizedQuery.isEmpty &&
        state.selectedTagId == null) {
      emit(
        state.copyWith(
          results: const [],
          hasSearched: false,
          status: SearchStatus.initial,
          errorMessage: null,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: SearchStatus.loading,
        hasSearched: true,
        errorMessage: null,
      ),
    );

    try {
      final results = await _searchStories(
        query: normalizedQuery,
        tagId: state.selectedTagId,
        sort: sort,
        limit: 20,
      );
      emit(
        state.copyWith(
          results: results,
          status: SearchStatus.success,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  String? _matchInitialTagId(
    List<TagFilterEntity> tags,
    String? initialTagName,
  ) {
    final normalizedInitial = _normalizeText(initialTagName ?? '');
    if (normalizedInitial.isEmpty) return state.selectedTagId;

    for (final tag in tags) {
      if (_normalizeText(tag.name) == normalizedInitial) {
        return tag.id;
      }
    }
    return state.selectedTagId;
  }

  String _normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll(
          RegExp(
            r'[\u00e0\u00e1\u1ea1\u1ea3\u00e3\u0103\u1eb1\u1eaf\u1eb7\u1eb3\u1eb5\u00e2\u1ea7\u1ea5\u1ead\u1ea9\u1eab]',
          ),
          'a',
        )
        .replaceAll(
          RegExp(r'[\u00e8\u00e9\u1eb9\u1ebb\u1ebd\u00ea\u1ec1\u1ebf\u1ec7\u1ec3\u1ec5]'),
          'e',
        )
        .replaceAll(RegExp(r'[\u00ec\u00ed\u1ecb\u1ec9\u0129]'), 'i')
        .replaceAll(
          RegExp(
            r'[\u00f2\u00f3\u1ecd\u1ecf\u00f5\u00f4\u1ed3\u1ed1\u1ed9\u1ed5\u1ed7\u01a1\u1edd\u1edb\u1ee3\u1edf\u1ee1]',
          ),
          'o',
        )
        .replaceAll(
          RegExp(r'[\u00f9\u00fa\u1ee5\u1ee7\u0169\u01b0\u1eeb\u1ee9\u1ef1\u1eed\u1eef]'),
          'u',
        )
        .replaceAll(RegExp(r'[\u1ef3\u00fd\u1ef5\u1ef7\u1ef9]'), 'y')
        .replaceAll('\u0111', 'd')
        .trim();
  }
}
