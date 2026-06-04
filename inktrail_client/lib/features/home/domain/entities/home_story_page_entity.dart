import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

class HomeStoryPageEntity {
  final List<StoryEntity> items;
  final int page;
  final int limit;
  final bool hasMore;
  final int? nextPage;

  const HomeStoryPageEntity({
    required this.items,
    required this.page,
    required this.limit,
    required this.hasMore,
    required this.nextPage,
  });
}
