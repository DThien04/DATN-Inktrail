import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class AccountLockedPage extends StatelessWidget {
  const AccountLockedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<AuthCubit>(),
      child: const _AccountLockedView(),
    );
  }
}

class _AccountLockedView extends StatefulWidget {
  const _AccountLockedView();

  @override
  State<_AccountLockedView> createState() => _AccountLockedViewState();
}

class _AccountLockedViewState extends State<_AccountLockedView> {
  final _formKey = GlobalKey<FormState>();
  final _reasonCtrl = TextEditingController();
  bool _submitting = false;
  String? _resultMessage;
  String? _errorMessage;

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  String _formatUntil(String? value) {
    if (value == null || value.isEmpty) return 'Vĩnh viễn';
    try {
      final dt = DateTime.parse(value).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return value;
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
      _resultMessage = null;
    });
    try {
      final message =
          await context.read<AuthCubit>().submitLockAppeal(reason: _reasonCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _resultMessage = message ?? 'Đã gửi khiếu nại.';
        _reasonCtrl.clear();
      });
    } catch (err) {
      if (!mounted) return;
      setState(() => _errorMessage = err.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản bị khóa'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            context.read<AuthCubit>().clearLockedState();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          final info = state.lockedInfo;
          if (info == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Không tìm thấy thông tin khóa.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final hasPending = info.hasPendingAppeal;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.redAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.lock_outline,
                                color: Colors.redAccent, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Tài khoản của bạn đang bị khóa',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.redAccent,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (info.lockedReason != null &&
                            info.lockedReason!.isNotEmpty) ...[
                          const Text(
                            'Lý do:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(info.lockedReason!),
                          const SizedBox(height: 8),
                        ],
                        Text('Mở khóa: ${_formatUntil(info.lockedUntil)}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    hasPending
                        ? 'Bạn đã gửi khiếu nại và đang chờ quản trị viên phản hồi.'
                        : 'Nếu bạn cho rằng quyết định không thỏa đáng, hãy gửi khiếu nại tới quản trị viên.',
                    style: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 13.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!hasPending)
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            controller: _reasonCtrl,
                            minLines: 4,
                            maxLines: 8,
                            maxLength: 1500,
                            decoration: const InputDecoration(
                              hintText:
                                  'Trình bày lý do bạn muốn khiếu nại (tối thiểu 20 ký tự)...',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              final trimmed = (value ?? '').trim();
                              if (trimmed.length < 20) {
                                return 'Vui lòng nhập ít nhất 20 ký tự.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _submitting ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFC4773B),
                                disabledBackgroundColor:
                                    const Color(0xFFC4773B).withValues(alpha: 0.6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: _submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Gửi khiếu nại',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_resultMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _resultMessage!,
                              style: const TextStyle(color: Colors.green),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Colors.redAccent.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Colors.redAccent, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.redAccent),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
