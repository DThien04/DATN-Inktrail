import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'package:ink_trail_client/core/notifications/onesignal_service.dart';
import 'package:ink_trail_client/features/auth/domain/entities/user_entity.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/logout_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:ink_trail_client/features/auth/domain/usecases/submit_lock_appeal_usecase.dart';

import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase _login;
  final RegisterUsecase _register;
  final LogoutUsecase _logout;
  final SubmitLockAppealUsecase _submitLockAppeal;

  AuthCubit({
    required LoginUsecase login,
    required RegisterUsecase register,
    required LogoutUsecase logout,
    required SubmitLockAppealUsecase submitLockAppeal,
  }) : _login = login,
       _register = register,
       _logout = logout,
       _submitLockAppeal = submitLockAppeal,
       super(const AuthState());

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _login(email: email, password: password);
      await bindOneSignalUser(
        userId: user.id,
        role: user.role.name,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on AccountLockedException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.locked,
          errorMessage: e.message,
          lockedInfo: LockedInfo(
            message: e.message,
            lockedReason: e.lockedReason,
            lockedUntil: e.lockedUntil,
            hasPendingAppeal: e.hasPendingAppeal,
            email: email,
            password: password,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<String?> submitLockAppeal({required String reason}) async {
    final info = state.lockedInfo;
    if (info == null) return 'Không tìm thấy thông tin tài khoản bị khóa.';
    try {
      final message = await _submitLockAppeal(
        email: info.email,
        password: info.password,
        reason: reason,
      );
      emit(
        state.copyWith(
          status: AuthStatus.locked,
          lockedInfo: info.copyWith(hasPendingAppeal: true),
        ),
      );
      return message;
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.locked,
          errorMessage: e.toString(),
        ),
      );
      rethrow;
    }
  }

  void clearLockedState() {
    emit(
      AuthState(
        status: AuthStatus.unauthenticated,
        user: null,
      ),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    emit(state.copyWith(status: AuthStatus.loading));
    try {
      final user = await _register(
        email: email,
        password: password,
        displayName: displayName,
      );
      await bindOneSignalUser(
        userId: user.id,
        role: user.role.name,
      );
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> logout() async {
    try {
      await _logout();
    } catch (_) {
    } finally {
      await unbindOneSignalUser();
      if (!isClosed) {
        emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      }
    }
  }

  void resetError() {
    if (isClosed) return;
    emit(state.copyWith(status: AuthStatus.initial, errorMessage: null));
  }

  void setCurrentUser(UserEntity user) {
    if (isClosed) return;
    unawaited(
      bindOneSignalUser(
        userId: user.id,
        role: user.role.name,
      ),
    );
    emit(state.copyWith(status: AuthStatus.authenticated, user: user));
  }

  void setUnauthenticated() {
    if (isClosed) return;
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      ),
    );
  }
}
