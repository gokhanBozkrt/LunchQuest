import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_button.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.coral,
      body: SafeArea(
        child: Stack(
          children: [
            // Deco circles
            Positioned(
              top: -60,
              right: -80,
              child: _DecoBubble(size: 280, opacity: 0.12),
            ),
            Positioned(
              bottom: 100,
              left: -100,
              child: _DecoBubble(size: 320, opacity: 0.08),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
              child: Column(
                children: [
                  const Spacer(),

                  // Logo + text
                  Column(
                    children: [
                      const LqLogo(size: 92, light: true),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        'Lunch Quest',
                        style: AppTextStyles.display.copyWith(
                          color: AppColors.onCoral,
                          fontSize: 38,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Ekibinle ye, eğlen, kazan!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white86,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // CTA
                  Column(
                    children: [
                      LqButton(
                        label: 'Başla',
                        variant: LqButtonVariant.onLight,
                        fullWidth: true,
                        iconRight: Icons.arrow_forward_rounded,
                        onPressed: () => context.go('/login'),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        "Devam ederek Kullanım Koşulları'nı kabul edersin",
                        style: AppTextStyles.xs.copyWith(
                          color: AppColors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LqLogo extends StatelessWidget {
  final double size;
  final bool light;

  const LqLogo({super.key, this.size = 76, this.light = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light ? AppColors.card : AppColors.coral,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: light
                ? AppColors.white18
                : AppColors.shadowCoral,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Center(
            child: Icon(
              Icons.restaurant_rounded,
              size: size * 0.46,
              color: light ? AppColors.coral : AppColors.onCoral,
            ),
          ),
          Positioned(
            right: size * 0.05,
            bottom: size * 0.05,
            child: Container(
              width: size * 0.38,
              height: size * 0.38,
              decoration: BoxDecoration(
                color: AppColors.amber,
                borderRadius: BorderRadius.circular(size * 0.12),
              ),
              child: Icon(
                Icons.bolt_rounded,
                size: size * 0.24,
                color: AppColors.card,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecoBubble extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecoBubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
      ),
    );
  }
}
