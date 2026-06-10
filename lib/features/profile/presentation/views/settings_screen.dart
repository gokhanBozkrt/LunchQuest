import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_button.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _deptCtrl;
  late final TextEditingController _phoneCtrl;
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  bool _passVisible = false;
  bool _passConfirmVisible = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<HomeViewModel>();
    _nameCtrl = TextEditingController(text: vm.user.fullName);
    _deptCtrl = TextEditingController(text: vm.user.dept);
    _phoneCtrl = TextEditingController(text: vm.user.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _deptCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final vm = context.read<HomeViewModel>();
    vm.updateProfile(
      fullName: _nameCtrl.text.trim(),
      dept: _deptCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
    );
    setState(() => _saved = true);
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) context.pop();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Değişiklikler kaydedildi ✓')),
    );
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
              LqScreenHeader(
                title: 'Ayarlar',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Profil bilgileri ─────────────────
                      _Section('Profil Bilgileri'),
                      const SizedBox(height: AppSpacing.md),

                      _FieldLabel('Ad Soyad'),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _nameCtrl,
                        style: AppTextStyles.body,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          hintText: 'Ad Soyad',
                          prefixIcon: Icon(Icons.person_outline_rounded,
                              color: AppColors.ink3),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _FieldLabel('Departman'),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _deptCtrl,
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText: 'Departman',
                          prefixIcon: Icon(Icons.business_outlined,
                              color: AppColors.ink3),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // ── İletişim ─────────────────────────
                      _Section('İletişim'),
                      const SizedBox(height: AppSpacing.md),

                      _FieldLabel('Telefon Numarası'),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9 +\-()]')),
                        ],
                        style: AppTextStyles.body,
                        decoration: const InputDecoration(
                          hintText: '+90 5__ ___ __ __',
                          prefixIcon: Icon(Icons.phone_outlined,
                              color: AppColors.ink3),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // ── Şifre ────────────────────────────
                      _Section('Şifre Güncelle'),
                      const SizedBox(height: AppSpacing.md),

                      _FieldLabel('Yeni Şifre'),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _passCtrl,
                        obscureText: !_passVisible,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppColors.ink3),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                                () => _passVisible = !_passVisible),
                            child: Icon(
                              _passVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.ink3,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      _FieldLabel('Şifre Tekrar'),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _passConfirmCtrl,
                        obscureText: !_passConfirmVisible,
                        style: AppTextStyles.body,
                        decoration: InputDecoration(
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              color: AppColors.ink3),
                          suffixIcon: GestureDetector(
                            onTap: () => setState(
                                () => _passConfirmVisible = !_passConfirmVisible),
                            child: Icon(
                              _passConfirmVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.ink3,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'En az 8 karakter, 1 büyük harf ve 1 rakam içermeli',
                        style:
                            AppTextStyles.xs.copyWith(color: AppColors.ink3),
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // ── Face ID ──────────────────────────
                      _Section('Biyometrik Kimlik'),
                      const SizedBox(height: AppSpacing.md),
                      _SettingsRow(
                        icon: Icons.face_retouching_natural_rounded,
                        title: 'Face ID',
                        subtitle: 'Kayıtlı · Son kullanım: Bugün',
                        trailing: TextButton(
                          onPressed: () {},
                          child: Text('Yeniden Kaydet',
                              style: AppTextStyles.smallMedium
                                  .copyWith(color: AppColors.coral)),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxxl),

                      // ── Tehlikeli bölge ──────────────────
                      _Section('Hesap'),
                      const SizedBox(height: AppSpacing.md),
                      _SettingsRow(
                        icon: Icons.logout_rounded,
                        iconColor: AppColors.coral,
                        title: 'Çıkış Yap',
                        subtitle: 'Oturumu kapat',
                        onTap: () => context.go('/login'),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
            child: LqButton(
              label: _saved ? 'Kaydedildi ✓' : 'Değişiklikleri Kaydet',
              variant:
                  _saved ? LqButtonVariant.joined : LqButtonVariant.coral,
              fullWidth: true,
              onPressed: _save,
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  const _Section(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: AppTextStyles.h3);
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.xsSemiBold.copyWith(color: AppColors.ink2));
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    this.iconColor = AppColors.coral,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.smallSemiBold),
                  Text(subtitle,
                      style:
                          AppTextStyles.xs.copyWith(color: AppColors.ink2)),
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.ink3),
          ],
        ),
      ),
    );
  }
}
