import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../domain/entities/restaurant.dart';
import '../viewmodels/home_viewmodel.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Ekran açılınca hepsini okundu işaretle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().markAllRead();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final notifs = vm.notifications;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            LqScreenHeader(
              title: 'Bildirimler',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: notifs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications_off_outlined,
                              size: 56, color: AppColors.ink3),
                          const SizedBox(height: AppSpacing.lg),
                          Text('Henüz bildirim yok',
                              style: AppTextStyles.body
                                  .copyWith(color: AppColors.ink2)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: notifs.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (_, i) =>
                          _NotifCard(notif: notifs[i], onTap: () {
                            if (notifs[i].eventId != null) {
                              vm.setCurrentEvent(notifs[i].eventId!);
                              context.push('/detail');
                            }
                          }),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;

  const _NotifCard({required this.notif, required this.onTap});

  static const _icons = {
    NotificationType.eventEnd: Icons.flag_rounded,
    NotificationType.newEvent: Icons.event_available_rounded,
    NotificationType.vote: Icons.how_to_vote_rounded,
    NotificationType.system: Icons.info_rounded,
  };
  static const _colors = {
    NotificationType.eventEnd: AppColors.amber,
    NotificationType.newEvent: AppColors.coral,
    NotificationType.vote: AppColors.violet,
    NotificationType.system: AppColors.ink2,
  };

  @override
  Widget build(BuildContext context) {
    final ic = _icons[notif.type]!;
    final cl = _colors[notif.type]!;
    final unread = !notif.isRead;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: unread
              ? cl.withValues(alpha: 0.05)
              : AppColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: unread
                ? cl.withValues(alpha: 0.3)
                : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cl.withValues(alpha: 0.12),
                borderRadius: AppRadius.mdAll,
              ),
              child: Icon(ic, size: 22, color: cl),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(notif.title,
                            style: AppTextStyles.smallSemiBold),
                      ),
                      if (unread)
                        Container(
                          width: 8, height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(notif.body,
                      style: AppTextStyles.small
                          .copyWith(color: AppColors.ink2)),
                  const SizedBox(height: 6),
                  Text(
                    _timeAgo(notif.time),
                    style: AppTextStyles.xs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Az önce';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    return '${diff.inDays} gün önce';
  }
}
