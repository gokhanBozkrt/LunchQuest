import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

enum _ScanState { idle, scanning, ok }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  _ScanState _state = _ScanState.idle;
  late final AnimationController _ringCtrl;
  late final Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _ringAnim = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _ringCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    super.dispose();
  }

  void _scan() {
    if (_state != _ScanState.idle) return;
    setState(() => _state = _ScanState.scanning);
    _ringCtrl.repeat(reverse: true);

    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      _ringCtrl.stop();
      setState(() => _state = _ScanState.ok);
    });
    Future.delayed(const Duration(milliseconds: 1850), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.card,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Brand placeholder
              Container(
                height: 40,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: AppRadius.smAll,
                  border: Border.all(color: AppColors.border),
                ),
                alignment: Alignment.center,
                child: Text('ŞİRKET',
                    style: AppTextStyles.h3.copyWith(
                      letterSpacing: 4,
                      color: AppColors.ink2,
                    )),
              ),

              const Spacer(),

              // Face ID button
              GestureDetector(
                onTap: _scan,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _ringAnim,
                      builder: (_, __) => Transform.scale(
                        scale: _state == _ScanState.scanning
                            ? _ringAnim.value
                            : 1.0,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _state == _ScanState.ok
                                ? AppColors.greenTint
                                : AppColors.bg,
                            border: Border.all(
                              color: _state == _ScanState.ok
                                  ? AppColors.green
                                  : _state == _ScanState.scanning
                                      ? AppColors.coral
                                      : AppColors.border,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _state == _ScanState.ok
                                ? Icons.check_rounded
                                : Icons.face_retouching_natural_rounded,
                            size: 56,
                            color: _state == _ScanState.ok
                                ? AppColors.green
                                : _state == _ScanState.scanning
                                    ? AppColors.coral
                                    : AppColors.ink2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      _state == _ScanState.ok
                          ? 'Hoş geldin, Ada!'
                          : 'Kimliğini doğrula',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _state == _ScanState.idle
                          ? 'Devam etmek için Face ID kullan'
                          : _state == _ScanState.scanning
                              ? 'Yüzün taranıyor…'
                              : 'Giriş başarılı',
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.ink2,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // PIN link
              TextButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.lock_outline_rounded,
                    size: 16, color: AppColors.ink3),
                label: Text('PIN ile giriş',
                    style: AppTextStyles.small
                        .copyWith(color: AppColors.ink3)),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
