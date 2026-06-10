import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_button.dart';
import 'splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _passVisible = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() { _loading = true; _errorMessage = null; });

    try {
      await AuthService.instance.signInWithEmail(
        email: _emailCtrl.text,
        password: _passCtrl.text,
      );
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'E-posta veya şifre hatalı';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: AppSpacing.xxl,
              right: AppSpacing.xxl,
              top: AppSpacing.xxl,
              bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  const Center(child: LqLogo(size: 72, light: false)),
                  const SizedBox(height: AppSpacing.xl),
                  Center(
                    child: Text('Lunch Quest',
                        style: AppTextStyles.h1
                            .copyWith(color: AppColors.coral)),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text('Ekibinle ye, eğlen, kazan!',
                        style: AppTextStyles.small
                            .copyWith(color: AppColors.ink2)),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // E-posta
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
                      if (!v.contains('@')) return 'Geçerli e-posta girin';
                      return null;
                    },
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Şifre
                  _Label('Şifre'),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: !_passVisible,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    style: AppTextStyles.body,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline_rounded,
                          color: AppColors.ink3, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.ink3,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _passVisible = !_passVisible),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Şifre gerekli';
                      if (v.length < 6) return 'En az 6 karakter';
                      return null;
                    },
                  ),

                  // Hata mesajı
                  if (_errorMessage != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.coralTint,
                        borderRadius: AppRadius.smAll,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 16, color: AppColors.coral),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(_errorMessage!,
                                style: AppTextStyles.xs
                                    .copyWith(color: AppColors.coral)),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),

                  // Şifremi unuttum
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Şifremi unuttum',
                          style: AppTextStyles.smallMedium
                              .copyWith(color: AppColors.coral)),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Giriş butonu
                  LqButton(
                    label: 'Giriş Yap',
                    variant: LqButtonVariant.coral,
                    fullWidth: true,
                    isLoading: _loading,
                    onPressed: _loading ? null : _login,
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Ayırıcı
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md),
                        child: Text('veya',
                            style: AppTextStyles.xs
                                .copyWith(color: AppColors.ink3)),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Kayıt ol
                  LqButton(
                    label: 'Hesap Oluştur',
                    variant: LqButtonVariant.ghost,
                    fullWidth: true,
                    onPressed: () => context.push('/register'),
                  ),

                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
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
      style: AppTextStyles.smallSemiBold.copyWith(color: AppColors.ink2));
}
