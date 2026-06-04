import 'package:ink_trail_client/features/home/domain/entities/story_entity.dart';

enum HomeApiStatus { initial, loading, success, failure }

class HomeApiState {
  final HomeApiStatus status;
  final List<StoryEntity> hotStories;
  final List<StoryEntity> monthlyRankingStories;
  final List<StoryEntity> newStories;
  final List<String> categories;
  final String selectedCategory;
  final String? errorMessage;
  final int hotPage;
  final int newPage;
  final bool hotHasMore;
  final bool newHasMore;
  final bool isLoadingMore;

  const HomeApiState({
    this.status = HomeApiStatus.initial,
    this.hotStories = const [],
    this.monthlyRankingStories = const [],
    this.newStories = const [],
    this.categories = const ['Tất cả'],
    this.selectedCategory = 'Tất cả',
    this.errorMessage,
    this.hotPage = 1,
    this.newPage = 1,
    this.hotHasMore = false,
    this.newHasMore = false,
    this.isLoadingMore = false,
  });

  HomeApiState copyWith({
    HomeApiStatus? status,
    List<StoryEntity>? hotStories,
    List<StoryEntity>? monthlyRankingStories,
    List<StoryEntity>? newStories,
    List<String>? categories,
    String? selectedCategory,
    String? errorMessage,
    int? hotPage,
    int? newPage,
    bool? hotHasMore,
    bool? newHasMore,
    bool? isLoadingMore,
  }) {
    return HomeApiState(
      status: status ?? this.status,
      hotStories: hotStories ?? this.hotStories,
      monthlyRankingStories: monthlyRankingStories ?? this.monthlyRankingStories,
      newStories: newStories ?? this.newStories,
      categories: categories ?? this.categories,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage ?? this.errorMessage,
      hotPage: hotPage ?? this.hotPage,
      newPage: newPage ?? this.newPage,
      hotHasMore: hotHasMore ?? this.hotHasMore,
      newHasMore: newHasMore ?? this.newHasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
