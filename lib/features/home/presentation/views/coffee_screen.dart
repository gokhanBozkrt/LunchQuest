import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/shared/lq_avatar.dart';
import '../../../../core/widgets/shared/lq_button.dart';
import '../../../../core/widgets/shared/lq_section_header.dart';
import '../../data/datasources/restaurant_local_datasource.dart';
import '../viewmodels/home_viewmodel.dart';

class CoffeeScreen extends StatefulWidget {
  const CoffeeScreen({super.key});

  @override
  State<CoffeeScreen> createState() => _CoffeeScreenState();
}

class _CoffeeScreenState extends State<CoffeeScreen> {
  int _duration = 15;
  String _location = '3. Kat Mutfak';
  bool _sent = false;

  static const _locations = [
    '3. Kat Mutfak',
    '2. Kat Teras',
    'Lobi Barista',
    '5. Kat Mutfak',
  ];

  void _start(HomeViewModel vm) {
    setState(() => _sent = true);
    Future.delayed(const Duration(milliseconds: 1300), () {
      if (!mounted) return;
      vm.coffeeStarted();
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Coffee Break başladı · ekibe haber verildi ☕')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    final nearbyTeam =
        MockData.team.where((t) => t.id != 'me').take(6).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            LqScreenHeader(
              title: 'Coffee Break',
              onBack: () => context.pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hero
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: AppColors.navy,
                        borderRadius: AppRadius.lgAll,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: AppRadius.mdAll,
                            ),
                            child: const Icon(Icons.coffee_rounded,
                                color: Colors.white, size: 26),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Text(
                              'Hızlı bir kahve molası ayarla, ekibe anında haber ver.',
                              style: AppTextStyles.small
                                  .copyWith(color: AppColors.white86),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Duration
                    _FieldLabel('Süre'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [10, 15, 20].map((d) {
                        final on = _duration == d;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _duration = d),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              margin: EdgeInsets.only(
                                  right: d != 20 ? AppSpacing.sm : 0),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12),
                              decoration: BoxDecoration(
                                color:
                                    on ? AppColors.navy : AppColors.card,
                                borderRadius: AppRadius.smAll,
                                border: Border.all(
                                    color: on
                                        ? AppColors.navy
                                        : AppColors.border),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$d dk',
                                style: AppTextStyles.smallSemiBold.copyWith(
                                  color: on
                                      ? AppColors.onNavy
                                      : AppColors.ink2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Location
                    _FieldLabel('Hangi mutfak?'),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: _locations.map((loc) {
                        final on = _location == loc;
                        return GestureDetector(
                          onTap: () => setState(() => _location = loc),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm),
                            decoration: BoxDecoration(
                              color:
                                  on ? const Color(0xFFECEEF5) : AppColors.card,
                              borderRadius: AppRadius.pillAll,
                              border: Border.all(
                                  color: on
                                      ? AppColors.navy600
                                      : AppColors.border),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.location_on_rounded,
                                    size: 14,
                                    color: on
                                        ? AppColors.navy
                                        : AppColors.ink3),
                                const SizedBox(width: 4),
                                Text(loc,
                                    style: AppTextStyles.xsSemiBold.copyWith(
                                      color: on
                                          ? AppColors.navy
                                          : AppColors.ink2,
                                    )),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Team
                    _FieldLabel('Kimler davetli?'),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        LqAvatarStack(
                          memberIds:
                              nearbyTeam.map((t) => t.id).toList(),
                          max: 6,
                          size: 34,
                        ),
                        const SizedBox(width: 10),
                        Text('Yakındaki 6 ekip üyesi',
                            style: AppTextStyles.small
                                .copyWith(color: AppColors.ink2)),
                      ],
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
                label: _sent ? 'Bildirim gönderildi' : 'Hemen Başlat',
                variant: _sent ? LqButtonVariant.joined : LqButtonVariant.navy,
                fullWidth: true,
                icon: _sent ? Icons.check_rounded : Icons.send_rounded,
                disabled: _sent,
                onPressed: () => _start(vm),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt_rounded,
                      size: 13, color: AppColors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '$_location · $_duration dk · anlık push bildirimi',
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
      style:
          AppTextStyles.smallSemiBold.copyWith(color: AppColors.ink2));
}

extension on AppColors {
  static Color get navyTint => const Color(0xFFECEEF5);
}
