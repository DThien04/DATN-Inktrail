class TagGroupRefEntity {
  final String id;
  final String name;

  const TagGroupRefEntity({
    required this.id,
    required this.name,
  });
}

class TagFilterEntity {
  final String id;
  final String name;
  final TagGroupRefEntity? group;
  final int storyCount;

  const TagFilterEntity({
    required this.id,
    required this.name,
    this.group,
    this.storyCount = 0,
  });
}

