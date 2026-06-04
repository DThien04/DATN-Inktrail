import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:ink_trail_client/core/local/offline_db.dart';
import 'package:ink_trail_client/core/local/offline_repository.dart';
import 'package:ink_trail_client/core/network/dio_client.dart';
import 'package:ink_trail_client/core/network/token_storage.dart';
import 'package:ink_trail_client/core/storage/reading_progress_local_cache.dart';
import 'package:ink_trail_client/core/theme/theme_cubit.dart';
import 'package:ink_trail_client/features/auth/data/repositories/auth_repo_impl.dart';
import 'package:ink_trail_client/features/auth/data/resources/auth_remote_datasource.dart';
import 'package:ink_trail_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/submit_lock_appeal_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/verify_reset_otp_usecase.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ink_trail_client/features/chapter_management/data/resources/chapter_management_remote_datasource.dart';
import 'package:ink_trail_client/features/chapter_management/data/repositories/chapter_management_repository_impl.dart';
import 'package:ink_trail_client/features/chapter_management/domain/repositories/chapter_management_repository.dart';
import 'package:ink_trail_client/features/chapter_management/domain/usecases/chapter_management_usecases.dart';
import 'package:ink_trail_client/features/chapter_management/presentation/cubit/my_story_details_cubit.dart';
import 'package:ink_trail_client/features/home/data/repositories/home_repo_impl.dart';
import 'package:ink_trail_client/features/home/data/repositories/home_notifications_repo_impl.dart';
import 'package:ink_trail_client/features/home/data/resources/home_remote_datasource.dart';
import 'package:ink_trail_client/features/home/data/resources/home_notifications_remote_datasource.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_notifications_repository.dart';
import 'package:ink_trail_client/features/home/domain/repositories/home_repository.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_home_categories_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_home_inbox_items_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_home_unread_notifications_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_public_admin_broadcast_log_items_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_hot_stories_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_monthly_ranking_stories_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/get_new_stories_usecase.dart';
import 'package:ink_trail_client/features/home/domain/usecases/mark_home_notifications_read_usecase.dart';
import 'package:ink_trail_client/features/report/domain/usecases/submit_report_appeal_usecase.dart';
import 'package:ink_trail_client/features/home/presentation/bloc/home/home_api_cubit.dart';
import 'package:ink_trail_client/features/home/presentation/bloc/notifications/home_notifications_cubit.dart';
import 'package:ink_trail_client/features/library/data/repositories/library_repo_impl.dart';
import 'package:ink_trail_client/features/library/data/resources/library_remote_datasource.dart';
import 'package:ink_trail_client/features/library/domain/repositories/library_repository.dart';
import 'package:ink_trail_client/features/library/domain/usecases/library_remote_history_usecases.dart';
import 'package:ink_trail_client/features/library/presentation/cubit/library_cubit.dart';
import 'package:ink_trail_client/features/profile/data/repositories/profile_repo_impl.dart';
import 'package:ink_trail_client/features/profile/data/resources/profile_remote_datasource.dart';
import 'package:ink_trail_client/features/profile/domain/repositories/profile_repository.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/get_my_profile_usecase.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/delete_my_avatar_usecase.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/profile_author_usecases.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/upload_my_avatar_usecase.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/update_my_profile_usecase.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/author_profile_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_admin_broadcasts_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_relations_cubit.dart';
import 'package:ink_trail_client/features/report/data/repositories/report_repo_impl.dart';
import 'package:ink_trail_client/features/report/data/resources/report_remote_datasource.dart';
import 'package:ink_trail_client/features/report/domain/repositories/report_repository.dart';
import 'package:ink_trail_client/features/report/domain/usecases/report_usecases.dart';
import 'package:ink_trail_client/features/reader/data/repositories/reader_repo_impl.dart';
import 'package:ink_trail_client/features/reader/data/resources/reader_remote_datasource.dart';
import 'package:ink_trail_client/features/reader/domain/repositories/reader_repository.dart';
import 'package:ink_trail_client/features/reader/domain/usecases/reader_usecases.dart';
import 'package:ink_trail_client/features/reader/presentation/cubit/reader_cubit.dart';
import 'package:ink_trail_client/features/report/presentation/cubit/report_appeal_cubit.dart';
import 'package:ink_trail_client/features/reader/presentation/cubit/reader_state.dart';
import 'package:ink_trail_client/features/search/data/repositories/search_repo_impl.dart';
import 'package:ink_trail_client/features/search/data/resources/search_remote_datasource.dart';
import 'package:ink_trail_client/features/search/domain/repositories/search_repository.dart';
import 'package:ink_trail_client/features/search/domain/usecases/get_search_tags_usecase.dart';
import 'package:ink_trail_client/features/search/domain/usecases/search_stories_usecase.dart';
import 'package:ink_trail_client/features/search/presentation/cubit/search_cubit.dart';
import 'package:ink_trail_client/features/story_detail/data/repositories/story_detail_repo_impl.dart';
import 'package:ink_trail_client/features/story_detail/data/resources/story_detail_remote_datasource.dart';
import 'package:ink_trail_client/features/story_detail/domain/repositories/story_detail_repository.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_highlighted_comments_usecase.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_story_chapters_usecase.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_story_suggestions_usecase.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/get_story_detail_info_usecase.dart';
import 'package:ink_trail_client/features/story_detail/domain/usecases/sync_story_reading_progress_usecase.dart';
import 'package:ink_trail_client/features/story_detail/presentation/cubit/story_detail_cubit.dart';
import 'package:ink_trail_client/features/story_rating/data/repositories/story_rating_repository_impl.dart';
import 'package:ink_trail_client/features/story_rating/domain/repositories/story_rating_repository.dart';
import 'package:ink_trail_client/features/story_rating/domain/usecases/story_rating_usecases.dart';
import 'package:ink_trail_client/features/story_management/data/resources/story_management_remote_datasource.dart';
import 'package:ink_trail_client/features/story_management/data/repositories/story_management_repository_impl.dart';
import 'package:ink_trail_client/features/story_management/domain/repositories/story_management_repository.dart';
import 'package:ink_trail_client/features/story_management/domain/usecases/story_management_usecases.dart';
import 'package:ink_trail_client/features/story_management/presentation/cubit/my_author_stories_cubit.dart';
import 'package:ink_trail_client/features/story_download/domain/entities/story_download_chapter_entity.dart';
import 'package:ink_trail_client/features/story_download/domain/usecases/story_download_usecases.dart';
import 'package:ink_trail_client/features/story_download/presentation/cubit/story_download_cubit.dart';
import 'package:ink_trail_client/features/story_rating/presentation/cubit/story_rating_cubit.dart';
import 'package:ink_trail_client/features/story_rating/presentation/cubit/story_rating_state.dart';
import 'package:ink_trail_client/features/tags/data/repositories/tags_repo_impl.dart';
import 'package:ink_trail_client/features/tags/domain/repositories/tags_repository.dart';
import 'package:ink_trail_client/features/tags/domain/usecases/get_tags_usecase.dart';
import 'package:ink_trail_client/features/tags/presentation/cubit/tags_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // ── Storage ──────────────────────────────────────────
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => TokenStorage(sl()));
  sl.registerLazySingleton(() => ReadingProgressLocalCache());
  sl.registerLazySingleton(() => OfflineDb());
  sl.registerLazySingleton(() => OfflineRepository(sl()));
  sl.registerLazySingleton(() => ThemeCubit(sl())..load());

  // ── Network ──────────────────────────────────────────
  sl.registerLazySingleton(
    () => DioClient(sl(), onForceLogout: () => sl<AuthCubit>().logout()),
  );

  // ── Auth feature ─────────────────────────────────────
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasourceImpl(sl<DioClient>().dio, sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepoImpl(sl()));
  sl.registerLazySingleton(() => LoginUsecase(sl()));
  sl.registerLazySingleton(() => RegisterUsecase(sl()));
  sl.registerLazySingleton(() => LogoutUsecase(sl()));
  sl.registerLazySingleton(() => ForgotPasswordUsecase(sl()));
  sl.registerLazySingleton(() => VerifyResetOtpUsecase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUsecase(sl()));
  sl.registerLazySingleton(() => SubmitLockAppealUsecase(sl()));
  sl.registerLazySingleton(
    () => AuthCubit(
      login: sl(),
      register: sl(),
      logout: sl(),
      submitLockAppeal: sl(),
    ),
  );

  // ── Profile feature ──────────────────────────────────
  sl.registerLazySingleton<ProfileRemoteDatasource>(
    () => ProfileRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ProfileRepository>(() => ProfileRepoImpl(sl()));
  sl.registerLazySingleton(() => GetMyProfileUsecase(sl()));
  sl.registerLazySingleton(() => UpdateMyProfileUsecase(sl()));
  sl.registerLazySingleton(() => UploadMyAvatarUsecase(sl()));
  sl.registerLazySingleton(() => DeleteMyAvatarUsecase(sl()));
  sl.registerLazySingleton(() => ChangePasswordUsecase(sl()));
  sl.registerLazySingleton(() => GetAuthorProfileUsecase(sl()));
  sl.registerLazySingleton(() => GetAuthorStoriesUsecase(sl()));
  sl.registerLazySingleton<StoryManagementRemoteDatasource>(
    () => StoryManagementRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<StoryManagementRepository>(
    () => StoryManagementRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetMyStoriesUsecase(sl()));
  sl.registerLazySingleton(() => CreateMyStoryUsecase(sl()));
  sl.registerLazySingleton(() => UpdateMyStoryUsecase(sl()));
  sl.registerLazySingleton(() => UpdateMyStoryStatusUsecase(sl()));
  sl.registerLazySingleton(() => DeleteMyStoryUsecase(sl()));
  sl.registerLazySingleton<ChapterManagementRemoteDatasource>(
    () => ChapterManagementRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ChapterManagementRepository>(
    () => ChapterManagementRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetMyStoryChaptersUsecase(sl()));
  sl.registerLazySingleton(() => CreateMyStoryChapterUsecase(sl()));
  sl.registerLazySingleton(() => UpdateMyStoryChapterUsecase(sl()));
  sl.registerLazySingleton(() => PublishMyStoryChapterUsecase(sl()));
  sl.registerLazySingleton(() => UnpublishMyStoryChapterUsecase(sl()));
  sl.registerLazySingleton(() => DeleteMyStoryChapterUsecase(sl()));
  sl.registerLazySingleton(() => SetAuthorFollowUsecase(sl()));
  sl.registerLazySingleton(() => GetFollowedAuthorsUsecase(sl()));
  sl.registerLazySingleton(() => GetFollowersUsecase(sl()));
  sl.registerFactory(
    () => ProfileCubit(
      getMyProfile: sl(),
      updateMyProfile: sl(),
      uploadMyAvatar: sl(),
      deleteMyAvatar: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileRelationsCubit(
      getFollowers: sl(),
      getFollowedAuthors: sl(),
      setAuthorFollow: sl(),
    ),
  );
  sl.registerFactory(
    () => MyAuthorStoriesCubit(
      getMyStories: sl(),
      createMyStory: sl(),
      updateMyStory: sl(),
      updateMyStoryStatus: sl(),
      deleteMyStory: sl(),
    ),
  );
  sl.registerFactory(
    () => MyStoryDetailsCubit(
      getMyStoryChapters: sl(),
      createMyStoryChapter: sl(),
      updateMyStoryChapter: sl(),
      publishMyStoryChapter: sl(),
      unpublishMyStoryChapter: sl(),
      deleteMyStoryChapter: sl(),
    ),
  );
  sl.registerFactoryParam<AuthorProfileCubit, AuthorProfileSeed, void>(
    (seed, _) => AuthorProfileCubit(
      seed: seed,
      getAuthorProfile: sl(),
      getAuthorStories: sl(),
      setAuthorFollow: sl(),
    ),
  );

  // ── Home feature ─────────────────────────────────────
  sl.registerLazySingleton<HomeRemoteDatasource>(
    () => HomeRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<HomeRepository>(() => HomeRepoImpl(sl()));
  sl.registerLazySingleton(() => GetHotStoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetMonthlyRankingStoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetNewStoriesUsecase(sl()));
  sl.registerLazySingleton(() => GetHomeCategoriesUsecase(sl()));
  sl.registerFactory(
    () => HomeApiCubit(
      getHotStories: sl(),
      getMonthlyRankingStories: sl(),
      getNewStories: sl(),
      getHomeCategories: sl(),
    ),
  );
  sl.registerLazySingleton<HomeNotificationsRemoteDatasource>(
    () => HomeNotificationsRemoteDatasourceImpl(sl<DioClient>().dio, sl()),
  );
  sl.registerLazySingleton<HomeNotificationsRepository>(
    () => HomeNotificationsRepoImpl(sl()),
  );
  sl.registerLazySingleton(() => GetHomeUnreadNotificationsUsecase(sl()));
  sl.registerLazySingleton(() => GetHomeNotificationSocketBaseUrlUsecase(sl()));
  sl.registerLazySingleton(() => GetHomeInboxItemsUsecase(sl()));
  sl.registerLazySingleton(() => GetPublicAdminBroadcastLogItemsUsecase(sl()));
  sl.registerLazySingleton(() => MarkHomeNotificationsReadUsecase(sl()));
  sl.registerLazySingleton<ReportRemoteDatasource>(
    () => ReportRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ReportRepository>(() => ReportRepoImpl(sl()));
  sl.registerLazySingleton(() => SubmitStoryReportUsecase(sl()));
  sl.registerLazySingleton(() => SubmitChapterReportUsecase(sl()));
  sl.registerLazySingleton(() => SubmitChapterCommentReportUsecase(sl()));
  sl.registerLazySingleton(() => SubmitReportAppealUsecase(sl()));
  sl.registerFactory(
    () => ReportAppealCubit(
      submitReportAppeal: sl(),
    ),
  );
  sl.registerLazySingleton(
    () => HomeNotificationsCubit(
      getUnreadCount: sl(),
      getInboxItems: sl(),
      markNotificationsRead: sl(),
      getSocketBaseUrl: sl(),
      tokenStorage: sl(),
    ),
  );
  sl.registerFactory(
    () => ProfileAdminBroadcastsCubit(
      getItems: sl(),
      getSocketBaseUrl: sl(),
      tokenStorage: sl(),
      storage: sl(),
    ),
  );

  // Search feature
  sl.registerLazySingleton<SearchRemoteDatasource>(
    () => SearchRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<SearchRepository>(() => SearchRepoImpl(sl()));
  sl.registerLazySingleton(() => GetSearchTagsUsecase(sl()));
  sl.registerLazySingleton(() => SearchStoriesUsecase(sl()));
  sl.registerFactory(
    () => SearchCubit(
      getTags: sl(),
      searchStories: sl(),
    ),
  );

  // Tags feature
  sl.registerLazySingleton<TagsRepository>(() => TagsRepoImpl(sl()));
  sl.registerLazySingleton(() => GetTagsUsecase(sl()));
  sl.registerFactory(
    () => TagsCubit(
      getTags: sl(),
    ),
  );

  // Story detail feature
  sl.registerLazySingleton<StoryDetailRemoteDatasource>(
    () => StoryDetailRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<StoryDetailRepository>(
    () => StoryDetailRepoImpl(sl()),
  );
  sl.registerLazySingleton<StoryRatingRepository>(
    () => StoryRatingRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetHighlightedCommentsUsecase(sl()));
  sl.registerLazySingleton(() => GetStorySuggestionsUsecase(sl()));
  sl.registerLazySingleton(() => GetStoryDetailInfoUsecase(sl()));
  sl.registerLazySingleton(() => GetStoryChaptersUsecase(sl()));
  sl.registerLazySingleton(() => SyncStoryReadingProgressUsecase(sl()));
  sl.registerLazySingleton(() => GetStoryRatingsUsecase(sl()));
  sl.registerLazySingleton(() => SubmitStoryRatingUsecase(sl()));
  sl.registerLazySingleton(() => GetDownloadedStoryChapterIdsUsecase(sl()));
  sl.registerLazySingleton(() => DownloadStoryChapterUsecase(sl()));
  sl.registerFactoryParam<StoryDetailCubit, StoryDetailSeed, void>(
    (seed, _) => StoryDetailCubit(
      seed: seed,
      getHighlightedComments: sl(),
      getStorySuggestions: sl(),
      getStoryDetailInfo: sl(),
      getStoryChapters: sl(),
    ),
  );
  sl.registerFactoryParam<StoryRatingCubit, StoryRatingSeed, void>(
    (seed, _) => StoryRatingCubit(
      seed: seed,
      getStoryRatings: sl(),
      submitStoryRating: sl(),
    ),
  );
  sl.registerFactoryParam<StoryDownloadCubit, StoryDownloadSeed, void>(
    (seed, _) => StoryDownloadCubit(
      seed: seed,
      getDownloadedIds: sl(),
      downloadChapter: sl(),
    ),
  );

  // Reader feature
  sl.registerLazySingleton<ReaderRemoteDatasource>(
    () => ReaderRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<ReaderRepository>(() => ReaderRepoImpl(sl()));
  sl.registerLazySingleton(() => TrackReaderReadEventUsecase(sl()));
  sl.registerLazySingleton(() => SetChapterLikeUsecase(sl()));
  sl.registerLazySingleton(() => GetFeaturedChapterCommentUsecase(sl()));
  sl.registerLazySingleton(() => GetChapterCommentsUsecase(sl()));
  sl.registerLazySingleton(() => SetChapterCommentLikeUsecase(sl()));
  sl.registerLazySingleton(() => SaveChapterCommentUsecase(sl()));
  sl.registerLazySingleton(() => DeleteChapterCommentUsecase(sl()));
  sl.registerLazySingleton(() => GetReaderSocketBaseUrlUsecase(sl()));
  sl.registerFactoryParam<ReaderCubit, ReaderSeed, void>(
    (seed, _) => ReaderCubit(
      seed: seed,
      getFeaturedChapterComment: sl(),
      setChapterLike: sl(),
      submitChapterReport: sl(),
    ),
  );

  // ── Library feature ─────────────────────────────────────
  sl.registerLazySingleton<LibraryRemoteDatasource>(
    () => LibraryRemoteDatasourceImpl(sl<DioClient>().dio),
  );
  sl.registerLazySingleton<LibraryRepository>(() => LibraryRepoImpl(sl()));
  sl.registerLazySingleton(() => GetLibraryRemoteHistoryUsecase(sl()));
  sl.registerLazySingleton(() => SaveLibraryRemoteProgressUsecase(sl()));
  sl.registerFactory(
    () => LibraryCubit(
      tokenStorage: sl(),
      localCache: sl(),
      getRemoteHistory: sl(),
      saveRemoteProgress: sl(),
    ),
  );
}
