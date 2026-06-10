import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../shared/lq_avatar.dart';
import '../shared/lq_status_badge.dart';
import '../../../features/home/domain/entities/restaurant.dart';

/// Compact horizontal card — used in Home screen horizontal scroller
class EventCardCompact extends StatelessWidget {
  final LunchEvent event;
  final bool joined;
  final VoidCallback? onOpen;
  final VoidCallback? onJoin;

  const EventCardCompact({
    super.key,
    required this.event,
    this.joined = false,
    this.onOpen,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final isCoffee = event.type == EventType.coffee;
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        width: 270,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadowSm,
                blurRadius: 14,
                offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Type badge + time
            Row(
              children: [
                LqEventTypeBadge(type: event.type),
                const Spacer(),
                const Icon(Icons.access_time_rounded,
                    size: 13, color: AppColors.ink3),
                const SizedBox(width: 3),
                Text(event.time, style: AppTextStyles.xsMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Title
            Text(event.title,
                style: AppTextStyles.h3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),

            // Place
            Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppColors.ink3),
              const SizedBox(width: 3),
              Expanded(
                child: Text(event.place,
                    style: AppTextStyles.xs,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ]),

            const Spacer(),

            // Footer — avatars + join button
            Row(
              children: [
                LqAvatarStack(
                    memberIds: event.memberIds, max: 3, size: 28),
                const SizedBox(width: 6),
                Text('${event.memberIds.length} kişi',
                    style: AppTextStyles.xsMedium),
                const Spacer(),
                _JoinButton(joined: joined, onJoin: onJoin),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinButton extends StatelessWidget {
  final bool joined;
  final VoidCallback? onJoin;
  const _JoinButton({required this.joined, this.onJoin});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: joined ? null : onJoin,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: joined ? AppColors.greenTint : AppColors.coral,
          borderRadius: AppRadius.pillAll,
        ),
        child: joined
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.check_rounded,
                    size: 13, color: AppColors.green),
                const SizedBox(width: 4),
                Text('Katıldın',
                    style: AppTextStyles.xsSemiBold
                        .copyWith(color: AppColors.green)),
              ])
            : Text('Katıl',
                style: AppTextStyles.xsSemiBold
                    .copyWith(color: AppColors.onCoral)),
      ),
    );
  }
}

/// Full-width list row — used in Events screen
class EventCardList extends StatelessWidget {
  final LunchEvent event;
  final bool joined;
  final VoidCallback? onOpen;

  const EventCardList({
    super.key,
    required this.event,
    this.joined = false,
    this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final isCoffee = event.type == EventType.coffee;
    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isCoffee ? AppColors.amberTint : AppColors.coralTint,
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(
                isCoffee
                    ? Icons.coffee_rounded
                    : Icons.restaurant_rounded,
                color: isCoffee ? AppColors.amber : AppColors.coral,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Body
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Text(event.title,
                          style: AppTextStyles.smallSemiBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    LqStatusBadge(status: event.status),
                  ]),
                  const SizedBox(height: 3),
                  Text(
                    '${event.organizer} oluşturdu · ${event.place}',
                    style: AppTextStyles.xs,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.access_time_rounded,
                        size: 12, color: AppColors.ink3),
                    const SizedBox(width: 3),
                    Text(event.time, style: AppTextStyles.xs),
                    const SizedBox(width: 10),
                    const Icon(Icons.people_outline_rounded,
                        size: 12, color: AppColors.ink3),
                    const SizedBox(width: 3),
                    Text('${event.memberIds.length} kişi',
                        style: AppTextStyles.xs),
                    if (joined) ...[
                      const SizedBox(width: 10),
                      const Icon(Icons.check_rounded,
                          size: 12, color: AppColors.green),
                      const SizedBox(width: 3),
                      Text('Katıldın',
                          style: AppTextStyles.xs
                              .copyWith(color: AppColors.green)),
                    ],
                  ]),
                ],
              ),
            ),

            const Icon(Icons.chevron_right_rounded,
                color: AppColors.ink3, size: 20),
          ],
        ),
      ),
    );
  }
}
