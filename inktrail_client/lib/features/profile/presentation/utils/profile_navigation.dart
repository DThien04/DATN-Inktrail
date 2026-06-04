import 'package:flutter/material.dart';
import 'package:ink_trail_client/core/navigation/app_router.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/core/navigation/main_tab_controller.dart';
import 'package:ink_trail_client/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/pages/author_profile_page.dart';

Future<void> openUserProfile(
  BuildContext context, {
  required String userId,
  String? initialName,
  String? initialBio,
  int? initialStoryCount,
  bool openSelfProfileTab = true,
}) async {
  final currentUserId = sl<AuthCubit>().state.user?.id;
  if (openSelfProfileTab && currentUserId != null && currentUserId == userId) {
    AppRouter.navigatorKey.currentState?.popUntil((route) => route.isFirst);
    MainTabController.openProfileTab();
    return;
  }

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => AuthorProfilePage(
        authorId: userId,
        initialName: initialName ?? '',
        initialBio: initialBio ?? '',
        initialStoryCount: initialStoryCount,
      ),
    ),
  );
}
