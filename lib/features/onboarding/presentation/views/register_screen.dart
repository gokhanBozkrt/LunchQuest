import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passVisible = false;
  bool _passConfirmVisible = false;
  bool _loading = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);

    try {
      await AuthService.instance.signUpWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
        fullName: '${_firstCtrl.text.trim()} ${_lastCtrl.text.trim()}',
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarısız: ${e.toString()}')),
      );
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              // Üst bar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: AppRadius.smAll,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(Icons.chevron_left_rounded,
                            color: AppColors.ink),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text('Hesap Oluştur', style: AppTextStyles.h2),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: AppSpacing.xl,
                    right: AppSpacing.xl,
                    top: AppSpacing.lg,
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        AppSpacing.xxl,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Ad / Soyad ──────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Label('Ad'),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextFormField(
                                    controller: _firstCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    style: AppTextStyles.body,
                                    decoration: const InputDecoration(
                                        hintText: 'Adınız'),
                                    validator: (v) =>
                                        (v?.trim().isEmpty ?? true)
                                            ? 'Gerekli'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _Label('Soyad'),
                                  const SizedBox(height: AppSpacing.sm),
                                  TextFormField(
                                    controller: _lastCtrl,
                                    textCapitalization:
                                        TextCapitalization.words,
                                    textInputAction: TextInputAction.next,
                                    style: AppTextStyles.body,
                                    decoration: const InputDecoration(
                                        hintText: 'Soyadınız'),
                                    validator: (v) =>
                                        (v?.trim().isEmpty ?? true)
                                            ? 'Gerekli'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Telefon ─────────────────────────
                        _Label('Telefon Numarası'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9 +\-()]')),
                          ],
                          style: AppTextStyles.body,
                          decoration: const InputDecoration(
                            hintText: '+90 5__ ___ __ __',
                            prefixIcon: Icon(Icons.phone_outlined,
                                color: AppColors.ink3, size: 20),
                          ),
                          validator: (v) {
                            if (v == null ||
                                v.replaceAll(RegExp(r'\D'), '').length < 10) {
                              return 'Geçerli telefon numarası girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── E-posta ─────────────────────────
                        _Label('E-posta'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          style: AppTextStyles.body,
                          decoration: const InputDecoration(
                            hintText: 'ornek@sirket.com',
                            prefixIcon: Icon(Icons.mail_outline_rounded,
                                color: AppColors.ink3, size: 20),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'E-posta gerekli';
                            }
                            if (!v.contains('@')) {
                              return 'Geçerli e-posta girin';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Şifre ───────────────────────────
                        _Label('Şifre'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _passCtrl,
                          obscureText: !_passVisible,
                          textInputAction: TextInputAction.next,
                          style: AppTextStyles.body,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.ink3, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.ink3, size: 20,
                              ),
                              onPressed: () => setState(
                                  () => _passVisible = !_passVisible),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Şifre gerekli';
                            }
                            if (v.length < 8) return 'En az 8 karakter';
                            if (!v.contains(RegExp(r'[A-Z]'))) {
                              return 'En az 1 büyük harf';
                            }
                            if (!v.contains(RegExp(r'[0-9]'))) {
                              return 'En az 1 rakam';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSpacing.lg),

                        // ── Şifre tekrar ────────────────────
                        _Label('Şifre Tekrar'),
                        const SizedBox(height: AppSpacing.sm),
                        TextFormField(
                          controller: _passConfirmCtrl,
                          obscureText: !_passConfirmVisible,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _register(),
                          style: AppTextStyles.body,
                          decoration: InputDecoration(
                            hintText: '••••••••',
                            prefixIcon: const Icon(
                                Icons.lock_outline_rounded,
                                color: AppColors.ink3, size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _passConfirmVisible
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.ink3, size: 20,
                              ),
                              onPressed: () => setState(() =>
                                  _passConfirmVisible = !_passConfirmVisible),
                            ),
                          ),
                          validator: (v) {
                            if (v != _passCtrl.text) {
                              return 'Şifreler eşleşmiyor';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'En az 8 karakter, 1 büyük harf ve 1 rakam içermeli',
                          style: AppTextStyles.xs
                              .copyWith(color: AppColors.ink3),
                        ),

                        const SizedBox(height: AppSpacing.xxl),

                        // ── Kayıt ol butonu ──────────────────
                        LqButton(
                          label: 'Hesap Oluştur',
                          variant: LqButtonVariant.coral,
                          fullWidth: true,
                          isLoading: _loading,
                          onPressed: _loading ? null : _register,
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // Giriş yap linki
                        Center(
                          child: GestureDetector(
                            onTap: () => context.go('/login'),
                            child: RichText(
                              text: TextSpan(
                                text: 'Zaten hesabın var mı? ',
                                style: AppTextStyles.small
                                    .copyWith(color: AppColors.ink2),
                                children: [
                                  TextSpan(
                                    text: 'Giriş Yap',
                                    style: AppTextStyles.smallSemiBold
                                        .copyWith(color: AppColors.coral),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.xsSemiBold.copyWith(color: AppColors.ink2));
}
