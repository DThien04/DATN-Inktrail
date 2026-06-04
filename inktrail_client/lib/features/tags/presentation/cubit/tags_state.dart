import 'package:ink_trail_client/core/entities/tag_filter_entity.dart';

class TagSection {
  final String id;
  final String title;
  final List<TagFilterEntity> tags;

  const TagSection({
    required this.id,
    required this.title,
    required this.tags,
  });
}

class TagsState {
  final bool isLoading;
  final String query;
  final List<TagFilterEntity> tags;
  final String? selectedSectionId;
  final List<TagSection> groupedSections;
  final List<TagFilterEntity> ungroupedTags;
  final String? errorMessage;

  const TagsState({
    this.isLoading = false,
    this.query = '',
    this.tags = const [],
    this.selectedSectionId,
    this.groupedSections = const [],
    this.ungroupedTags = const [],
    this.errorMessage,
  });

  TagsState copyWith({
    bool? isLoading,
    String? query,
    List<TagFilterEntity>? tags,
    String? selectedSectionId,
    List<TagSection>? groupedSections,
    List<TagFilterEntity>? ungroupedTags,
    Object? errorMessage = _sentinel,
  }) {
    return TagsState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      tags: tags ?? this.tags,
      selectedSectionId: selectedSectionId ?? this.selectedSectionId,
      groupedSections: groupedSections ?? this.groupedSections,
      ungroupedTags: ungroupedTags ?? this.ungroupedTags,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const Object _sentinel = Object();

