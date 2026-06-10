import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cards/event_card.dart';
import '../../../../core/widgets/shared/lq_avatar.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../../../core/widgets/shared/lq_status_badge.dart';
import '../../../onboarding/presentation/views/splash_screen.dart';
import '../viewmodels/home_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final events = vm.activeEvents;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Top bar ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Merhaba, ${vm.user.name}! 👋',
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.ink2),
                        ),
                        const SizedBox(height: 2),
                        LqXpBadge(xp: vm.xp),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          LqAvatar(
                            initials: vm.user.initials,
                            color: Color(vm.user.color),
                            size: AppDimensions.avatarLG,
                          ),
                          Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.coral,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: AppColors.card, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '${vm.user.level}',
                                style: AppTextStyles.levelBadge,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Quick Actions ────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.restaurant_rounded,
                        title: 'Lunch Quest',
                        subtitle: 'Başlat',
                        color: AppColors.coral,
                        onTap: () => context.push('/create'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        title: 'Etkinlik Oluştur',
                        subtitle: 'Hızlı başlat',
                        color: AppColors.navy,
                        onTap: () => context.push('/coffee'),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Active Events ────────────────────────────
            SliverToBoxAdapter(
              child: LqSectionHeader(
                title: 'Aktif Etkinlikler',
                actionLabel: 'Tümünü gör',
                onAction: () => context.go('/events'),
              ),
            ),

            SliverToBoxAdapter(
              child: SizedBox(
                height: 188,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  itemCount: events.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: AppSpacing.md),
                  itemBuilder: (_, i) {
                    final ev = events[i];
                    return EventCardCompact(
                      event: ev,
                      joined: vm.isJoined(ev.id),
                      onOpen: () {
                        vm.setCurrentEvent(ev.id);
                        context.push('/detail');
                      },
                      onJoin: () => vm.join(ev.id),
                    );
                  },
                ),
              ),
            ),

            // ── AI Banner ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                    AppSpacing.xxl, AppSpacing.lg, 0),
                child: _AiBanner(onTap: () => context.go('/ai')),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl)),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: color,
          borderRadius: AppRadius.lgAll,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: AppRadius.smAll,
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTextStyles.smallSemiBold.copyWith(
                        color: AppColors.onCoral)),
                Text(subtitle,
                    style: AppTextStyles.xs.copyWith(
                        color: Colors.white.withValues(alpha: 0.7))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AiBanner extends StatelessWidget {
  final VoidCallback onTap;
  const _AiBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.violetTint,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
              color: AppColors.violet.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.violet,
                borderRadius: AppRadius.mdAll,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI bugün ne öneriyor?',
                      style: AppTextStyles.smallSemiBold
                          .copyWith(color: AppColors.violet)),
                  const SizedBox(height: 2),
                  Text(
                    'Geçmiş tercihlerine göre 3 restoran',
                    style:
                        AppTextStyles.xs.copyWith(color: AppColors.ink2),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.violet, size: 20),
          ],
        ),
      ),
    );
  }
}
