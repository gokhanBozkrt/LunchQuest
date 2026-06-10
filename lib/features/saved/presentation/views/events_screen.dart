import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/cards/event_card.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../../home/data/datasources/restaurant_local_datasource.dart';
import '../../../home/domain/entities/restaurant.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final filters = [
      (FoodCategory.all, 'Tümü'),
      (FoodCategory.lunch, 'Lunch'),
      (FoodCategory.coffee, 'Coffee Break'),
      (FoodCategory.mine, 'Katıldıklarım'),
    ];

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
                    Text('Etkinlikler', style: AppTextStyles.h1),
                    const Spacer(),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppRadius.smAll,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.search_rounded,
                          size: 20, color: AppColors.ink2),
                    ),
                  ],
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  children: filters.map((f) {
                    final (cat, label) = f;
                    final active = vm.eventsFilter == cat;
                    return GestureDetector(
                      onTap: () => vm.setEventsFilter(cat),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: AppSpacing.sm),
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: active ? AppColors.coral : AppColors.card,
                          borderRadius: AppRadius.pillAll,
                          border: Border.all(
                              color: active
                                  ? AppColors.coral
                                  : AppColors.border),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          label,
                          style: AppTextStyles.smallMedium.copyWith(
                            color: active ? AppColors.onCoral : AppColors.ink2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // List
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: vm.filteredEvents.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 48, color: AppColors.ink3),
                            const SizedBox(height: AppSpacing.lg),
                            Text('Bu filtrede etkinlik yok',
                                style: AppTextStyles.body
                                    .copyWith(color: AppColors.ink2)),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: EventCardList(
                            event: vm.filteredEvents[i],
                            joined: vm.isJoined(vm.filteredEvents[i].id),
                            onOpen: () {
                              vm.setCurrentEvent(vm.filteredEvents[i].id);
                              context.push('/detail');
                            },
                          ),
                        ),
                        childCount: vm.filteredEvents.length,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
