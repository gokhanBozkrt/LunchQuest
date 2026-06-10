import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_spacing.dart';
import '../../theme/app_text_styles.dart';
import '../shared/lq_avatar.dart';
import '../shared/lq_status_badge.dart';
import '../../../features/home/domain/entities/restaurant.dart';
import '../../../features/home/presentation/viewmodels/home_viewmodel.dart';

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

  bool get _hasRestaurant => event.votes.isNotEmpty;
  bool _isDone(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    return vm.effectiveStatus(event) == EventStatus.done;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final isCoffee = event.type == EventType.coffee;
    final existingRating = vm.ratingFor(event.id);

    return GestureDetector(
      onTap: onOpen,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: _isDone(context) ? AppColors.borderStrong : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isDone(context)
                        ? AppColors.cardSunken
                        : isCoffee
                            ? AppColors.amberTint
                            : AppColors.coralTint,
                    borderRadius: AppRadius.mdAll,
                  ),
                  child: Icon(
                    isCoffee
                        ? Icons.coffee_rounded
                        : Icons.restaurant_rounded,
                    color: _isDone(context)
                        ? AppColors.ink3
                        : isCoffee
                            ? AppColors.amber
                            : AppColors.coral,
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
                              style: AppTextStyles.smallSemiBold.copyWith(
                                color: _isDone(context)
                                    ? AppColors.ink2
                                    : AppColors.ink,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        const SizedBox(width: 8),
                        LqStatusBadge(status: vm.effectiveStatus(event)),
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

                if (!_isDone(context) || !_hasRestaurant)
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.ink3, size: 20),
              ],
            ),

            // ── Puanlama satırı (sadece bitti + restoran varsa) ──
            if (_isDone(context) && _hasRestaurant) ...[
              const SizedBox(height: AppSpacing.md),
              _RatingRow(
                event: event,
                existingRating: existingRating,
                onRate: (stars) => vm.rateEvent(event.id, stars),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Puanlama satırı ───────────────────────────────────────
class _RatingRow extends StatelessWidget {
  final LunchEvent event;
  final int? existingRating;
  final ValueChanged<int> onRate;

  const _RatingRow({
    required this.event,
    required this.existingRating,
    required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    final rated = existingRating != null;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: rated ? AppColors.amberTint : AppColors.cardSunken,
        borderRadius: AppRadius.smAll,
        border: Border.all(
          color: rated
              ? AppColors.amber.withValues(alpha: 0.3)
              : AppColors.borderStrong,
        ),
      ),
      child: Row(
        children: [
          Icon(
            rated ? Icons.star_rounded : Icons.star_border_rounded,
            size: 16,
            color: rated ? AppColors.amber : AppColors.ink3,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              rated
                  ? '${event.place} · $existingRating/5 puan verdin'
                  : '${event.place}\'ı puanla',
              style: AppTextStyles.xsSemiBold.copyWith(
                color: rated ? AppColors.amber : AppColors.ink2,
              ),
            ),
          ),
          if (rated)
            // Puan göster
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (i) => Icon(
                i < existingRating! ? Icons.star_rounded : Icons.star_border_rounded,
                size: 14,
                color: AppColors.amber,
              )),
            )
          else
            // Puanla butonu
            GestureDetector(
              onTap: () => _showRatingSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.amber,
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(
                  'Puanla',
                  style: AppTextStyles.xsSemiBold.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showRatingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _RatingSheet(
        event: event,
        onRate: (stars) {
          onRate(stars);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${event.place} için $stars yıldız verdin! ⭐',
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Rating Bottom Sheet ───────────────────────────────────
class _RatingSheet extends StatefulWidget {
  final LunchEvent event;
  final ValueChanged<int> onRate;

  const _RatingSheet({required this.event, required this.onRate});

  @override
  State<_RatingSheet> createState() => _RatingSheetState();
}

class _RatingSheetState extends State<_RatingSheet> {
  int _hovered = 0;
  int _selected = 0;

  static const _labels = ['', 'Berbattı 😞', 'İdare eder 😐', 'İyi 🙂', 'Harika 😄', 'Mükemmel 🤩'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxl, AppSpacing.xxxl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: AppRadius.pillAll,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Restaurant tile + name
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.amberTint,
              borderRadius: AppRadius.lgAll,
            ),
            child: const Icon(Icons.restaurant_rounded,
                size: 32, color: AppColors.amber),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(widget.event.place, style: AppTextStyles.h2),
          const SizedBox(height: 4),
          Text('Bu restoranı nasıl buldun?',
              style: AppTextStyles.small.copyWith(color: AppColors.ink2)),

          const SizedBox(height: AppSpacing.xxl),

          // Stars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              final filled = star <= (_hovered > 0 ? _hovered : _selected);
              return GestureDetector(
                onTap: () => setState(() => _selected = star),
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hovered = star),
                  onExit: (_) => setState(() => _hovered = 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 120),
                      child: Icon(
                        filled ? Icons.star_rounded : Icons.star_border_rounded,
                        key: ValueKey(filled),
                        size: 48,
                        color: filled ? AppColors.amber : AppColors.border,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),

          // Label
          SizedBox(
            height: 28,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: Text(
                _labels[_hovered > 0 ? _hovered : _selected],
                key: ValueKey(_hovered > 0 ? _hovered : _selected),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.amber,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),

          // Confirm
          SizedBox(
            width: double.infinity,
            height: AppDimensions.btnHeight,
            child: ElevatedButton(
              onPressed: _selected > 0
                  ? () => widget.onRate(_selected)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.amber,
                disabledBackgroundColor: AppColors.border,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.smAll,
                ),
              ),
              child: Text(
                _selected > 0
                    ? '$_selected yıldız ver  ⭐'
                    : 'Bir yıldız seç',
                style: AppTextStyles.btnLabel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
