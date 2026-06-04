import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/entities/tag_filter_entity.dart';
import 'package:ink_trail_client/features/tags/domain/usecases/get_tags_usecase.dart';

import 'tags_state.dart';

class TagsCubit extends Cubit<TagsState> {
  final GetTagsUsecase _getTags;

  TagsCubit({required GetTagsUsecase getTags})
      : _getTags = getTags,
        super(const TagsState());

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      final rows = await _getTags();
      final computed = _computeSections(tags: rows, query: state.query);
      emit(
        state.copyWith(
          tags: rows,
          groupedSections: computed.groupedSections,
          ungroupedTags: computed.ungroupedTags,
          selectedSectionId: _alignSelection(
            selectedSectionId: state.selectedSectionId,
            sections: computed.groupedSections,
          ),
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> refresh() => load();

  void setQuery(String query) {
    final nextQuery = query.trim().toLowerCase();
    if (nextQuery == state.query) return;

    final computed = _computeSections(tags: state.tags, query: nextQuery);
    emit(
      state.copyWith(
        query: nextQuery,
        groupedSections: computed.groupedSections,
        ungroupedTags: computed.ungroupedTags,
        selectedSectionId: _alignSelection(
          selectedSectionId: state.selectedSectionId,
          sections: computed.groupedSections,
        ),
      ),
    );
  }

  void selectSection(String id) {
    if (state.selectedSectionId == id) return;
    emit(state.copyWith(selectedSectionId: id));
  }

  String? _alignSelection({
    required String? selectedSectionId,
    required List<TagSection> sections,
  }) {
    if (sections.isEmpty) return null;
    final has = sections.any((s) => s.id == selectedSectionId);
    if (selectedSectionId == null || !has) return sections.first.id;
    return selectedSectionId;
  }

  _ComputedSections _computeSections({
    required List<TagFilterEntity> tags,
    required String query,
  }) {
    final filtered = query.isEmpty
        ? tags
        : tags.where((t) => t.name.toLowerCase().contains(query)).toList();

    final Map<String, List<TagFilterEntity>> byGroupId = {};
    final Map<String, String> groupNames = {};
    final ungrouped = <TagFilterEntity>[];

    for (final tag in filtered) {
      final group = tag.group;
      if (group == null) {
        ungrouped.add(tag);
      } else {
        groupNames[group.id] = group.name;
        byGroupId.putIfAbsent(group.id, () => []).add(tag);
      }
    }

    final groupIds = byGroupId.keys.toList()
      ..sort((a, b) => (groupNames[a] ?? '').compareTo(groupNames[b] ?? ''));
    ungrouped.sort((a, b) => a.name.compareTo(b.name));

    final sections = <TagSection>[];
    for (final gid in groupIds) {
      final sorted = [...byGroupId[gid]!]..sort((a, b) => a.name.compareTo(b.name));
      sections.add(
        TagSection(
          id: gid,
          title: groupNames[gid] ?? gid,
          tags: sorted,
        ),
      );
    }

    return _ComputedSections(
      groupedSections: sections,
      ungroupedTags: ungrouped,
    );
  }
}

class _ComputedSections {
  final List<TagSection> groupedSections;
  final List<TagFilterEntity> ungroupedTags;

  const _ComputedSections({
    required this.groupedSections,
    required this.ungroupedTags,
  });
}

