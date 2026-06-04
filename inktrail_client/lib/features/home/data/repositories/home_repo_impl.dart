import 'package:ink_trail_client/features/home/domain/entities/home_story_page_entity.dart';
import 'package:ink_trail_client/features/home/data/resources/home_remote_datasource.dart';
import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_repository.dart';

class HomeRepoImpl implements HomeRepository {
  final HomeRemoteDatasource _datasource;

  const HomeRepoImpl(this._datasource);

  @override
  Future<List<StoryEntity>> getHomeBanners() => _datasource.getHomeBanners();

  @override
  Future<List<StoryEntity>> getHotStories({int limit = 6}) =>
      _datasource.getHotStories(limit: limit);

  @override
  Future<HomeStoryPageEntity> getHotStoriesPage({int page = 1, int limit = 6}) =>
      _datasource.getHotStoriesPage(page: page, limit: limit);

  @override
  Future<List<StoryEntity>> getMonthlyRankingStories({int limit = 9}) =>
      _datasource.getMonthlyRankingStories(limit: limit);

  @override
  Future<List<StoryEntity>> getNewStories({int limit = 6}) =>
      _datasource.getNewStories(limit: limit);

  @override
  Future<HomeStoryPageEntity> getNewStoriesPage({int page = 1, int limit = 6}) =>
      _datasource.getNewStoriesPage(page: page, limit: limit);

  @override
  Future<List<String>> getTagNames() => _datasource.getTagNames();
}
