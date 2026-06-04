import 'package:ink_trail_client/features/home/domain/entities/home_story_page_entity.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

abstract class HomeRepository {
  Future<List<StoryEntity>> getHomeBanners();
  Future<List<StoryEntity>> getHotStories({int limit = 6});
  Future<HomeStoryPageEntity> getHotStoriesPage({int page = 1, int limit = 6});
  Future<List<StoryEntity>> getMonthlyRankingStories({int limit = 9});
  Future<List<StoryEntity>> getNewStories({int limit = 6});
  Future<HomeStoryPageEntity> getNewStoriesPage({int page = 1, int limit = 6});
  Future<List<String>> getTagNames();
}
