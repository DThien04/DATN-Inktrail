import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/widgets/app_field_label.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/reset_password_usecase.dart';
import '../../domain/usecases/verify_reset_otp_usecase.dart';

class ForgotPasswordFinalPage extends StatefulWidget {
  const ForgotPasswordFinalPage({super.key});

  @override
  State<ForgotPasswordFinalPage> createState() =>
      _ForgotPasswordFinalPageState();
}

class _ForgotPasswordFinalPageState extends State<ForgotPasswordFinalPage> {
  static const int _resendCooldownSeconds = 30;

  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  late final ForgotPasswordUsecase _forgotPassword;
  late final VerifyResetOtpUsecase _verifyResetOtp;
  late final ResetPasswordUsecase _resetPassword;

  int _step = 1;
  bool _isSendingOtp = false;
  bool _isVerifyingOtp = false;
  bool _isResettingPassword = false;
  int _resendCountdown = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _forgotPassword = sl<ForgotPasswordUsecase>();
    _verifyResetOtp = sl<VerifyResetOtpUsecase>();
    _resetPassword = sl<ResetPasswordUsecase>();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendCountdown = _resendCooldownSeconds);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendCountdown <= 1) {
        timer.cancel();
        setState(() => _resendCountdown = 0);
        return;
      }
      setState(() => _resendCountdown -= 1);
    });
  }

  Future<void> _goToOtpVerification() async {
    FocusScope.of(context).unfocus();
    if (!_emailFormKey.currentState!.validate()) return;

    setState(() => _isSendingOtp = true);
    try {
      final message = await _forgotPassword(email: _emailCtrl.text.trim());
      if (!mounted) return;
      _startResendCooldown();
      setState(() => _step = 2);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _goToResetPassword() async {
    FocusScope.of(context).unfocus();
    if (!_otpFormKey.currentState!.validate()) return;

    setState(() => _isVerifyingOtp = true);
    try {
      final message = await _verifyResetOtp(
        email: _emailCtrl.text.trim(),
        otp: _otpCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _step = 3);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isVerifyingOtp = false);
    }
  }

  Future<void> _resendOtp() async {
    if (_resendCountdown > 0 || _isSendingOtp) return;
    setState(() => _isSendingOtp = true);
    try {
      final message = await _forgotPassword(email: _emailCtrl.text.trim());
      if (!mounted) return;
      _startResendCooldown();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSendingOtp = false);
    }
  }

  Future<void> _submitReset() async {
    FocusScope.of(context).unfocus();
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _isResettingPassword = true);
    try {
      final message = await _resetPassword(
        email: _emailCtrl.text.trim(),
        otp: _otpCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _isResettingPassword = false);
    }
  }

  String _bottomHint() {
    switch (_step) {
      case 1:
        return 'Nhập email đã đăng ký. Hệ thống sẽ gửi mã OTP đặt lại mật khẩu cho bạn.';
      case 2:
        return 'Kiểm tra hộp thư đến hoặc spam rồi nhập mã OTP gồm 6 số để tiếp tục.';
      default:
        return 'Sau khi OTP hợp lệ, bạn có thể đặt mật khẩu mới cho tài khoản InkTrail.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          'Quên mật khẩu',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: scheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StepIndicator(currentStep: _step),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: scheme.outlineVariant,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF7A4A21).withValues(alpha: 0.045),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeIn,
                  child: switch (_step) {
                    1 => _SendOtpStep(
                        key: const ValueKey('send-otp-step'),
                        formKey: _emailFormKey,
                        emailCtrl: _emailCtrl,
                        isLoading: _isSendingOtp,
                        onSubmit: _goToOtpVerification,
                      ),
                    2 => _VerifyOtpStep(
                        key: const ValueKey('verify-otp-step'),
                        formKey: _otpFormKey,
                        email: _emailCtrl.text.trim(),
                        otpCtrl: _otpCtrl,
                        isLoading: _isVerifyingOtp,
                        resendLoading: _isSendingOtp,
                        resendCountdown: _resendCountdown,
                        onBack: () => setState(() => _step = 1),
                        onResend: _resendOtp,
                        onSubmit: _goToResetPassword,
                      ),
                    _ => _ResetPasswordStep(
                        key: const ValueKey('reset-password-step'),
                        formKey: _resetFormKey,
                        email: _emailCtrl.text.trim(),
                        passwordCtrl: _passwordCtrl,
                        confirmCtrl: _confirmCtrl,
                        isLoading: _isResettingPassword,
                        onBack: () => setState(() => _step = 2),
                        onSubmit: _submitReset,
                      ),
                  },
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _bottomHint(),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StepBubble(
            index: 1,
            icon: Icons.mail_outline_rounded,
            active: currentStep == 1,
            done: currentStep > 1,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StepBubble(
            index: 2,
            icon: Icons.verified_user_outlined,
            active: currentStep == 2,
            done: currentStep > 2,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StepBubble(
            index: 3,
            icon: Icons.lock_reset_rounded,
            active: currentStep == 3,
            done: false,
          ),
        ),
      ],
    );
  }
}

class _StepBubble extends StatelessWidget {
  const _StepBubble({
    required this.index,
    required this.icon,
    required this.active,
    required this.done,
  });

  final int index;
  final IconData icon;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = active
        ? const Color(0xFFD48843)
        : done
            ? (isDark ? scheme.surfaceContainerHighest : const Color(0xFFF7ECDF))
            : (isDark ? scheme.surface : const Color(0xFFFFFCF8));
    final borderColor = active
        ? const Color(0xFFD48843)
        : (isDark ? scheme.outlineVariant : const Color(0xFFEEE2D4));
    final contentColor = active ? Colors.white : (isDark ? scheme.onSurface : const Color(0xFF6B5545));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active
                  ? Colors.white.withValues(alpha: 0.16)
                  : (isDark ? scheme.surfaceContainerHighest : const Color(0xFFF8F1E9)),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: contentColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(icon, size: 18, color: contentColor),
        ],
      ),
    );
  }
}

class _SendOtpStep extends StatelessWidget {
  const _SendOtpStep({
    super.key,
    required this.formKey,
    required this.emailCtrl,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailCtrl;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _CardHeading(
              icon: Icons.mail_outline_rounded,
              title: 'Nhận mã xác thực',
              subtitle:
                  'Chúng tôi sẽ gửi một mã OTP gồm 6 số về email của bạn.',
            ),
            const SizedBox(height: 22),
            AppFieldLabel(
              label: 'Email',
              hint: 'example@email.com',
              controller: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                final email = value?.trim() ?? '';
                if (email.isEmpty) return 'Vui lòng nhập email';
                if (!email.contains('@')) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFC97A35),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Gửi mã OTP',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifyOtpStep extends StatelessWidget {
  const _VerifyOtpStep({
    super.key,
    required this.formKey,
    required this.email,
    required this.otpCtrl,
    required this.isLoading,
    required this.resendLoading,
    required this.resendCountdown,
    required this.onBack,
    required this.onResend,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String email;
  final TextEditingController otpCtrl;
  final bool isLoading;
  final bool resendLoading;
  final int resendCountdown;
  final VoidCallback onBack;
  final VoidCallback onResend;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardHeading(
              icon: Icons.verified_user_outlined,
              title: 'Xác thực OTP',
              subtitle: 'Mã xác thực đã được gửi đến $email',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: scheme.outlineVariant),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: Color(0xFFC97A35),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'OTP có hiệu lực trong 10 phút. Nếu chưa thấy mail, hãy kiểm tra cả mục spam.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.45,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            AppFieldLabel(
              label: 'Mã OTP',
              hint: '123456',
              controller: otpCtrl,
              keyboardType: TextInputType.number,
              validator: (value) {
                final otp = value?.trim() ?? '';
                if (otp.isEmpty) return 'Vui lòng nhập mã OTP';
                if (otp.length < 6) return 'OTP gồm 6 số';
                return null;
              },
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed:
                    (resendCountdown > 0 || resendLoading) ? null : onResend,
                child: resendLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        resendCountdown > 0
                            ? 'Gửi lại OTP sau ${resendCountdown}s'
                            : 'Gửi lại OTP',
                      ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                      side: BorderSide(color: scheme.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Đổi email',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC97A35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Xác thực mã OTP',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ResetPasswordStep extends StatelessWidget {
  const _ResetPasswordStep({
    super.key,
    required this.formKey,
    required this.email,
    required this.passwordCtrl,
    required this.confirmCtrl,
    required this.isLoading,
    required this.onBack,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final String email;
  final TextEditingController passwordCtrl;
  final TextEditingController confirmCtrl;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _CardHeading(
              icon: Icons.lock_reset_rounded,
              title: 'Đặt lại mật khẩu',
              subtitle: 'Tạo mật khẩu mới cho tài khoản $email',
            ),
            const SizedBox(height: 18),
            AppFieldLabel(
              label: 'Mật khẩu mới',
              hint: '••••••••',
              controller: passwordCtrl,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới';
                }
                if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
                return null;
              },
            ),
            const SizedBox(height: 14),
            AppFieldLabel(
              label: 'Xác nhận mật khẩu',
              hint: '••••••••',
              controller: confirmCtrl,
              isPassword: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu';
                }
                if (value != passwordCtrl.text) {
                  return 'Mật khẩu xác nhận không khớp';
                }
                return null;
              },
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF6B5545),
                      side: const BorderSide(color: Color(0xFFE3D6C8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: const Text(
                      'Quay lại OTP',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC97A35),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Xác nhận mật khẩu mới',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardHeading extends StatelessWidget {
  const _CardHeading({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFFC97A35)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
