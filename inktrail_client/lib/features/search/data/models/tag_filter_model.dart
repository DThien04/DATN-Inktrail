import 'package:ink_trail_client/features/search/domain/entities/tag_filter_entity.dart';

class TagFilterModel extends TagFilterEntity {
  const TagFilterModel({
    required super.id,
    required super.name,
    super.group,
    super.storyCount,
  });

  factory TagFilterModel.fromJson(Map<String, dynamic> json) {
    final groupJson = json['group'];
    TagGroupRefEntity? group;
    if (groupJson is Map<String, dynamic>) {
      final groupId = (groupJson['id'] as String? ?? '').trim();
      final groupName = (groupJson['name'] as String? ?? '').trim();
      if (groupId.isNotEmpty && groupName.isNotEmpty) {
        group = TagGroupRefEntity(id: groupId, name: groupName);
      }
    }

    return TagFilterModel(
      id: (json['id'] as String? ?? '').trim(),
      name: (json['name'] as String? ?? '').trim(),
      group: group,
      storyCount: _parseStoryCount(json['story_count'] ?? json['storyCount']),
    );
  }
}

int _parseStoryCount(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
