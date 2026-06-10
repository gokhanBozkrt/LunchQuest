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

// ── Hazır mesaj şablonları ────────────────────────────────
class _Preset {
  final String id;
  final IconData icon;
  final String label;
  final String message;
  final Color color;

  const _Preset({
    required this.id,
    required this.icon,
    required this.label,
    required this.message,
    required this.color,
  });
}

const _presets = [
  _Preset(
    id: 'coffee',
    icon: Icons.coffee_rounded,
    label: 'Kahve',
    message: 'Kahve molası ☕ Aşağı iner misiniz?',
    color: AppColors.amber,
  ),
  _Preset(
    id: 'smoke',
    icon: Icons.air_rounded,
    label: 'Sigara',
    message: 'Sigara molası 🚬 Dışarı çıkıyorum.',
    color: AppColors.ink2,
  ),
  _Preset(
    id: 'walk',
    icon: Icons.directions_walk_rounded,
    label: 'Yürüyüş',
    message: 'Kısa bir yürüyüş molası 🚶 Katılmak isteyen?',
    color: AppColors.green,
  ),
  _Preset(
    id: 'snack',
    icon: Icons.cookie_rounded,
    label: 'Atıştırmalık',
    message: 'Atıştırmalık molası 🍪 Mutfakta buluşalım!',
    color: AppColors.coral,
  ),
  _Preset(
    id: 'custom',
    icon: Icons.edit_rounded,
    label: 'Özel',
    message: '',
    color: AppColors.violet,
  ),
];

class CoffeeScreen extends StatefulWidget {
  const CoffeeScreen({super.key});

  @override
  State<CoffeeScreen> createState() => _CoffeeScreenState();
}

class _CoffeeScreenState extends State<CoffeeScreen> {
  int _duration = 15;
  String _location = '3. Kat Mutfak';
  bool _customLocation = false;
  final _locationCtrl = TextEditingController();
  final _locationFocus = FocusNode();
  bool _sent = false;
  String _selectedPresetId = 'coffee';
  final _customCtrl = TextEditingController();
  final _customFocus = FocusNode();

  static const _locations = [
    '3. Kat Mutfak',
    '2. Kat Teras',
    'Lobi Barista',
    '5. Kat Mutfak',
  ];

  String get _activeMessage {
    if (_selectedPresetId == 'custom') return _customCtrl.text.trim();
    return _presets.firstWhere((p) => p.id == _selectedPresetId).message;
  }

  String get _activeLocation =>
      _customLocation ? _locationCtrl.text.trim() : _location;

  bool get _canSend =>
      _activeMessage.isNotEmpty && _activeLocation.isNotEmpty;

  @override
  void dispose() {
    _customCtrl.dispose();
    _customFocus.dispose();
    _locationCtrl.dispose();
    _locationFocus.dispose();
    super.dispose();
  }

  void _start(HomeViewModel vm) {
    if (!_canSend) return;
    setState(() => _sent = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      vm.coffeeStarted();
      context.go('/home');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bildirim gönderildi · "${_activeMessage.length > 40 ? '${_activeMessage.substring(0, 40)}…' : _activeMessage}"'),
          duration: const Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    final nearbyTeam =
        MockData.team.where((t) => t.id != 'me').take(6).toList();
    final selectedPreset =
        _presets.firstWhere((p) => p.id == _selectedPresetId);
    final isCustom = _selectedPresetId == 'custom';

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              LqScreenHeader(
                title: 'Etkinlik Başlat',
                onBack: () => context.pop(),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Mesaj tipi seçici ─────────────────
                      _FieldLabel('Ne yapmak istiyorsun?'),
                      const SizedBox(height: AppSpacing.md),
                      _PresetGrid(
                        presets: _presets,
                        selectedId: _selectedPresetId,
                        onSelect: (id) {
                          setState(() => _selectedPresetId = id);
                          if (id == 'custom') {
                            Future.delayed(
                              const Duration(milliseconds: 150),
                              () => _customFocus.requestFocus(),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Mesaj önizleme / özel metin ───────
                      _FieldLabel('Bildirim mesajı'),
                      const SizedBox(height: AppSpacing.sm),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) =>
                            FadeTransition(opacity: anim, child: child),
                        child: isCustom
                            ? _CustomMessageField(
                                key: const ValueKey('custom'),
                                controller: _customCtrl,
                                focusNode: _customFocus,
                                onChanged: (_) => setState(() {}),
                              )
                            : _MessagePreview(
                                key: ValueKey(_selectedPresetId),
                                message: selectedPreset.message,
                                color: selectedPreset.color,
                              ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Süre ──────────────────────────────
                      _FieldLabel('Süre'),
                      const SizedBox(height: AppSpacing.sm),
                      _DurationPicker(
                        value: _duration,
                        onChange: (v) => setState(() => _duration = v),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Konum ─────────────────────────────
                      _FieldLabel('Nerede buluşalım?'),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          // Hazır konum chip'leri
                          ..._locations.map((loc) {
                            final on = !_customLocation && _location == loc;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _location = loc;
                                _customLocation = false;
                              }),
                              child: _LocationChip(
                                  label: loc, active: on),
                            );
                          }),
                          // Özel chip
                          GestureDetector(
                            onTap: () {
                              setState(() => _customLocation = true);
                              Future.delayed(
                                const Duration(milliseconds: 150),
                                () => _locationFocus.requestFocus(),
                              );
                            },
                            child: _LocationChip(
                              label: 'Özel',
                              active: _customLocation,
                              icon: Icons.edit_location_alt_rounded,
                              accentColor: AppColors.violet,
                            ),
                          ),
                        ],
                      ),
                      // Özel konum text alanı
                      AnimatedSize(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOut,
                        child: _customLocation
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: AppSpacing.md),
                                child: TextField(
                                  controller: _locationCtrl,
                                  focusNode: _locationFocus,
                                  onChanged: (_) => setState(() {}),
                                  style: AppTextStyles.body,
                                  decoration: InputDecoration(
                                    hintText: 'Konum yaz… (örn. Çatı, Bahçe)',
                                    prefixIcon: const Icon(
                                        Icons.edit_location_alt_rounded,
                                        size: 18,
                                        color: AppColors.violet),
                                    border: OutlineInputBorder(
                                      borderRadius: AppRadius.lgAll,
                                      borderSide: const BorderSide(
                                          color: AppColors.violet,
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: AppRadius.lgAll,
                                      borderSide: const BorderSide(
                                          color: AppColors.violet,
                                          width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: AppRadius.lgAll,
                                      borderSide: const BorderSide(
                                          color: AppColors.violet,
                                          width: 2),
                                    ),
                                    fillColor: AppColors.violetTint,
                                    filled: true,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Kimler davetli ────────────────────
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
                  variant: _sent
                      ? LqButtonVariant.joined
                      : LqButtonVariant.navy,
                  fullWidth: true,
                  icon: _sent
                      ? Icons.check_rounded
                      : Icons.send_rounded,
                  disabled: _sent || !_canSend,
                  onPressed: () => _start(vm),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.bolt_rounded,
                        size: 13, color: AppColors.amber),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        '${_activeLocation.isEmpty ? '?' : _activeLocation} · $_duration dk · +15 XP',
                        style: AppTextStyles.xs,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Alt widget'lar ────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.smallSemiBold.copyWith(color: AppColors.ink2));
}

class _PresetGrid extends StatelessWidget {
  final List<_Preset> presets;
  final String selectedId;
  final ValueChanged<String> onSelect;

  const _PresetGrid({
    required this.presets,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppSpacing.sm,
      mainAxisSpacing: AppSpacing.xs,
      childAspectRatio: 0.85,
      children: presets.map((p) {
        final on = selectedId == p.id;
        return GestureDetector(
          onTap: () => onSelect(p.id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: on
                  ? p.color.withValues(alpha: 0.12)
                  : AppColors.card,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: on ? p.color : AppColors.border,
                width: on ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: on
                        ? p.color
                        : AppColors.bg,
                    borderRadius: AppRadius.smAll,
                  ),
                  child: Icon(p.icon,
                      size: 18,
                      color: on ? Colors.white : AppColors.ink3),
                ),
                const SizedBox(height: 5),
                Text(
                  p.label,
                  style: AppTextStyles.xsSemiBold.copyWith(
                    fontSize: 11,
                    color: on ? p.color : AppColors.ink2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _MessagePreview extends StatelessWidget {
  final String message;
  final Color color;

  const _MessagePreview({
    super.key,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.notifications_rounded,
                size: 16, color: color),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Push Bildirimi',
                    style: AppTextStyles.xsSemiBold
                        .copyWith(color: color)),
                const SizedBox(height: 3),
                Text(message,
                    style: AppTextStyles.small
                        .copyWith(color: AppColors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomMessageField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _CustomMessageField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          maxLength: 120,
          maxLines: 3,
          minLines: 3,
          style: AppTextStyles.body,
          decoration: InputDecoration(
            hintText: 'Ekibine göndermek istediğin mesajı yaz…',
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 12, right: 8, top: 14),
              child: Icon(Icons.edit_rounded,
                  size: 18, color: AppColors.violet),
            ),
            prefixIconConstraints:
                const BoxConstraints(minWidth: 0, minHeight: 0),
            counterStyle: AppTextStyles.xs,
            border: OutlineInputBorder(
              borderRadius: AppRadius.lgAll,
              borderSide:
                  const BorderSide(color: AppColors.violet, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgAll,
              borderSide: const BorderSide(
                  color: AppColors.violet, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.lgAll,
              borderSide:
                  const BorderSide(color: AppColors.violet, width: 2),
            ),
            fillColor: AppColors.violetTint,
            filled: true,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Hızlı öneri chip'leri
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              '🚬 Sigara molası, çıkıyorum',
              '🧘 Kısa mola lazım',
              '🍕 Pizza söyleyelim mi?',
              '🎉 Küçük bir kutlama!',
            ].map((suggestion) {
              return GestureDetector(
                onTap: () {
                  controller.text = suggestion;
                  onChanged(suggestion);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: AppSpacing.sm),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppRadius.pillAll,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(suggestion,
                      style: AppTextStyles.xsMedium
                          .copyWith(color: AppColors.ink2)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _LocationChip extends StatelessWidget {
  final String label;
  final bool active;
  final IconData icon;
  final Color accentColor;

  const _LocationChip({
    required this.label,
    required this.active,
    this.icon = Icons.location_on_rounded,
    this.accentColor = AppColors.navy,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: active ? accentColor : AppColors.card,
        borderRadius: AppRadius.pillAll,
        border: Border.all(
            color: active ? accentColor : AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: active ? Colors.white : AppColors.ink3),
          const SizedBox(width: 4),
          Text(label,
              style: AppTextStyles.xsSemiBold.copyWith(
                  color: active ? Colors.white : AppColors.ink2)),
        ],
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChange;

  const _DurationPicker({required this.value, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [5, 10, 15, 20, 30].map((d) {
        final on = value == d;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChange(d),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 6),
              padding:
                  const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: on ? AppColors.navy : AppColors.card,
                borderRadius: AppRadius.smAll,
                border: Border.all(
                    color:
                        on ? AppColors.navy : AppColors.border),
              ),
              alignment: Alignment.center,
              child: Text(
                '$d dk',
                style: AppTextStyles.xsSemiBold.copyWith(
                  fontSize: 12,
                  color:
                      on ? AppColors.onNavy : AppColors.ink2,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
