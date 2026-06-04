// features/profile/presentation/pages/edit_profile_page.dart
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ink_trail_client/core/di/service_locator.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/widgets/app_field_label.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/entities/profile_entity.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _picker = ImagePicker();
  late final AuthCubit _authCubit;
  late final ProfileCubit _profileCubit;
  bool _seeded = false;
  Uint8List? _avatarPreviewBytes;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>();
    _profileCubit = sl<ProfileCubit>()..fetchMyProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _profileCubit,
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }
        },
        builder: (context, state) {
          _seedFieldsFromState(state);
          final isSaving = state.status == ProfileStatus.saving;
          final isUploadingAvatar = state.status == ProfileStatus.uploadingAvatar;
          final profile = state.profile;
          final scheme = Theme.of(context).colorScheme;
          final hasAvatar =
              _avatarPreviewBytes != null ||
              (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty);

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(
                  Iconsax.arrow_left,
                  color: scheme.onSurface,
                  size: 22,
                ),
              ),
              title: Text(
                'Chỉnh sửa hồ sơ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
              actions: [
                GestureDetector(
                  onTap: isSaving ? null : _save,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Lưu',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC4773B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
              // Avatar section
              Container(
                color: scheme.surface,
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: const Color(0xFFF0EBE4),
                        backgroundImage: _avatarPreviewBytes != null
                            ? MemoryImage(_avatarPreviewBytes!)
                            : (profile?.avatarUrl != null &&
                                      profile!.avatarUrl!.isNotEmpty)
                                  ? NetworkImage(profile.avatarUrl!)
                                  : null,
                        child: _avatarPreviewBytes != null ||
                                (profile?.avatarUrl != null &&
                                    profile!.avatarUrl!.isNotEmpty)
                            ? null
                            : Text(
                                _nameCtrl.text.isEmpty
                                    ? 'U'
                                    : _nameCtrl.text[0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFC4773B),
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: isUploadingAvatar ? null : _pickImage,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFFC4773B),
                              shape: BoxShape.circle,
                              border: Border.all(color: scheme.surface, width: 2),
                            ),
                            child: const Icon(
                              Iconsax.camera,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (hasAvatar) ...[
                const SizedBox(height: 10),
                TextButton(
                  onPressed: isUploadingAvatar ? null : _deleteAvatar,
                  child: const Text(
                    'Xóa avatar',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Form fields
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin cá nhân',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppFieldLabel(
                      label: 'Tên hiển thị',
                      hint: 'Nhập tên của bạn',
                      controller: _nameCtrl,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Vui lòng nhập tên';
                        if (v.length < 2) return 'Tên tối thiểu 2 ký tự';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Bio field
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Giới thiệu',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _bioCtrl,
                          maxLines: 3,
                          maxLength: 150,
                          style: TextStyle(fontSize: 14, color: scheme.onSurface),
                          decoration: InputDecoration(
                            hintText: 'Viết vài dòng về bản thân...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            filled: true,
                            fillColor: scheme.surface,
                            contentPadding: const EdgeInsets.all(14),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: scheme.outlineVariant,
                                width: 0.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: scheme.outlineVariant,
                                width: 0.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color(0xFFC4773B),
                                width: 1.5,
                              ),
                            ),
                            counterStyle: TextStyle(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Email — readonly
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tài khoản',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Iconsax.sms,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _authCubit.state.user?.email ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (isSaving || isUploadingAvatar) ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC4773B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: (isSaving || isUploadingAvatar)
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Lưu thay đổi',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) return;

    setState(() => _avatarPreviewBytes = bytes);
    final mimeType = _guessMimeType(file.name);

    final profile = await _profileCubit.uploadAvatar(
      avatarBytes: bytes,
      fileName: file.name.isEmpty ? 'avatar.jpg' : file.name,
      mimeType: mimeType,
    );
    if (profile == null || !mounted) return;

    _syncAuthUser(profile);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cập nhật avatar thành công')));
  }

  Future<void> _deleteAvatar() async {
    final profile = await _profileCubit.deleteAvatar();
    if (profile == null || !mounted) return;

    setState(() => _avatarPreviewBytes = null);
    _syncAuthUser(profile);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã xóa avatar')));
  }

  void _seedFieldsFromState(ProfileState state) {
    if (_seeded) return;
    final profile = state.profile;
    if (profile == null) return;
    _nameCtrl.text = profile.displayName;
    _bioCtrl.text = profile.bio ?? '';
    _seeded = true;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final profile = await _profileCubit.updateProfile(
      displayName: _nameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
    );

    if (profile == null || !mounted) return;
    _syncAuthUser(profile);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cập nhật profile thành công')));
    Navigator.pop(context);
  }

  void _syncAuthUser(ProfileEntity profile) {
    final currentAuth = _authCubit.state.user;
    final role = UserRole.values.firstWhere(
      (item) => item.name == profile.role,
      orElse: () => currentAuth?.role ?? UserRole.reader,
    );
    _authCubit.setCurrentUser(
      UserEntity(
        id: profile.id,
        email: profile.email,
        displayName: profile.displayName,
        avatarUrl: profile.avatarUrl,
        bio: profile.bio,
        role: role,
      ),
    );
  }

  String _guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }
}
