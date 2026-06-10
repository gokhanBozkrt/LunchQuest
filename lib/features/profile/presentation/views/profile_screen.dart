import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_avatar.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../../../core/widgets/shared/lq_status_badge.dart';
import '../../../home/data/datasources/restaurant_local_datasource.dart';
import '../../../home/domain/entities/restaurant.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final user = vm.user;
    final pct = ((vm.xp - 1000) / (user.xpNext - 1000)).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Text('Profil', style: AppTextStyles.h1),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppRadius.smAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.settings_outlined,
                          size: 20, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
            ),

            // Profile head
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    LqAvatar(
                      initials: user.initials,
                      color: Color(user.color),
                      size: AppDimensions.avatarXL,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(user.fullName, style: AppTextStyles.h2),
                    const SizedBox(height: 4),
                    Text(user.dept,
                        style: AppTextStyles.small
                            .copyWith(color: AppColors.ink2)),
                  ],
                ),
              ),
            ),

            // XP Level card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navy, AppColors.navy600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: AppRadius.lgAll,
                    boxShadow: const [
                      BoxShadow(
                          color: AppColors.shadowNavy,
                          blurRadius: 22,
                          offset: Offset(0, 8)),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Lv ${user.level}',
                                  style: AppTextStyles.h2.copyWith(
                                      color: AppColors.onNavy)),
                              LqXpBadge(xp: vm.xp, small: true),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            'Sonraki seviyeye\n${(user.xpNext - vm.xp).toLocaleString()} XP',
                            style: AppTextStyles.xs
                                .copyWith(color: AppColors.white60),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      ClipRRect(
                        borderRadius: AppRadius.pillAll,
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 8,
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Row(
                  children: [
                    Expanded(
                        child: _StatItem(
                            value: '${user.joined}',
                            label: 'Katıldığım')),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: _StatItem(
                            value: '${user.created}',
                            label: 'Oluşturduğum')),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: _StatItem(
                            value: user.favoriteRestaurant,
                            label: 'Favori',
                            small: true)),
                  ],
                ),
              ),
            ),

            // Activity feed
            const SliverToBoxAdapter(
              child: LqSectionHeader(title: 'Son Aktiviteler'),
            ),

            SliverPadding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _ActivityRow(
                      item: vm.activity[i]),
                  childCount: vm.activity.length,
                ),
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

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final bool small;

  const _StatItem(
      {required this.value, required this.label, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: small
                ? AppTextStyles.xsSemiBold.copyWith(
                    fontSize: 13, color: AppColors.coral)
                : AppTextStyles.h2.copyWith(color: AppColors.coral),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(label,
              style: AppTextStyles.xs, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final ActivityItem item;
  const _ActivityRow({required this.item});

  static const _icons = {
    ActivityType.join: Icons.check_circle_rounded,
    ActivityType.create: Icons.add_circle_rounded,
    ActivityType.vote: Icons.favorite_rounded,
    ActivityType.level: Icons.emoji_events_rounded,
  };
  static const _colors = {
    ActivityType.join: AppColors.green,
    ActivityType.create: AppColors.coral,
    ActivityType.vote: AppColors.amber,
    ActivityType.level: AppColors.violet,
  };

  @override
  Widget build(BuildContext context) {
    final ic = _icons[item.type]!;
    final cl = _colors[item.type]!;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cl.withValues(alpha: 0.12),
              borderRadius: AppRadius.smAll,
            ),
            child: Icon(ic, size: 18, color: cl),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.smallSemiBold),
                Text(item.when, style: AppTextStyles.xs),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.amberTint,
              borderRadius: AppRadius.pillAll,
            ),
            child: Text('+${item.xp}',
                style: AppTextStyles.xpBadge.copyWith(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
