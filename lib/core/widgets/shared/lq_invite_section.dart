import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../../../features/home/domain/entities/restaurant.dart';

class LqInviteSection extends StatelessWidget {
  final List<TeamMember> team;
  final Set<String> invited;
  final ValueChanged<String> onToggle;
  final VoidCallback? onSelectAll;

  const LqInviteSection({
    super.key,
    required this.team,
    required this.invited,
    required this.onToggle,
    this.onSelectAll,
  });

  bool get _allSelected => invited.length == team.length;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık + Tümünü seç
        Row(
          children: [
            Text(
              invited.isEmpty
                  ? 'Kimler davetli?'
                  : '${invited.length} kişi seçildi',
              style: AppTextStyles.smallSemiBold
                  .copyWith(color: AppColors.ink2),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onSelectAll ?? () {},
              child: Text(
                _allSelected ? 'Seçimi kaldır' : 'Tümünü seç',
                style: AppTextStyles.xsSemiBold
                    .copyWith(color: AppColors.coral),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Kişi grid'i
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: team.map((t) {
            final on = invited.contains(t.id);
            final memberColor = Color(t.color);
            return GestureDetector(
              onTap: () => onToggle(t.id),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: on
                      ? memberColor.withValues(alpha: 0.10)
                      : AppColors.card,
                  borderRadius: AppRadius.pillAll,
                  border: Border.all(
                    color: on
                        ? memberColor.withValues(alpha: 0.45)
                        : AppColors.border,
                    width: on ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mini avatar
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: on ? memberColor : AppColors.cardSunken,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        t.initials,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: on ? Colors.white : AppColors.ink3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      t.name,
                      style: AppTextStyles.smallSemiBold.copyWith(
                        color: on ? memberColor : AppColors.ink,
                      ),
                    ),
                    // Check işareti
                    AnimatedSize(
                      duration: const Duration(milliseconds: 150),
                      child: on
                          ? Padding(
                              padding:
                                  const EdgeInsets.only(left: 5),
                              child: Icon(Icons.check_rounded,
                                  size: 14, color: memberColor),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        // Hiç seçilmemişse uyarı
        if (invited.isEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.amberTint,
              borderRadius: AppRadius.smAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 13, color: AppColors.amber),
                const SizedBox(width: 6),
                Text(
                  'Kimseyi seçmezsen bildirim gönderilmez',
                  style: AppTextStyles.xs
                      .copyWith(color: AppColors.amber),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
