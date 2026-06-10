import 'package:flutter/material.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../../features/home/domain/entities/restaurant.dart';

class LqEventTypeBadge extends StatelessWidget {
  final EventType type;

  const LqEventTypeBadge({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final isLunch = type == EventType.lunch;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isLunch ? AppColors.coralTint : AppColors.amberTint,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLunch ? Icons.restaurant_rounded : Icons.coffee_rounded,
            size: 12,
            color: isLunch ? AppColors.coral : AppColors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            isLunch ? 'Lunch Quest' : 'Coffee Break',
            style: AppTextStyles.xsSemiBold.copyWith(
              color: isLunch ? AppColors.coral : AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }
}

class LqStatusBadge extends StatelessWidget {
  final EventStatus status;

  const LqStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      EventStatus.active => ('Aktif', AppColors.statusActive),
      EventStatus.full   => ('Dolu', AppColors.statusFull),
      EventStatus.done   => ('Bitti', AppColors.statusDone),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(
        label,
        style: AppTextStyles.xsSemiBold.copyWith(color: color),
      ),
    );
  }
}

class LqXpBadge extends StatelessWidget {
  final int xp;
  final bool small;

  const LqXpBadge({super.key, required this.xp, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: small ? 8 : 10,
        vertical: small ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: AppColors.amberTint,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded,
              size: small ? 13 : 15, color: AppColors.amber),
          const SizedBox(width: 3),
          Text(
            '${xp.toLocaleString()} XP',
            style: AppTextStyles.xpBadge.copyWith(
              fontSize: small ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

extension IntFormat on int {
  String toLocaleString() {
    final str = toString();
    if (str.length <= 3) return str;
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}
