import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:ink_trail_client/features/home/domain/entities/home_inbox_item_entity.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_admin_broadcasts_cubit.dart';
import 'package:ink_trail_client/features/profile/presentation/cubit/profile_admin_broadcasts_state.dart';

class ProfileAdminBroadcastsPage extends StatelessWidget {
  const ProfileAdminBroadcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProfileAdminBroadcastsCubit>()..load(),
      child: const _ProfileAdminBroadcastsView(),
    );
  }
}

class _ProfileAdminBroadcastsView extends StatelessWidget {
  const _ProfileAdminBroadcastsView();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Thông báo từ hệ thống'),
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        actions: [
          BlocBuilder<ProfileAdminBroadcastsCubit, ProfileAdminBroadcastsState>(
            builder: (context, state) => TextButton(
              onPressed: state.unreadCount == 0 || state.isMarkingAll
                  ? null
                  : () => context.read<ProfileAdminBroadcastsCubit>().markAllAsRead(),
              child: Text(
                'Đọc tất cả',
                style: TextStyle(color: scheme.primary),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<ProfileAdminBroadcastsCubit, ProfileAdminBroadcastsState>(
        builder: (context, state) {
          if (state.errorMessage != null && !state.isLoading && state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                ),
              ),
            );
          }
          if (state.isLoading && state.items.isEmpty) {
            return const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFC4773B),
                ),
              ),
            );
          }
          if (state.items.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Text(
                  'Chưa có thông báo chung từ quản trị.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(fontSize: 12, color: scheme.error),
                  ),
                ),
              if (state.unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${state.unreadCount} mới',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: const Color(0xFFC4773B),
                  onRefresh: () => context.read<ProfileAdminBroadcastsCubit>().load(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    itemCount: state.items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return _AdminBroadcastTile(
                        key: ValueKey<Object>(item.id ?? index),
                        item: item,
                        onTap: () {
                          context.read<ProfileAdminBroadcastsCubit>().markItemAsRead(index);
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              content: SingleChildScrollView(
                                child: Text(
                                  item.body.isEmpty ? '—' : item.body,
                                  style: TextStyle(
                                    fontSize: 14,
                                    height: 1.45,
                                    color: Theme.of(ctx).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Đóng'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _AdminBroadcastTile extends StatelessWidget {
  final HomeInboxItemEntity item;
  final VoidCallback onTap;

  const _AdminBroadcastTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: item.isUnread ? scheme.surfaceContainerHighest : scheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.campaign_outlined,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.38,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.timeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
