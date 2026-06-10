import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../../features/home/domain/entities/restaurant.dart';

class LqAvatar extends StatelessWidget {
  final TeamMember? member;
  final String? initials;
  final Color? color;
  final double size;
  final bool ring;

  const LqAvatar({
    super.key,
    this.member,
    this.initials,
    this.color,
    this.size = 36,
    this.ring = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = member != null
        ? Color(member!.color)
        : (color ?? AppColors.navy600);
    final label = member?.initials ?? initials ?? '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: ring
            ? Border.all(color: AppColors.card, width: 2.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: size * 0.35,
          fontWeight: FontWeight.w700,
          color: AppColors.onCoral,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class LqAvatarStack extends StatelessWidget {
  final List<String> memberIds;
  final int max;
  final double size;

  const LqAvatarStack({
    super.key,
    required this.memberIds,
    this.max = 4,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    final shown = memberIds.take(max).toList();
    final extra = memberIds.length - shown.length;

    return SizedBox(
      height: size,
      width: shown.length * (size - size * 0.32) + (extra > 0 ? size : 0),
      child: Stack(
        children: [
          ...shown.asMap().entries.map((e) {
            final member = _memberById(e.value);
            return Positioned(
              left: e.key * (size - size * 0.32),
              child: LqAvatar(member: member, size: size, ring: true),
            );
          }),
          if (extra > 0)
            Positioned(
              left: shown.length * (size - size * 0.32),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.card, width: 2.5),
                ),
                alignment: Alignment.center,
                child: Text(
                  '+$extra',
                  style: TextStyle(
                    fontSize: size * 0.32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  TeamMember? _memberById(String id) {
    try {
      return [
        const TeamMember(id: 'me',     name: 'Ada',    initials: 'AY', color: 0xFFE8490F),
        const TeamMember(id: 'mert',   name: 'Mert',   initials: 'MD', color: 0xFF2E3658),
        const TeamMember(id: 'zeynep', name: 'Zeynep', initials: 'ZK', color: 0xFF6C5CE7),
        const TeamMember(id: 'can',    name: 'Can',    initials: 'CÖ', color: 0xFF16A34A),
        const TeamMember(id: 'elif',   name: 'Elif',   initials: 'EŞ', color: 0xFFF4A52A),
        const TeamMember(id: 'burak',  name: 'Burak',  initials: 'BA', color: 0xFF0EA5A0),
        const TeamMember(id: 'selin',  name: 'Selin',  initials: 'SA', color: 0xFFD9447E),
        const TeamMember(id: 'deniz',  name: 'Deniz',  initials: 'DY', color: 0xFF3B82F6),
      ].firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}
