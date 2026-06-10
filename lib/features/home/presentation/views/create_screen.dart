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

// RSVP durumu (tek restoran modu)
enum _Rsvp { none, going, notGoing }

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});

  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _titleCtrl = TextEditingController();

  // Tarih & saat — gerçek seçim
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 12, minute: 30);

  // Seçili restoranlar (ID listesi — hem hazır hem custom)
  final List<String> _picked = ['bella', 'kofteci'];

  // Kullanıcının eklediği özel restoranlar
  final List<Restaurant> _customRestaurants = [];

  // Tek restoran modunda RSVP — oluşturan kişi (ben) seçmez
  _Rsvp _rsvp = _Rsvp.none;

  // Davet listesi
  final Set<String> _invited = {'mert', 'zeynep', 'can'};

  bool get _isSingleMode => _picked.length == 1;

  // Oluşturan ben olduğum için RSVP zorunlu değil
  bool get _valid =>
      _titleCtrl.text.trim().length >= 2 && _picked.isNotEmpty;

  // Tüm mevcut restoranlar (hazır + custom)
  List<Restaurant> get _allRestaurants =>
      [...MockData.restaurants, ..._customRestaurants];

  List<Restaurant> get _pickedRestaurants =>
      _picked.map((id) => _allRestaurants.firstWhere((r) => r.id == id)).toList();

  List<Restaurant> get _poolRestaurants =>
      _allRestaurants.where((r) => !_picked.contains(r.id)).toList();

  // ── Tarih formatı ─────────────────────────────────────
  static const _monthNames = [
    '', 'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  String get _formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final sel = DateTime(
        _selectedDate.year, _selectedDate.month, _selectedDate.day);

    if (sel == today) return 'Bugün';
    if (sel == tomorrow) return 'Yarın';
    return '${_selectedDate.day} ${_monthNames[_selectedDate.month]}';
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      locale: const Locale('tr', 'TR'),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.coral,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.coral,
                onPrimary: Colors.white,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _addCustomRestaurant() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _AddCustomRestaurantSheet(
        onAdd: (restaurant) {
          setState(() {
            _customRestaurants.add(restaurant);
            _picked.add(restaurant.id);
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<HomeViewModel>();
    final team = MockData.team.where((t) => t.id != 'me').toList();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                      // ── Başlık ─────────────────────────────
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

                      // ── Tarih & Saat ───────────────────────
                      _FieldLabel('Tarih & Saat'),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          // Gün seçici
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.card,
                                  borderRadius: AppRadius.smAll,
                                  border:
                                      Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                        Icons.calendar_today_rounded,
                                        size: 16,
                                        color: AppColors.coral),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Text(
                                        _formattedDate,
                                        style: AppTextStyles.smallSemiBold,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(
                                        Icons.expand_more_rounded,
                                        size: 18,
                                        color: AppColors.ink3),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // Saat seçici
                          GestureDetector(
                            onTap: _pickTime,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: 14),
                              decoration: BoxDecoration(
                                color: AppColors.coralTint,
                                borderRadius: AppRadius.smAll,
                                border: Border.all(
                                    color: AppColors.coral
                                        .withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.access_time_rounded,
                                      size: 16,
                                      color: AppColors.coral),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                                    style: AppTextStyles.smallSemiBold
                                        .copyWith(
                                            color: AppColors.coral),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Restoran seçimi ────────────────────
                      _RestaurantSection(
                        picked: _picked,
                        pickedRestaurants: _pickedRestaurants,
                        poolRestaurants: _poolRestaurants,
                        onRemove: (id) => setState(() {
                          _picked.remove(id);
                          if (_picked.length != 1) _rsvp = _Rsvp.none;
                        }),
                        onAdd: (id) => setState(() {
                          if (_picked.length < 4) _picked.add(id);
                          _rsvp = _Rsvp.none;
                        }),
                        onAddCustom: _addCustomRestaurant,
                        onAiTap: () => context.push('/ai'),
                      ),

                      // ── Tek restoran: Geliyorum / Gelmiyorum ──
                      // Oluşturan kişi (ben) zaten organizatör — RSVP gerekmez
                      // Bu bölüm sadece davet edilen ekip üyeleri için gösterilir
                      // (bilgi bandı olarak göster)
                      AnimatedSize(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOut,
                        child: _isSingleMode
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    top: AppSpacing.xl),
                                child: Container(
                                  padding: const EdgeInsets.all(
                                      AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.greenTint,
                                    borderRadius: AppRadius.lgAll,
                                    border: Border.all(
                                        color: AppColors.green
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.green,
                                          borderRadius: AppRadius.smAll,
                                        ),
                                        child: const Icon(
                                            Icons.person_rounded,
                                            color: Colors.white,
                                            size: 18),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Sen organizatörsün',
                                              style: AppTextStyles
                                                  .smallSemiBold
                                                  .copyWith(
                                                      color:
                                                          AppColors.green),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              'Davet edenler gelip gelmeyeceklerini seçecek',
                                              style: AppTextStyles.xs
                                                  .copyWith(
                                                      color:
                                                          AppColors.green),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // ── Davet ──────────────────────────────
                      _FieldLabel('Davet Et  ${_invited.length} kişi'),
                      const SizedBox(height: AppSpacing.sm),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: team.map((t) {
                          final on = _invited.contains(t.id);
                          return GestureDetector(
                            onTap: () => setState(() => on
                                ? _invited.remove(t.id)
                                : _invited.add(t.id)),
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
                                      ? AppColors.coral
                                          .withValues(alpha: 0.4)
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
                                        size: 13,
                                        color: AppColors.coral),
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
                    Text('Tüm ekip üyelerine bildirim gönderilecek',
                        style: AppTextStyles.xs),
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

// ── Restoran seçim bölümü ─────────────────────────────────

class _RestaurantSection extends StatelessWidget {
  final List<String> picked;
  final List<Restaurant> pickedRestaurants;
  final List<Restaurant> poolRestaurants;
  final ValueChanged<String> onRemove;
  final ValueChanged<String> onAdd;
  final VoidCallback onAddCustom;
  final VoidCallback onAiTap;

  const _RestaurantSection({
    required this.picked,
    required this.pickedRestaurants,
    required this.poolRestaurants,
    required this.onRemove,
    required this.onAdd,
    required this.onAddCustom,
    required this.onAiTap,
  });

  bool get _isSingle => picked.length == 1;
  bool get _isMulti => picked.length > 1;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Başlık + AI butonu
        Row(
          children: [
            _FieldLabel(
              _isSingle
                  ? 'Restoran (1 seçili — oylama yok)'
                  : 'Restoran Seçenekleri ${picked.length}/4',
            ),
            const Spacer(),
            GestureDetector(
              onTap: onAiTap,
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
                    Text('AI Öneri',
                        style: AppTextStyles.xsMedium
                            .copyWith(color: AppColors.violet)),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Mod açıklama bandı
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSingle
              ? Padding(
                  key: const ValueKey('single-info'),
                  padding:
                      const EdgeInsets.only(top: AppSpacing.sm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.coralTint,
                      borderRadius: AppRadius.smAll,
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 14, color: AppColors.coral),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Tek restoran seçildi. Oylama olmaz; katılıp katılmadığını belirt.',
                            style: AppTextStyles.xs
                                .copyWith(color: AppColors.coral),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _isMulti
                  ? Padding(
                      key: const ValueKey('multi-info'),
                      padding:
                          const EdgeInsets.only(top: AppSpacing.sm),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.amberTint,
                          borderRadius: AppRadius.smAll,
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.how_to_vote_rounded,
                                size: 14, color: AppColors.amber),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Çoklu restoran — ekip oylama yapar, en çok oy alan kazanır 👑',
                                style: AppTextStyles.xs
                                    .copyWith(color: AppColors.amber),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
        ),

        const SizedBox(height: AppSpacing.md),

        // Seçili restoranlar
        if (pickedRestaurants.isEmpty)
          Text('En az 1 restoran ekle',
              style:
                  AppTextStyles.small.copyWith(color: AppColors.ink3))
        else
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: pickedRestaurants.map((r) {
              return _RestaurantChip(
                restaurant: r,
                onRemove: () => onRemove(r.id),
              );
            }).toList(),
          ),

        const SizedBox(height: AppSpacing.md),

        // Eklenebilecek restoranlar (max 4)
        if (picked.length < 4) ...[
          ...poolRestaurants.map(
            (r) => _AddRestaurantRow(
              restaurant: r,
              onAdd: () => onAdd(r.id),
            ),
          ),
          // Özel restoran ekle butonu
          _AddCustomRow(onTap: onAddCustom),
        ],
      ],
    );
  }
}

// ── Tek restoran: Geliyorum / Gelmiyorum ─────────────────

class _RsvpSection extends StatelessWidget {
  final _Rsvp rsvp;
  final String restaurantName;
  final ValueChanged<_Rsvp> onChange;

  const _RsvpSection({
    required this.rsvp,
    required this.restaurantName,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FieldLabel('$restaurantName\'a geliyor musun?'),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _RsvpButton(
                label: 'Geliyorum',
                icon: Icons.check_circle_rounded,
                color: AppColors.green,
                tintColor: AppColors.greenTint,
                selected: rsvp == _Rsvp.going,
                onTap: () => onChange(_Rsvp.going),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _RsvpButton(
                label: 'Gelmiyorum',
                icon: Icons.cancel_rounded,
                color: AppColors.coral,
                tintColor: AppColors.coralTint,
                selected: rsvp == _Rsvp.notGoing,
                onTap: () => onChange(_Rsvp.notGoing),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RsvpButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color tintColor;
  final bool selected;
  final VoidCallback onTap;

  const _RsvpButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.tintColor,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: selected ? color : AppColors.card,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? Colors.white : color,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.smallSemiBold.copyWith(
                color: selected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Özel restoran ekleme satırı ───────────────────────────

class _AddCustomRow extends StatelessWidget {
  final VoidCallback onTap;
  const _AddCustomRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.smAll,
          border: Border.all(
            color: AppColors.coral.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.coralTint,
                borderRadius: AppRadius.smAll,
              ),
              child: const Icon(Icons.add_location_alt_rounded,
                  size: 18, color: AppColors.coral),
            ),
            const SizedBox(width: AppSpacing.md),
            Text('Yeni restoran ekle',
                style: AppTextStyles.smallSemiBold
                    .copyWith(color: AppColors.coral)),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.coral),
          ],
        ),
      ),
    );
  }
}

// ── Yeni restoran ekleme bottom sheet ─────────────────────

class _AddCustomRestaurantSheet extends StatefulWidget {
  final ValueChanged<Restaurant> onAdd;
  const _AddCustomRestaurantSheet({required this.onAdd});

  @override
  State<_AddCustomRestaurantSheet> createState() =>
      _AddCustomRestaurantSheetState();
}

class _AddCustomRestaurantSheetState
    extends State<_AddCustomRestaurantSheet> {
  final _nameCtrl = TextEditingController();
  final _cuisineCtrl = TextEditingController();
  String _selectedEmoji = '🍽️';
  int _selectedColor = 0xFFE8490F;

  static const _emojis = [
    '🍽️','🍕','🍔','🍣','🥗','🌮','🍜','🥩','🍱','🥪','🧆','🥘',
  ];
  static const _colors = [
    0xFFE8490F, 0xFF2E3658, 0xFF16A34A, 0xFFF4A52A,
    0xFF6C5CE7, 0xFFD9447E, 0xFF0EA5A0, 0xFF3B82F6,
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _cuisineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _nameCtrl.text.trim().length > 1;
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.xxl,
        right: AppSpacing.xxl,
        top: AppSpacing.xxl,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            Text('Yeni Restoran Ekle', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            Text('Listede olmayan bir yeri ekle',
                style: AppTextStyles.small.copyWith(color: AppColors.ink2)),
            const SizedBox(height: AppSpacing.xl),

            // Önizleme tile
            Row(
              children: [
                _EmojiTile(
                    emoji: _selectedEmoji, color: _selectedColor),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _nameCtrl.text.trim().isEmpty
                        ? 'Restoran adı…'
                        : _nameCtrl.text.trim(),
                    style: AppTextStyles.h3.copyWith(
                      color: _nameCtrl.text.trim().isEmpty
                          ? AppColors.ink3
                          : AppColors.ink,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // İsim
            _SheetLabel('Restoran Adı'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _nameCtrl,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.body,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  hintText: 'örn. Nusret, Köşe Pidecisi'),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Mutfak tipi
            _SheetLabel('Mutfak Tipi (isteğe bağlı)'),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _cuisineCtrl,
              style: AppTextStyles.body,
              decoration: const InputDecoration(
                  hintText: 'örn. Türk, İtalyan, Fast-food'),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Emoji seçici
            _SheetLabel('Simge'),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _emojis.map((e) {
                final on = _selectedEmoji == e;
                return GestureDetector(
                  onTap: () => setState(() => _selectedEmoji = e),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: on ? AppColors.coralTint : AppColors.card,
                      borderRadius: AppRadius.smAll,
                      border: Border.all(
                          color: on ? AppColors.coral : AppColors.border),
                    ),
                    alignment: Alignment.center,
                    child: Text(e,
                        style: const TextStyle(fontSize: 22)),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Renk seçici
            _SheetLabel('Renk'),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _colors.map((c) {
                final on = _selectedColor == c;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 140),
                    width: 32, height: 32,
                    margin: const EdgeInsets.only(right: AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Color(c),
                      shape: BoxShape.circle,
                      border: on
                          ? Border.all(
                              color: AppColors.card, width: 2)
                          : null,
                      boxShadow: on
                          ? [
                              BoxShadow(
                                  color: Color(c).withValues(alpha: 0.5),
                                  blurRadius: 8)
                            ]
                          : null,
                    ),
                    child: on
                        ? const Icon(Icons.check_rounded,
                            size: 16, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Ekle butonu
            SizedBox(
              width: double.infinity,
              height: AppDimensions.btnHeight,
              child: ElevatedButton(
                onPressed: canAdd
                    ? () {
                        final id =
                            'custom_${DateTime.now().millisecondsSinceEpoch}';
                        final r = Restaurant(
                          id: id,
                          name: _nameCtrl.text.trim(),
                          cuisine: _cuisineCtrl.text.trim().isEmpty
                              ? 'Diğer'
                              : _cuisineCtrl.text.trim(),
                          dist: '—',
                          rating: 0,
                          eta: '—',
                          tileColor: _selectedColor,
                        );
                        widget.onAdd(r);
                        Navigator.pop(context);
                      }
                    : null,
                child: const Text('Listeye Ekle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Küçük yardımcı widget'lar ─────────────────────────────

class _EmojiTile extends StatelessWidget {
  final String emoji;
  final int color;
  const _EmojiTile({required this.emoji, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        color: Color(color),
        borderRadius: AppRadius.mdAll,
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 26)),
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style: AppTextStyles.xsSemiBold.copyWith(color: AppColors.ink2));
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(text,
      style:
          AppTextStyles.smallSemiBold.copyWith(color: AppColors.ink2));
}

class _RestaurantChip extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onRemove;
  const _RestaurantChip(
      {required this.restaurant, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 10, 4),
      decoration: BoxDecoration(
        color:
            Color(restaurant.tileColor).withValues(alpha: 0.12),
        borderRadius: AppRadius.pillAll,
        border: Border.all(
            color: Color(restaurant.tileColor)
                .withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LqRestaurantTile(
              restaurant: restaurant, size: 24, radius: 6),
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
  const _AddRestaurantRow(
      {required this.restaurant, required this.onAdd});

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
            LqRestaurantTile(
                restaurant: restaurant, size: 34, radius: 10),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(restaurant.name,
                      style: AppTextStyles.smallSemiBold),
                  if (restaurant.cuisine.isNotEmpty &&
                      restaurant.dist != '—')
                    Text(
                        '${restaurant.cuisine} · ${restaurant.dist}',
                        style: AppTextStyles.xs),
                ],
              ),
            ),
            const Icon(Icons.add_circle_outline_rounded,
                size: 20, color: AppColors.coral),
          ],
        ),
      ),
    );
  }
}
