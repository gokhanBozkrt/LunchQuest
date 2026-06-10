import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_avatar.dart';
import '../../../../core/widgets/shared/lq_button.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../../home/data/datasources/restaurant_local_datasource.dart';
import '../../../home/domain/entities/restaurant.dart';
import '../../../home/presentation/viewmodels/home_viewmodel.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _mounted = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 120),
        () => mounted ? setState(() => _mounted = true) : null);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final ev = vm.currentEvent;
    final isCoffee = ev.type == EventType.coffee;
    final joined = vm.isJoined(ev.id);
    final myVote = vm.userVoteFor(ev.id);
    final enriched = vm.enrichedVotes(ev);
    final total = enriched.fold<int>(0, (s, v) => s + v.count);
    final leadId = enriched.isEmpty
        ? null
        : (enriched.toList()..sort((a, b) => b.count - a.count)).first.restaurantId;

    final members = joined
        ? [...ev.memberIds, 'me']
        : ev.memberIds;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            LqScreenHeader(
              title: ev.title,
              onBack: () => context.pop(),
              right: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.coralTint,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 11, color: AppColors.coral),
                    const SizedBox(width: 3),
                    Text(
                      "${ev.time}'a ${ev.remaining}",
                      style: AppTextStyles.xsSemiBold
                          .copyWith(color: AppColors.coral),
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Participants
                    Row(
                      children: [
                        LqAvatarStack(
                            memberIds: members, max: 5, size: 38),
                        const SizedBox(width: 10),
                        Text('${members.length} kişi katıldı',
                            style: AppTextStyles.small.copyWith(
                                color: AppColors.ink2)),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    if (!isCoffee) ...[
                      // Voting section
                      Text('Restoran Oylaması',
                          style: AppTextStyles.h3),
                      const SizedBox(height: AppSpacing.lg),

                      ...enriched.map((vote) {
                        final r = MockData.restaurantById(vote.restaurantId);
                        if (r == null) return const SizedBox();
                        final pct = total > 0 && _mounted
                            ? (vote.count / total * 100).round()
                            : 0;
                        final isLead = vote.restaurantId == leadId;
                        final votedThis = myVote == vote.restaurantId;

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.md),
                          child: _VoteRow(
                            restaurant: r,
                            count: vote.count,
                            percent: pct,
                            isLeading: isLead,
                            hasVoted: myVote != null,
                            votedThis: votedThis,
                            onVote: () => vm.vote(ev.id, vote.restaurantId),
                          ),
                        );
                      }),

                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: myVote != null
                              ? AppColors.greenTint
                              : AppColors.amberTint,
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              myVote != null
                                  ? Icons.check_circle_rounded
                                  : Icons.info_outline_rounded,
                              size: 16,
                              color: myVote != null
                                  ? AppColors.green
                                  : AppColors.amber,
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: Text(
                                myVote != null
                                    ? 'Oyun kaydedildi · değiştirmek için organizatöre yaz'
                                    : 'Bir restorana oy ver, en çok oyu alan kazanır 👑',
                                style: AppTextStyles.xs.copyWith(
                                  color: myVote != null
                                      ? AppColors.green
                                      : AppColors.amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Coffee info
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.amberTint,
                          borderRadius: AppRadius.lgAll,
                          border: Border.all(
                              color: AppColors.amber.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.amber,
                                borderRadius: AppRadius.mdAll,
                              ),
                              child: const Icon(Icons.coffee_rounded,
                                  color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(ev.place,
                                    style: AppTextStyles.h3),
                                const SizedBox(height: 4),
                                Text(
                                  '${ev.duration} · ${ev.organizer} başlattı',
                                  style: AppTextStyles.small,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Hızlı bir mola — ekiple ${ev.place}\'ta buluş.',
                        style: AppTextStyles.body.copyWith(
                            color: AppColors.ink2),
                      ),
                    ],

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
          child: LqButton(
            label: joined ? 'Katıldın' : 'Katıl',
            variant: joined ? LqButtonVariant.joined : LqButtonVariant.coral,
            fullWidth: true,
            icon: joined ? Icons.check_rounded : null,
            onPressed: joined ? null : () => vm.join(ev.id),
          ),
        ),
      ),
    );
  }
}

class _VoteRow extends StatelessWidget {
  final Restaurant restaurant;
  final int count;
  final int percent;
  final bool isLeading;
  final bool hasVoted;
  final bool votedThis;
  final VoidCallback onVote;

  const _VoteRow({
    required this.restaurant,
    required this.count,
    required this.percent,
    required this.isLeading,
    required this.hasVoted,
    required this.votedThis,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasVoted ? null : onVote,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: votedThis
              ? AppColors.coralTint
              : isLeading
                  ? AppColors.card
                  : AppColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: votedThis
                ? AppColors.coral.withValues(alpha: 0.5)
                : isLeading
                    ? AppColors.amber.withValues(alpha: 0.5)
                    : AppColors.border,
            width: isLeading ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Tile
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Color(restaurant.tileColor),
                    borderRadius: AppRadius.smAll,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    restaurant.name[0],
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(restaurant.name,
                              style: AppTextStyles.smallSemiBold),
                          if (isLeading) ...[
                            const SizedBox(width: 6),
                            const Text('👑',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ],
                      ),
                      Text(restaurant.cuisine, style: AppTextStyles.xs),
                    ],
                  ),
                ),
                Text('$count oy',
                    style: AppTextStyles.xsSemiBold),
                const SizedBox(width: AppSpacing.sm),
                if (votedThis)
                  const Icon(Icons.check_circle_rounded,
                      size: 18, color: AppColors.coral)
                else if (!hasVoted)
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            // Progress bar
            ClipRRect(
              borderRadius: AppRadius.pillAll,
              child: LinearProgressIndicator(
                value: percent / 100,
                minHeight: 6,
                backgroundColor: AppColors.border,
                valueColor: AlwaysStoppedAnimation(
                  isLeading ? AppColors.amber : AppColors.coral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
