import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_button.dart';
import '../../../../core/widgets/shared/lq_restaurant_tile.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../../home/data/datasources/restaurant_local_datasource.dart';
import '../../../home/domain/entities/restaurant.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';

class AiScreen extends StatelessWidget {
  /// selectionMode = true → Create ekranından push ile açıldı
  final bool selectionMode;
  const AiScreen({super.key, this.selectionMode = false});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (selectionMode)
                          GestureDetector(
                            onTap: () => context.pop(),
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
                        if (selectionMode) const SizedBox(width: AppSpacing.sm),
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                              color: AppColors.violet,
                              borderRadius: AppRadius.smAll),
                          child: const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 18),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text('AI Öneri', style: AppTextStyles.h2),
                        const Spacer(),
                        GestureDetector(
                          onTap: vm.refreshAi,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: AppRadius.pillAll,
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh_rounded,
                                    size: 15, color: AppColors.ink2),
                                const SizedBox(width: 4),
                                Text('Yenile',
                                    style: AppTextStyles.xsSemiBold),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      selectionMode
                          ? 'Eklemek istediğin restoranları seç:'
                          : 'Geçmiş tercihlerine göre bugün şunları öneririz:',
                      style: AppTextStyles.small.copyWith(
                          color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
            ),

            // ── Liste ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) {
                    if (vm.aiLoading) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _SkeletonCard(),
                      );
                    }
                    final s = vm.aiSuggestions[i];
                    final r = MockData.restaurantById(s.restaurantId);
                    if (r == null) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _AiCard(
                        restaurant: r,
                        suggestion: s,
                        added: vm.isAiAdded(s.restaurantId),
                        selectionMode: selectionMode,
                        onToggle: () => vm.toggleAiPick(s.restaurantId),
                      ),
                    );
                  },
                  childCount: vm.aiLoading ? 3 : vm.aiSuggestions.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl)),
          ],
        ),
      ),
      // selectionMode'da "Seçilenleri Ekle" butonu
      bottomNavigationBar: selectionMode
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LqButton(
                      label: vm.pendingAiPicks.isEmpty
                          ? 'Restoran Seç'
                          : '${vm.pendingAiPicks.length} Restoran Ekle',
                      variant: LqButtonVariant.violet,
                      fullWidth: true,
                      disabled: vm.pendingAiPicks.isEmpty,
                      onPressed: vm.pendingAiPicks.isEmpty
                          ? null
                          : () => context.pop(),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}

class _AiCard extends StatelessWidget {
  final Restaurant restaurant;
  final AiSuggestion suggestion;
  final bool added;
  final bool selectionMode;
  final VoidCallback onToggle;

  const _AiCard({
    required this.restaurant,
    required this.suggestion,
    required this.added,
    required this.selectionMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: added ? AppColors.violetTint : AppColors.card,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: added
              ? AppColors.violet.withValues(alpha: 0.4)
              : AppColors.border,
          width: added ? 1.5 : 1,
        ),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadowSm,
              blurRadius: 12,
              offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır
          Row(
            children: [
              LqRestaurantTile(restaurant: restaurant, size: 56, radius: 16),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: AppTextStyles.h3),
                    const SizedBox(height: 3),
                    Text(
                      '${restaurant.cuisine} · ${restaurant.dist}',
                      style: AppTextStyles.xs,
                    ),
                  ],
                ),
              ),
              // Eşleşme yüzdesi
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.violet,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        size: 11, color: Colors.white),
                    const SizedBox(width: 3),
                    Text('${suggestion.matchPercent}%',
                        style: AppTextStyles.xsSemiBold
                            .copyWith(color: Colors.white)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Neden öneriliyor
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.violetTint,
              borderRadius: AppRadius.smAll,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 14, color: AppColors.violet),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(suggestion.reason,
                      style: AppTextStyles.xs
                          .copyWith(color: AppColors.violet)),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Ekle / Çıkar butonu
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: added ? AppColors.violet : AppColors.coralTint,
                borderRadius: AppRadius.smAll,
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    added ? Icons.check_rounded : Icons.add_rounded,
                    size: 16,
                    color: added ? Colors.white : AppColors.coral,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    added
                        ? selectionMode
                            ? 'Seçildi ✓'
                            : 'Eklendi ✓'
                        : selectionMode
                            ? 'Seç'
                            : 'Etkinliğe Ekle',
                    style: AppTextStyles.smallSemiBold.copyWith(
                      color: added ? Colors.white : AppColors.coral,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatefulWidget {
  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1100))
      ..repeat();
    _anim = Tween<double>(begin: -1, end: 2)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        height: 180,
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: const [AppColors.border, AppColors.card, AppColors.border],
          ),
        ),
      ),
    );
  }
}
