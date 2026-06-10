import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

class LqSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const LqSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg, AppSpacing.xxl, AppSpacing.lg, AppSpacing.md),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.h3),
          const Spacer(),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.smallMedium
                    .copyWith(color: AppColors.coral),
              ),
            ),
        ],
      ),
    );
  }
}

class LqScreenHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBack;
  final Widget? right;

  const LqScreenHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onBack,
    this.right,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Row(
          children: [
            if (onBack != null)
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.chevron_left_rounded,
                      color: AppColors.ink, size: 24),
                ),
              )
            else
              const SizedBox(width: 40),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: AppTextStyles.h3, textAlign: TextAlign.center),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: AppTextStyles.xs, textAlign: TextAlign.center),
                ],
              ),
            ),
            SizedBox(width: 40, child: right),
          ],
        ),
      ),
    );
  }
}
