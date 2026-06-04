import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/core/navigation/app_router.dart';
import 'package:ink_trail_client/core/notifications/notification_navigation_service.dart';
import 'package:ink_trail_client/core/network/token_storage.dart';
import 'package:ink_trail_client/features/auth/domain/entities/user_entity.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ink_trail_client/features/profile/domain/entities/profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/get_my_profile_usecase.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  static const _minimumSplashDuration = Duration(milliseconds: 2000);
  static const _primary = Color(0xFFC4773B);

  late final AnimationController _entranceController;
  late final AnimationController _progressController;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _taglineFade;
  late final Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();

    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _logoFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );
    _taglineFade = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _entranceController.forward();
    _bootstrap();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      _restoreSession(),
      Future<void>.delayed(_minimumSplashDuration),
    ]);
    if (!mounted) return;
    AppRouter.pushReplacement(AppRouter.home);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(NotificationNavigationService.flushPendingPushNavigation());
    });
  }

  Future<void> _restoreSession() async {
    final tokenStorage = sl<TokenStorage>();
    final authCubit = sl<AuthCubit>();
    final hasToken = await tokenStorage.hasToken();

    if (!hasToken) {
      authCubit.setUnauthenticated();
      return;
    }

    try {
      final profile = await sl<GetMyProfileUsecase>()();
      authCubit.setCurrentUser(_mapProfileToUser(profile));
    } catch (_) {
      await tokenStorage.clearTokens();
      authCubit.setUnauthenticated();
    }
  }

  UserEntity _mapProfileToUser(ProfileEntity profile) {
    final role = switch (profile.role.trim().toLowerCase()) {
      'admin' => UserRole.admin,
      'author' => UserRole.author,
      _ => UserRole.reader,
    };

    return UserEntity(
      id: profile.id,
      email: profile.email,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl,
      bio: profile.bio,
      role: role,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _SplashPalette.of(isDark: isDark);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: palette.background,
                ),
              ),
            ),
          ),
          Positioned(
            top: -140,
            right: -120,
            child: IgnorePointer(
              child: _RadialGlow(color: palette.glowWarm, size: 380),
            ),
          ),
          Positioned(
            bottom: -160,
            left: -140,
            child: IgnorePointer(
              child: _RadialGlow(color: palette.glowSoft, size: 420),
            ),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _entranceController,
                      builder: (_, child) {
                        return Opacity(
                          opacity: _logoFade.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 128,
                        height: 128,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: palette.logoHalo,
                          boxShadow: [
                            BoxShadow(
                              color: _primary
                                  .withValues(alpha: isDark ? 0.30 : 0.22),
                              blurRadius: 48,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(22),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/logo/logo.webp',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(
                        opacity: _taglineFade,
                        child: Text(
                          'Chạm vào từng câu chuyện.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: palette.tagline,
                            height: 1.45,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: 36),
              child: Center(
                child: FadeTransition(
                  opacity: _taglineFade,
                  child: SizedBox(
                    width: 120,
                    child: _IndeterminateBar(
                      controller: _progressController,
                      color: _primary,
                      trackColor: palette.progressTrack,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplashPalette {
  const _SplashPalette({
    required this.background,
    required this.glowWarm,
    required this.glowSoft,
    required this.logoHalo,
    required this.tagline,
    required this.progressTrack,
  });

  final List<Color> background;
  final Color glowWarm;
  final Color glowSoft;
  final Color logoHalo;
  final Color tagline;
  final Color progressTrack;

  static _SplashPalette of({required bool isDark}) {
    if (isDark) {
      return const _SplashPalette(
        background: [Color(0xFF1B1612), Color(0xFF0F0C0A)],
        glowWarm: Color(0x33C4773B),
        glowSoft: Color(0x1FE4A672),
        logoHalo: Color(0x14FFFFFF),
        tagline: Color(0xFFB9A48C),
        progressTrack: Color(0x1FC4773B),
      );
    }
    return const _SplashPalette(
      background: [Color(0xFFFBF6EF), Color(0xFFF0E4D4)],
      glowWarm: Color(0x33C4773B),
      glowSoft: Color(0x4DE4C4A2),
      logoHalo: Color(0xA6FFFFFF),
      tagline: Color(0xFF8A6B50),
      progressTrack: Color(0x33C4773B),
    );
  }
}

class _RadialGlow extends StatelessWidget {
  const _RadialGlow({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.0)],
        ),
      ),
    );
  }
}

class _IndeterminateBar extends StatelessWidget {
  const _IndeterminateBar({
    required this.controller,
    required this.color,
    required this.trackColor,
  });

  final AnimationController controller;
  final Color color;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 3,
        child: LayoutBuilder(
          builder: (ctx, constraints) {
            final fullWidth = constraints.maxWidth;
            return AnimatedBuilder(
              animation: controller,
              builder: (_, _) {
                const segmentFraction = 0.45;
                final t = Curves.easeInOut.transform(controller.value);
                final leftFraction =
                    (t * (1 + segmentFraction)) - segmentFraction;
                return Stack(
                  children: [
                    Positioned.fill(child: ColoredBox(color: trackColor)),
                    Positioned(
                      left: leftFraction * fullWidth,
                      top: 0,
                      bottom: 0,
                      width: fullWidth * segmentFraction,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              color.withValues(alpha: 0.0),
                              color,
                              color.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
