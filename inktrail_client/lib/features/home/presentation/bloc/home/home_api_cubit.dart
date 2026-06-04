import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_home_categories_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_hot_stories_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_monthly_ranking_stories_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_new_stories_usecase.dart';

import 'home_api_state.dart';

class HomeApiCubit extends Cubit<HomeApiState> {
  static const int _pageSize = 20;

  final GetHotStoriesUsecase _getHotStories;
  final GetMonthlyRankingStoriesUsecase _getMonthlyRankingStories;
  final GetNewStoriesUsecase _getNewStories;
  final GetHomeCategoriesUsecase _getHomeCategories;

  HomeApiCubit({
    required GetHotStoriesUsecase getHotStories,
    required GetMonthlyRankingStoriesUsecase getMonthlyRankingStories,
    required GetNewStoriesUsecase getNewStories,
    required GetHomeCategoriesUsecase getHomeCategories,
  }) : _getHotStories = getHotStories,
       _getMonthlyRankingStories = getMonthlyRankingStories,
       _getNewStories = getNewStories,
       _getHomeCategories = getHomeCategories,
       super(const HomeApiState());

  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeApiStatus.loading, errorMessage: null));

    try {
      final monthlyRankingStories = await _getMonthlyRankingStories(limit: 9);
      final firstPages = await Future.wait([
        _getHotStories.page(page: 1, limit: _pageSize),
        _getNewStories.page(page: 1, limit: _pageSize),
      ]);
      final categoryNames = await _getHomeCategories();

      emit(
        state.copyWith(
          status: HomeApiStatus.success,
          hotStories: firstPages[0].items,
          monthlyRankingStories: monthlyRankingStories,
          newStories: firstPages[1].items,
          categories: ['Tất cả', ...categoryNames],
          hotPage: firstPages[0].page,
          newPage: firstPages[1].page,
          hotHasMore: firstPages[0].hasMore,
          newHasMore: firstPages[1].hasMore,
          isLoadingMore: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: HomeApiStatus.failure,
          errorMessage: e.toString(),
          isLoadingMore: false,
        ),
      );
    }
  }

  Future<void> loadMoreStories() async {
    if (state.status != HomeApiStatus.success) return;
    if (state.isLoadingMore) return;
    if (!state.hotHasMore && !state.newHasMore) return;

    emit(state.copyWith(isLoadingMore: true));
    try {
      var nextHotStories = state.hotStories;
      var nextHotPage = state.hotPage;
      var nextHotHasMore = state.hotHasMore;

      var nextNewStories = state.newStories;
      var nextNewPage = state.newPage;
      var nextNewHasMore = state.newHasMore;

      if (state.hotHasMore) {
        final hotPage = await _getHotStories.page(
          page: state.hotPage + 1,
          limit: _pageSize,
        );
        nextHotStories = [...state.hotStories, ...hotPage.items];
        nextHotPage = hotPage.page;
        nextHotHasMore = hotPage.hasMore;
      }

      if (state.newHasMore) {
        final newPage = await _getNewStories.page(
          page: state.newPage + 1,
          limit: _pageSize,
        );
        nextNewStories = [...state.newStories, ...newPage.items];
        nextNewPage = newPage.page;
        nextNewHasMore = newPage.hasMore;
      }

      emit(
        state.copyWith(
          hotStories: nextHotStories,
          newStories: nextNewStories,
          hotPage: nextHotPage,
          newPage: nextNewPage,
          hotHasMore: nextHotHasMore,
          newHasMore: nextNewHasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingMore: false));
    }
  }

  void selectCategory(String category) {
    emit(state.copyWith(selectedCategory: category));
  }
}
