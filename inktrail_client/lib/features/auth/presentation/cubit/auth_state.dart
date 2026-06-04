import '../../domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  failure,
  locked,
}

class LockedInfo {
  final String message;
  final String? lockedReason;
  final String? lockedUntil;
  final bool hasPendingAppeal;
  final String email;
  final String password;

  const LockedInfo({
    required this.message,
    required this.lockedReason,
    required this.lockedUntil,
    required this.hasPendingAppeal,
    required this.email,
    required this.password,
  });

  LockedInfo copyWith({bool? hasPendingAppeal}) => LockedInfo(
        message: message,
        lockedReason: lockedReason,
        lockedUntil: lockedUntil,
        hasPendingAppeal: hasPendingAppeal ?? this.hasPendingAppeal,
        email: email,
        password: password,
      );
}

class AuthState {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final LockedInfo? lockedInfo;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.lockedInfo,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLocked => status == AuthStatus.locked;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    LockedInfo? lockedInfo,
    bool clearLockedInfo = false,
  }) => AuthState(
    status: status ?? this.status,
    user: user ?? this.user,
    errorMessage: errorMessage,
    lockedInfo: clearLockedInfo ? null : (lockedInfo ?? this.lockedInfo),
  );
}
