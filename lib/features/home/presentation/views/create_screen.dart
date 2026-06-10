import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_avatar.dart';
import '../../../../core/widgets/shared/lq_button.dart';
import '../../../../core/widgets/shared/lq_restaurant_tile.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../data/datasources/restaurant_local_datasource.dart';
import '../../domain/entities/restaurant.dart';
import '../viewmodels/home_viewmodel.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _titleCtrl = TextEditingController();
  int _whenIndex = 0;
  final _whens = ['Bugün, 12:30', 'Bugün, 13:00', 'Yarın, 12:00'];
  final Set<String> _picked = {'bella', 'kofteci'};
  final Set<String> _invited = {'mert', 'zeynep', 'can'};

  bool get _valid => _titleCtrl.text.trim().length > 1 && _picked.length >= 2;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    final allRests = MockData.restaurants;
    final pool = allRests.where((r) => !_picked.contains(r.id)).toList();
    final team = MockData.team.where((t) => t.id != 'me').toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            LqScreenHeader(
              title: 'Yeni Lunch Quest',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title field
                    _FieldLabel('Etkinlik Başlığı'),
                    const SizedBox(height: AppSpacing.sm),
                    TextField(
                      controller: _titleCtrl,
                      onChanged: (_) => setState(() {}),
                      style: AppTextStyles.body,
                      decoration: const InputDecoration(
                          hintText: 'örn. Cuma Öğle Yemeği'),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // When picker
                    _FieldLabel('Tarih & Saat'),
                    const SizedBox(height: AppSpacing.sm),
                    GestureDetector(
                      onTap: () => setState(
                          () => _whenIndex = (_whenIndex + 1) % _whens.length),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.lg, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: AppRadius.smAll,
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: AppColors.coral),
                            const SizedBox(width: AppSpacing.sm),
                            Text(_whens[_whenIndex],
                                style: AppTextStyles.bodyMedium),
                            const Spacer(),
                            const Icon(Icons.expand_more_rounded,
                                color: AppColors.ink3),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Restaurant selection
                    Row(
                      children: [
                        _FieldLabel(
                            'Restoran Seçenekleri ${_picked.length}/4'),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push('/ai'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.violetTint,
                              borderRadius: AppRadius.pillAll,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.auto_awesome_rounded,
                                    size: 13, color: AppColors.violet),
                                const SizedBox(width: 4),
                                Text('AI Öneri Al',
                                    style: AppTextStyles.xsMedium.copyWith(
                                        color: AppColors.violet)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Picked chips
                    if (_picked.isEmpty)
                      Text('En az 2 restoran ekle',
                          style: AppTextStyles.small
                              .copyWith(color: AppColors.ink3))
                    else
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _picked.map((id) {
                          final r = MockData.restaurantById(id)!;
                          return _RestaurantChip(
                            restaurant: r,
                            onRemove: () =>
                                setState(() => _picked.remove(id)),
                          );
                        }).toList(),
                      ),

                    // Add pool
                    if (_picked.length < 4 && pool.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      ...pool.map(
                        (r) => _AddRestaurantRow(
                          restaurant: r,
                          onAdd: () => setState(() => _picked.add(r.id)),
                        ),
                      ),
                    ],

                    const SizedBox(height: AppSpacing.xl),

                    // Invite
                    _FieldLabel('Davet Et  ${_invited.length} kişi'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: team.map((t) {
                        final on = _invited.contains(t.id);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (on) {
                              _invited.remove(t.id);
                            } else {
                              _invited.add(t.id);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: on
                                  ? AppColors.coralTint
                                  : AppColors.card,
                              borderRadius: AppRadius.pillAll,
                              border: Border.all(
                                color: on
                                    ? AppColors.coral.withValues(alpha: 0.4)
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LqAvatar(member: t, size: 26),
                                const SizedBox(width: 6),
                                Text(t.name,
                                    style: AppTextStyles.xsSemiBold
                                        .copyWith(
                                          color: on
                                              ? AppColors.coral
                                              : AppColors.ink,
                                        )),
                                if (on) ...[
                                  const SizedBox(width: 4),
                                  const Icon(Icons.check_rounded,
                                      size: 13, color: AppColors.coral),
                                ],
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 100),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LqButton(
                label: 'Etkinlik Oluştur',
                variant: LqButtonVariant.coral,
                fullWidth: true,
                disabled: !_valid,
                onPressed: () {
                  vm.createEvent();
                  context.go('/home');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Etkinlik oluşturuldu! +25 XP 🎉')),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.notifications_outlined,
                      size: 13, color: AppColors.ink3),
                  const SizedBox(width: 4),
                  Text(
                    'Tüm ekip üyelerine bildirim gönderilecek',
                    style: AppTextStyles.xs,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.smallSemiBold.copyWith(color: AppColors.ink2));
}

class _RestaurantChip extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onRemove;
  const _RestaurantChip({required this.restaurant, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
      decoration: BoxDecoration(
        color: Color(restaurant.tileColor).withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(
            color: Color(restaurant.tileColor).withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LqRestaurantTile(restaurant: restaurant, size: 24, radius: 6),
          const SizedBox(width: 6),
          Text(restaurant.name, style: AppTextStyles.xsSemiBold),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: AppColors.ink2),
          ),
        ],
      ),
    );
  }
}

class _AddRestaurantRow extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onAdd;
  const _AddRestaurantRow({required this.restaurant, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAdd,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            LqRestaurantTile(restaurant: restaurant, size: 34, radius: 10),
            const SizedBox(width: AppSpacing.md),
            Text(restaurant.name, style: AppTextStyles.smallSemiBold),
            const Spacer(),
            const Icon(Icons.add_circle_outline_rounded,
                size: 20, color: AppColors.coral),
          ],
        ),
      ),
    );
  }
}
