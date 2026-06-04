import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/core/network/api_exception.dart';
import 'dart:async';

import 'package:ink_trail_client/core/widgets/login_promt_sheet.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_state.dart';
import 'package:ink_trail_client/core/theme/theme_cubit.dart';
import 'package:ink_trail_client/core/theme/theme_state.dart';
import 'package:ink_trail_client/features/profile/domain/entities/author_profile_entity.dart';
import 'package:ink_trail_client/features/profile/domain/usecases/profile_author_usecases.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_relations_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_relations_state.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_state.dart';
import 'package:ink_trail_client/features/profile/presentation/pages/about_app_page.dart';
import 'package:ink_trail_client/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:ink_trail_client/features/story_management/presentation/pages/my_author_stories_page.dart';
import 'package:ink_trail_client/features/profile/presentation/utils/profile_navigation.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_admin_broadcasts_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_admin_broadcasts_state.dart';
import 'package:ink_trail_client/features/profile/presentation/pages/profile_admin_broadcasts_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AuthCubit _authCubit;
  late final ProfileAdminBroadcastsCubit _broadcastsCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>();
    _broadcastsCubit = sl<ProfileAdminBroadcastsCubit>();
    unawaited(_broadcastsCubit.load());
  }

  @override
  Widget build(BuildContext context) {
    final authCubit = _authCubit;
    final broadcastsCubit = _broadcastsCubit;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider.value(value: broadcastsCubit),
        BlocProvider(
          create: (_) {
            final cubit = sl<ProfileCubit>();
            if (authCubit.state.isAuthenticated) cubit.fetchMyProfile();
            return cubit;
          },
        ),
        BlocProvider(create: (_) => sl<ProfileRelationsCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            context.read<ProfileCubit>().fetchMyProfile();
          }
        },
        child: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, authState) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildHeader(context, authState),
                      const SizedBox(height: 16),
                      BlocBuilder<ProfileCubit, ProfileState>(
                        builder: (context, profileState) =>
                            _buildStats(context, authState, profileState),
                      ),
                      const SizedBox(height: 20),
                      _buildAccountSection(context, authState),
                      const SizedBox(height: 12),
                      _buildAppSection(context),
                      if (authState.isAuthenticated) ...[
                        const SizedBox(height: 12),
                        _buildMenuSection(
                          context,
                          items: [
                            _MenuItem(
                              icon: Iconsax.logout,
                              label: 'Đăng xuất',
                              color: Colors.redAccent,
                              onTap: () => _showLogoutDialog(context),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthState authState) {
    if (authState.isAuthenticated) {
      return _buildMenuSection(
        context,
        title: 'Tài khoản',
        items: [
          _MenuItem(
            icon: Iconsax.user_edit,
            label: 'Chỉnh sửa hồ sơ',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
          _MenuItem(
            icon: Iconsax.lock,
            label: 'Đổi mật khẩu',
            onTap: () => _showChangePasswordSheet(context),
          ),
          _MenuItem(
            icon: Iconsax.book_1,
            label: 'Truyện của tôi',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MyAuthorStoriesPage(
                  authorId: authState.user!.id,
                  authorName: authState.user!.displayName,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildMenuSection(
      context,
      title: 'Tài khoản',
      items: [
        _MenuItem(
          icon: Iconsax.login,
          label: 'Đăng nhập',
          color: const Color(0xFFC4773B),
          onTap: () => LoginPromptSheet.show(context),
        ),
        _MenuItem(
          icon: Iconsax.user_add,
          label: 'Tạo tài khoản mới',
          onTap: () => LoginPromptSheet.show(context),
        ),
      ],
    );
  }
  Widget _buildAppSection(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _buildMenuSection(
      context,
      title: 'Ứng dụng',
      items: [
        _MenuItem(
          icon: Iconsax.moon,
          label: 'Chế độ tối',
          trailing: BlocBuilder<ThemeCubit, ThemeState>(
            builder: (context, state) => Switch(
              value: state.isDarkMode,
              onChanged: (value) => context.read<ThemeCubit>().setDarkMode(value),
              activeThumbColor: const Color(0xFFC4773B),
            ),
          ),
        ),
        _MenuItem(
          icon: Iconsax.notification,
          label: 'Thông báo hệ thống',
          trailing: BlocBuilder<ProfileAdminBroadcastsCubit, ProfileAdminBroadcastsState>(
            builder: (context, state) {
              final unread = state.unreadCount;
              if (unread <= 0) return const SizedBox.shrink();
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                  ),
                ),
              );
            },
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => const ProfileAdminBroadcastsPage(),
            ),
          ),
        ),
        _MenuItem(
          icon: Iconsax.info_circle,
          label: 'Về ứng dụng',
          value: 'v1.0.0',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutAppPage()),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AuthState state) {
    final scheme = Theme.of(context).colorScheme;
    final user = state.user;
    final isAuth = state.isAuthenticated;

    return Container(
      width: double.infinity,
      color: scheme.surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 44,
            backgroundColor: scheme.surfaceContainerHighest,
            backgroundImage: isAuth && (user?.avatarUrl?.isNotEmpty ?? false)
                ? NetworkImage(user!.avatarUrl!)
                : null,
            child: isAuth && (user?.avatarUrl?.isNotEmpty ?? false)
                ? null
                : isAuth
                    ? Text(
                        user!.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC4773B),
                        ),
                      )
                    : const Icon(Iconsax.user, size: 40, color: Color(0xFFCCBBAA)),
          ),
          const SizedBox(height: 14),
          Text(
            isAuth ? user!.displayName : 'Khách',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          if (isAuth)
            Text(
              user!.email,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            )
          else
            GestureDetector(
              onTap: () => LoginPromptSheet.show(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Đăng nhập để mở khóa tính năng',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFC4773B),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    AuthState authState,
    ProfileState profileState,
  ) {
    final isAuth = authState.isAuthenticated;
    final profile = profileState.profile;

    if (!isAuth) {
      return _buildStatsCard(
        context,
        isAuth: false,
        storiesReadCount: 0,
        favoriteCount: 0,
        followingCount: 0,
        followerCount: 0,
        onFollowingTap: () => _showFollowedAuthorsSheet(context, false),
        onFollowersTap: null,
      );
    }

    return _buildStatsCard(
      context,
      isAuth: true,
      storiesReadCount: profile?.storiesReadCount ?? 0,
      favoriteCount: profile?.favoriteCount ?? 0,
      followingCount: profile?.followingAuthorCount ?? 0,
      followerCount: profile?.followerCount ?? 0,
      onFollowingTap: () => _showFollowedAuthorsSheet(context, true),
      onFollowersTap: () => _showFollowersSheet(context, true),
    );
  }

  Widget _buildStatsCard(
    BuildContext context, {
    required bool isAuth,
    required int storiesReadCount,
    required int favoriteCount,
    required int followingCount,
    required int followerCount,
    VoidCallback? onFollowingTap,
    VoidCallback? onFollowersTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem(
                context,
                isAuth ? '$storiesReadCount' : '--',
                'Đã đọc',
                isAuth,
              ),
              _buildStatDivider(context),
              _buildStatItem(
                context,
                isAuth ? '$followerCount' : '--',
                'Người theo dõi',
                isAuth,
                onTap: onFollowersTap,
              ),
              _buildStatDivider(context),
              _buildStatItem(
                context,
                isAuth ? '$followingCount' : '--',
                'Đang theo dõi',
                isAuth,
                onTap: onFollowingTap,
              ),
              _buildStatDivider(context),
              _buildStatItem(
                context,
                isAuth ? '$favoriteCount' : '--',
                'Lượt thích',
                isAuth,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showFollowedAuthorsSheet(
    BuildContext context,
    bool isAuthenticated,
  ) async {
    if (!isAuthenticated) {
      LoginPromptSheet.show(context);
      return;
    }

    context.read<ProfileRelationsCubit>().loadFollowing();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileRelationsCubit>(),
        child: const _FollowedAuthorsSheet(),
      ),
    );

    if (context.mounted) {
      context.read<ProfileCubit>().fetchMyProfile();
    }
  }

  Future<void> _showFollowersSheet(
    BuildContext context,
    bool isAuthenticated,
  ) async {
    if (!isAuthenticated) {
      LoginPromptSheet.show(context);
      return;
    }

    context.read<ProfileRelationsCubit>().loadFollowers();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<ProfileRelationsCubit>(),
        child: const _FollowersSheet(),
      ),
    );

    if (context.mounted) {
      context.read<ProfileCubit>().fetchMyProfile();
    }
  }

  Future<void> _showChangePasswordSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    bool isAuth, {
    VoidCallback? onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: isAuth
                    ? scheme.onSurface
                    : scheme.outline,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              height: 20,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatDivider(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 0.5,
      height: 36,
      color: scheme.outlineVariant,
    );
  }

  Widget _buildMenuSection(
    BuildContext context, {
    String? title,
    required List<_MenuItem> items,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: scheme.outlineVariant, width: 0.5),
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                final isLast = i == items.length - 1;
                return Column(
                  children: [
                    _buildMenuItem(context, items[i]),
                    if (!isLast)
                      Divider(
                        height: 0.5,
                        thickness: 0.5,
                        indent: 52,
                        color: scheme.outlineVariant,
                      ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, _MenuItem item) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 20,
              color: item.color ?? scheme.onSurfaceVariant,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: item.color ?? scheme.onSurface,
                ),
              ),
            ),
            if (item.trailing != null) item.trailing!,
            if (item.value != null)
              Text(
                item.value!,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
            if (item.trailing == null && item.color == null) ...[
              const SizedBox(width: 6),
              Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: scheme.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Iconsax.logout,
                  color: Colors.redAccent,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Đăng xuất',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Bạn có chắc muốn đăng xuất\nkhỏi tài khoản không?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text('Hủy'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        Navigator.pop(context);
                        await _authCubit.logout();
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Đăng xuất',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowedAuthorsSheet extends StatelessWidget {
  const _FollowedAuthorsSheet();

  @override
  Widget build(BuildContext context) {
    return const _ProfileRelationsSheet(type: ProfileRelationType.following);
  }
}

class _FollowersSheet extends StatelessWidget {
  const _FollowersSheet();

  @override
  Widget build(BuildContext context) {
    return const _ProfileRelationsSheet(type: ProfileRelationType.followers);
  }
}

class _ChangePasswordSheet extends StatefulWidget {
  const _ChangePasswordSheet();

  @override
  State<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<_ChangePasswordSheet> {
  final ChangePasswordUsecase _changePassword = sl<ChangePasswordUsecase>();
  final _oldPasswordCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _hideOldPassword = true;
  bool _hideNewPassword = true;
  bool _hideConfirmPassword = true;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _oldPasswordCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final oldPassword = _oldPasswordCtrl.text.trim();
    final newPassword = _newPasswordCtrl.text.trim();
    final confirmPassword = _confirmPasswordCtrl.text.trim();

    if (oldPassword.isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      setState(() => _errorMessage = 'Vui lòng nhập đầy đủ thông tin.');
      return;
    }

    if (newPassword.length < 6) {
      setState(() => _errorMessage = 'Mật khẩu mới phải có ít nhất 6 ký tự.');
      return;
    }

    if (newPassword != confirmPassword) {
      setState(() => _errorMessage = 'Xác nhận mật khẩu mới không khớp.');
      return;
    }

    if (oldPassword == newPassword) {
      setState(() => _errorMessage = 'Mật khẩu mới phải khác mật khẩu cũ.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      await _changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Đổi mật khẩu thành công.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      var message = 'Không thể đổi mật khẩu lúc này.';
      if (e is ApiException && e.message.trim().isNotEmpty) {
        message = e.message.trim();
      }
      setState(() => _errorMessage = message);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Đổi mật khẩu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: Icon(Icons.close_rounded, color: scheme.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Nhập mật khẩu hiện tại và mật khẩu mới để cập nhật.',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _buildPasswordField(
                  controller: _oldPasswordCtrl,
                  label: 'Mật khẩu cũ',
                  hint: 'Nhập mật khẩu hiện tại',
                  obscureText: _hideOldPassword,
                  onToggleVisibility: () =>
                      setState(() => _hideOldPassword = !_hideOldPassword),
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _newPasswordCtrl,
                  label: 'Mật khẩu mới',
                  hint: 'Ít nhất 6 ký tự',
                  obscureText: _hideNewPassword,
                  onToggleVisibility: () =>
                      setState(() => _hideNewPassword = !_hideNewPassword),
                ),
                const SizedBox(height: 12),
                _buildPasswordField(
                  controller: _confirmPasswordCtrl,
                  label: 'Xác nhận mật khẩu mới',
                  hint: 'Nhập lại mật khẩu mới',
                  obscureText: _hideConfirmPassword,
                  onToggleVisibility: () => setState(
                    () => _hideConfirmPassword = !_hideConfirmPassword,
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: scheme.outlineVariant),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFFC4773B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Cập nhật mật khẩu',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          textInputAction: TextInputAction.next,
          style: TextStyle(color: scheme.onSurface),
          onChanged: (_) {
            if (_errorMessage != null) {
              setState(() => _errorMessage = null);
            }
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: scheme.onSurfaceVariant),
            filled: true,
            fillColor: scheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: scheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFC4773B), width: 1.2),
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileRelationsSheet extends StatelessWidget {
  final ProfileRelationType type;

  const _ProfileRelationsSheet({required this.type});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<ProfileRelationsCubit, ProfileRelationsState>(
      builder: (context, state) {
        final isLoading =
            state.status == ProfileRelationsStatus.loading && state.type == type;
        final hasError =
            state.status == ProfileRelationsStatus.failure && state.type == type;
        final users = state.type == type ? state.users : const [];

        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.45,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: scheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                type == ProfileRelationType.followers
                                    ? 'Người theo dõi'
                                    : 'Đang theo dõi',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: scheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${users.length} người dùng',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFC4773B),
                            ),
                          )
                        : hasError
                            ? _FollowedAuthorsStatus(
                                message: state.errorMessage!,
                                onRetry: () {
                                  if (type == ProfileRelationType.followers) {
                                    return context
                                        .read<ProfileRelationsCubit>()
                                        .loadFollowers();
                                  }
                                  return context
                                      .read<ProfileRelationsCubit>()
                                      .loadFollowing();
                                },
                              )
                            : users.isEmpty
                                ? _FollowedAuthorsStatus(
                                    message: type == ProfileRelationType.followers
                                        ? 'Bạn chưa có người theo dõi nào. Khi có, danh sách sẽ hiện ở đây.'
                                        : 'Bạn chưa theo dõi người dùng nào. Khi theo dõi, danh sách sẽ hiện ở đây.',
                                  )
                                : ListView.separated(
                                    controller: scrollController,
                                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                                    itemCount: users.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                                    itemBuilder: (_, index) {
                                      final user = users[index];
                                      if (type == ProfileRelationType.followers) {
                                        return _FollowerTile(
                                          user: user,
                                          onTap: () => _openProfile(context, user),
                                        );
                                      }
                                      return _FollowedAuthorTile(
                                        author: user,
                                        isBusy: state.busyUserId == user.id,
                                        onTap: () => _openProfile(context, user),
                                        onUnfollow: () => _unfollow(context, user),
                                      );
                                    },
                                  ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _openProfile(
    BuildContext context,
    FollowedAuthorEntity user,
  ) async {
    await openUserProfile(
      context,
      userId: user.id,
      initialName: user.displayName,
      initialBio: user.bio,
      initialStoryCount: user.storyCount,
    );
  }

  Future<void> _unfollow(
    BuildContext context,
    FollowedAuthorEntity user,
  ) async {
    final success = await context.read<ProfileRelationsCubit>().unfollow(user);
    if (!context.mounted) return;

    final message = success
        ? 'Đã hủy theo dõi ${user.displayName}.'
        : 'Không thể hủy theo dõi lúc này.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }
}

class _FollowedAuthorTile extends StatelessWidget {
  final FollowedAuthorEntity author;
  final bool isBusy;
  final VoidCallback onTap;
  final VoidCallback onUnfollow;

  const _FollowedAuthorTile({
    required this.author,
    required this.isBusy,
    required this.onTap,
    required this.onUnfollow,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFEADFD4)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF1E3D6),
                backgroundImage: author.avatarUrl.isNotEmpty
                    ? NetworkImage(author.avatarUrl)
                    : null,
                child: author.avatarUrl.isNotEmpty
                    ? null
                    : Text(author.displayName.isNotEmpty ? author.displayName[0].toUpperCase() : 'A'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      author.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF241B15),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      author.bio.isEmpty
                          ? 'Chạm để xem hồ sơ người dùng và các tác phẩm đã đăng.'
                          : author.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 0,
                        height: 0,
                        color: Colors.transparent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${author.storyCount} tác phẩm • ${author.followerCount} người theo dõi',
                      style: const TextStyle(fontSize: 11, color: Color(0xFFA19084)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: isBusy ? null : onUnfollow,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFC25B47),
                  backgroundColor: const Color(0xFFFFF4F0),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isBusy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Hủy theo dõi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowerTile extends StatelessWidget {
  final FollowedAuthorEntity user;
  final VoidCallback onTap;

  const _FollowerTile({
    required this.user,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1C1512) : Colors.white;
    final borderColor = isDark ? const Color(0xFF4A362C) : const Color(0xFFEADFD4);
    final titleColor = scheme.onSurface;
    final subtitleColor = scheme.onSurfaceVariant;
    final metaColor = isDark ? const Color(0xFFC5AEA1) : const Color(0xFFA19084);
    final avatarBg = isDark ? const Color(0xFF3A2E27) : const Color(0xFFF1E3D6);
    final arrowColor = isDark ? const Color(0xFFB9A79D) : const Color(0xFFCCCCCC);

    return Material(
      color: cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
            boxShadow: isDark
                ? const []
                : const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarBg,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                child: user.avatarUrl.isNotEmpty
                    ? null
                    : Text(
                        user.displayName.isNotEmpty
                            ? user.displayName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: isDark ? const Color(0xFFD68A43) : const Color(0xFFC78A57),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.bio.isEmpty
                          ? 'Chạm để xem hồ sơ người dùng.'
                          : user.bio,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${user.storyCount} tác phẩm • ${user.followerCount} người theo dõi',
                      style: TextStyle(
                        fontSize: 11,
                        color: metaColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                Iconsax.arrow_right_3,
                size: 16,
                color: arrowColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FollowedAuthorsStatus extends StatelessWidget {
  final String message;
  final Future<void> Function()? onRetry;

  const _FollowedAuthorsStatus({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8E8279)),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 14),
              FilledButton(onPressed: () => onRetry!.call(), child: const Text('Thử lại')),
            ],
          ],
        ),
      ),
    );
  }
}


class _MenuItem {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? trailing;
  final Color? color;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.value,
    this.trailing,
    this.color,
    this.onTap,
  });
}






