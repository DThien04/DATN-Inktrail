import 'package:dio/dio.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/features/profile/data/models/author_profile_model.dart';
import 'package:ink_trail_client/features/profile/data/models/profile_model.dart';
import 'package:http_parser/http_parser.dart';

abstract class ProfileRemoteDatasource {
  Future<ProfileModel> getMyProfile();
  Future<ProfileModel> updateMyProfile({
    required String displayName,
    required String bio,
  });
  Future<ProfileModel> uploadMyAvatar({
    required List<int> avatarBytes,
    required String fileName,
    required String mimeType,
  });
  Future<ProfileModel> deleteMyAvatar();
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  });
  Future<AuthorProfileModel> getAuthorProfile({required String authorId});
  Future<List<AuthorStoryModel>> getAuthorStories({required String authorId});
  Future<AuthorFollowResultModel> setAuthorFollow({
    required String authorId,
    required bool follow,
    required bool fallbackFollowing,
    required int fallbackFollowerCount,
  });
  Future<List<FollowedAuthorModel>> getFollowedAuthors();
  Future<List<FollowedAuthorModel>> getFollowers();
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final Dio _dio;

  const ProfileRemoteDatasourceImpl(this._dio);

  @override
  Future<ProfileModel> getMyProfile() async {
    try {
      final response = await _dio.get('/profile/me');
      return ProfileModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ProfileModel> updateMyProfile({
    required String displayName,
    required String bio,
  }) async {
    try {
      final response = await _dio.patch(
        '/profile/me',
        data: {'display_name': displayName, 'bio': bio},
      );
      final userJson = response.data['user'] as Map<String, dynamic>;
      return ProfileModel.fromJson(userJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ProfileModel> uploadMyAvatar({
    required List<int> avatarBytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final formData = FormData.fromMap({
        'avatar_file': MultipartFile.fromBytes(
          avatarBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });
      final response = await _dio.post(
        '/profile/me/avatar',
        data: formData,
      );
      final userJson = response.data['user'] as Map<String, dynamic>;
      return ProfileModel.fromJson(userJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ProfileModel> deleteMyAvatar() async {
    try {
      final response = await _dio.delete('/profile/me/avatar');
      final userJson = response.data['user'] as Map<String, dynamic>;
      return ProfileModel.fromJson(userJson);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _dio.patch(
        '/profile/me/password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_new_password': confirmPassword,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AuthorProfileModel> getAuthorProfile({required String authorId}) async {
    try {
      final response = await _dio.get('/profile/$authorId');
      final json = response.data as Map<String, dynamic>? ?? const {};
      return AuthorProfileModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<AuthorStoryModel>> getAuthorStories({
    required String authorId,
  }) async {
    try {
      final response = await _dio.get('/stories/author/$authorId');
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(AuthorStoryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AuthorFollowResultModel> setAuthorFollow({
    required String authorId,
    required bool follow,
    required bool fallbackFollowing,
    required int fallbackFollowerCount,
  }) async {
    try {
      final response = follow
          ? await _dio.post('/profile/$authorId/follow')
          : await _dio.delete('/profile/$authorId/follow');
      final json = response.data as Map<String, dynamic>? ?? const {};
      return AuthorFollowResultModel.fromJson(
        json,
        fallbackFollowing: fallbackFollowing,
        fallbackFollowerCount: fallbackFollowerCount,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<FollowedAuthorModel>> getFollowedAuthors() async {
    try {
      final response = await _dio.get('/profile/me/following-users');
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(FollowedAuthorModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<FollowedAuthorModel>> getFollowers() async {
    try {
      final response = await _dio.get('/profile/me/followers');
      final rows = response.data as List<dynamic>? ?? const [];
      return rows
          .whereType<Map<String, dynamic>>()
          .map(FollowedAuthorModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
