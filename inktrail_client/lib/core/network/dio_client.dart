import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'token_storage.dart';
import '../navigation/app_router.dart';

class DioClient {
  late final Dio _dio;
  late final Dio _refreshDio;
  final TokenStorage _tokenStorage;
  final VoidCallback? onForceLogout;
  static const _baseUrl = 'https://inktrail-server-1.onrender.com/api';
  DioClient(this._tokenStorage, {this.onForceLogout}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

  
    _refreshDio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
      ),
    );

    _dio.interceptors.add(
      _AuthInterceptor(
        _tokenStorage,
        _refreshDio,
        onForceLogout: onForceLogout, 
      ),
    );

  }

  Dio get dio => _dio;
}

// â”€â”€ Auth Interceptor â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _refreshDio;
  bool _isRefreshing = false;
  final VoidCallback? onForceLogout;
  _AuthInterceptor(
    this._tokenStorage,
    this._refreshDio, {
    this.onForceLogout, // â† thÃªm
  });

  // 1. Tá»± Ä‘á»™ng gáº¯n access token vÃ o má»i request
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;

      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null) {
          _forceLogout();
          return handler.next(err);
        }

        final response = await _refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String;

        await _tokenStorage.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
        final retryResponse = await _refreshDio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (_) {
        _forceLogout();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }

  void _forceLogout() async {
    await _tokenStorage.clearTokens();
    onForceLogout?.call();
    AppRouter.pushReplacement(AppRouter.home);
  }
}

