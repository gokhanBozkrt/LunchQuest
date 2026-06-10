import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_button.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';

enum _Step { form, faceId, done }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  _Step _step = _Step.form;

  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _scanning = false;
  bool _faceOk = false;

  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  bool get _formValid =>
      _firstCtrl.text.trim().isNotEmpty &&
      _lastCtrl.text.trim().isNotEmpty &&
      _phoneCtrl.text.trim().length >= 10;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _phoneCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _goToFaceId() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _step = _Step.faceId);
  }

  void _startScan() {
    if (_scanning || _faceOk) return;
    setState(() => _scanning = true);
    _pulseCtrl.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _pulseCtrl.stop();
      setState(() {
        _scanning = false;
        _faceOk = true;
        _step = _Step.done;
      });
    });
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      context.go('/home');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, anim) =>
              SlideTransition(
                position: Tween<Offset>(
                    begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
                child: FadeTransition(opacity: anim, child: child),
              ),
          child: switch (_step) {
            _Step.form => _FormStep(
                key: const ValueKey('form'),
                firstCtrl: _firstCtrl,
                lastCtrl: _lastCtrl,
                phoneCtrl: _phoneCtrl,
                formKey: _formKey,
                onNext: _goToFaceId,
                onLogin: () => context.go('/login'),
              ),
            _Step.faceId || _Step.done => _FaceIdStep(
                key: const ValueKey('faceid'),
                scanning: _scanning,
                done: _faceOk,
                pulseAnim: _pulseAnim,
                onTap: _startScan,
                firstName: _firstCtrl.text.trim(),
              ),
          },
        ),
      ),
    );
  }
}

// ── Adım 1 — Form ─────────────────────────────────────────

class _FormStep extends StatelessWidget {
  final TextEditingController firstCtrl, lastCtrl, phoneCtrl;
  final GlobalKey<FormState> formKey;
  final VoidCallback onNext, onLogin;

  const _FormStep({
    super.key,
    required this.firstCtrl,
    required this.lastCtrl,
    required this.phoneCtrl,
    required this.formKey,
    required this.onNext,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xxl,
          right: AppSpacing.xxl,
          top: AppSpacing.xxl,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Geri butonu
                GestureDetector(
                  onTap: onLogin,
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
                const SizedBox(height: AppSpacing.xxl),

                Text('Hesap Oluştur', style: AppTextStyles.h1),
                const SizedBox(height: AppSpacing.sm),
                Text('Ekibine katılmak için bilgilerini gir',
                    style: AppTextStyles.small.copyWith(
                        color: AppColors.ink2)),

                const SizedBox(height: AppSpacing.xxxl),

                // Ad
                _Label('Ad'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: firstCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Adınız',
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: AppColors.ink3),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Ad gerekli' : null,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Soyad
                _Label('Soyad'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: lastCtrl,
                  textCapitalization: TextCapitalization.words,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(
                    hintText: 'Soyadınız',
                    prefixIcon: Icon(Icons.person_outline_rounded,
                        color: AppColors.ink3),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? 'Soyad gerekli' : null,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Telefon
                _Label('Telefon Numarası'),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: phoneCtrl,
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
                  validator: (v) {
                    if (v == null || v.replaceAll(RegExp(r'\D'), '').length < 10) {
                      return 'Geçerli bir telefon numarası girin';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                // İleri butonu
                LqButton(
                  label: 'İleri — Face ID Kaydı',
                  variant: LqButtonVariant.coral,
                  fullWidth: true,
                  iconRight: Icons.arrow_forward_rounded,
                  onPressed: onNext,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Giriş linki
                Center(
                  child: GestureDetector(
                    onTap: onLogin,
                    child: RichText(
                      text: TextSpan(
                        text: 'Zaten hesabın var mı? ',
                        style: AppTextStyles.small.copyWith(
                            color: AppColors.ink2),
                        children: [
                          TextSpan(
                            text: 'Giriş yap',
                            style: AppTextStyles.smallSemiBold
                                .copyWith(color: AppColors.coral),
                          ),
                        ],
                      ),
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
}

// ── Adım 2 — Face ID ──────────────────────────────────────

class _FaceIdStep extends StatelessWidget {
  final bool scanning, done;
  final Animation<double> pulseAnim;
  final VoidCallback onTap;
  final String firstName;

  const _FaceIdStep({
    super.key,
    required this.scanning,
    required this.done,
    required this.pulseAnim,
    required this.onTap,
    required this.firstName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        children: [
          const Spacer(),

          // Icon
          AnimatedBuilder(
            animation: pulseAnim,
            builder: (_, __) => Transform.scale(
              scale: scanning ? pulseAnim.value : 1.0,
              child: GestureDetector(
                onTap: onTap,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.greenTint
                        : AppColors.bg,
                    border: Border.all(
                      color: done
                          ? AppColors.green
                          : scanning
                              ? AppColors.coral
                              : AppColors.border,
                      width: 2.5,
                    ),
                    boxShadow: (scanning || done)
                        ? [
                            BoxShadow(
                              color: done
                                  ? AppColors.green.withValues(alpha: 0.25)
                                  : AppColors.coral.withValues(alpha: 0.3),
                              blurRadius: 32,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(
                    done
                        ? Icons.check_rounded
                        : Icons.face_retouching_natural_rounded,
                    size: 64,
                    color: done
                        ? AppColors.green
                        : scanning
                            ? AppColors.coral
                            : AppColors.ink3,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxxl),

          Text(
            done ? 'Hoş geldin, $firstName!' : 'Face ID Kaydı',
            style: AppTextStyles.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            done
                ? 'Yüzün kaydedildi. Giriş yapılıyor…'
                : scanning
                    ? 'Yüzün taranıyor…'
                    : 'Ekrana dokun ve yüzünü kameraya yönelt',
            style: AppTextStyles.body.copyWith(color: AppColors.ink2),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          if (!done && !scanning)
            LqButton(
              label: 'Face ID ile Kayıt Ol',
              variant: LqButtonVariant.coral,
              fullWidth: true,
              icon: Icons.face_retouching_natural_rounded,
              onPressed: onTap,
            ),

          const SizedBox(height: AppSpacing.xl),
        ],
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
