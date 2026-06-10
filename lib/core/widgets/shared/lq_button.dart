import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';

enum LqButtonVariant { coral, navy, ghost, joined, onLight }

class LqButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final LqButtonVariant variant;
  final bool fullWidth;
  final bool disabled;
  final IconData? icon;
  final IconData? iconRight;
  final bool isLoading;

  const LqButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = LqButtonVariant.coral,
    this.fullWidth = false,
    this.disabled = false,
    this.icon,
    this.iconRight,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, shadow) = _colors;

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: AppDimensions.btnHeight,
      child: Material(
        color: disabled ? const Color(0xFFD1CEC8) : bg,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: disabled ? null : onPressed,
          borderRadius: AppRadius.smAll,
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              boxShadow: shadow,
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(fg)),
                  )
                : Row(
                    mainAxisSize:
                        fullWidth ? MainAxisSize.max : MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Color(fg), size: 19),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTextStyles.btnLabel
                            .copyWith(color: Color(fg)),
                      ),
                      if (iconRight != null) ...[
                        const SizedBox(width: 8),
                        Icon(iconRight, color: Color(fg), size: 19),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  (Color, int, List<BoxShadow>?) get _colors => switch (variant) {
        LqButtonVariant.coral => (
            AppColors.coral,
            AppColors.onCoral.value,
            [
              BoxShadow(
                color: AppColors.shadowCoral,
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ]
          ),
        LqButtonVariant.navy => (
            AppColors.navy,
            AppColors.onNavy.value,
            [
              BoxShadow(
                color: AppColors.shadowNavy,
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ]
          ),
        LqButtonVariant.joined => (
            AppColors.greenTint,
            AppColors.green.value,
            null,
          ),
        LqButtonVariant.onLight => (
            AppColors.card,
            AppColors.coral.value,
            null,
          ),
        LqButtonVariant.ghost => (
            Colors.transparent,
            AppColors.coral.value,
            null,
          ),
      };
}
