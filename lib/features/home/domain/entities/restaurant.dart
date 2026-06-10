import 'package:equatable/equatable.dart';

// ─── Restaurant (→ restaurant_suggestions tablosu) ─────────────────────────

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String cuisine; // cuisine_type
  final String dist;    // UI-only, not stored
  final double rating;
  final String eta;
  final int tileColor;
  final String eta;     // UI-only, not stored
  final int tileColor;  // UI-only, not stored
  final String? address;
  final String? mapsUrl;
  final String? imageUrl;
  final String? priceRange;
  final String? notes;
  final int voteCount;  // suggestion_votes sayısı

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.dist,
    required this.rating,
    required this.eta,
    required this.tileColor,
    this.address,
    this.mapsUrl,
    this.imageUrl,
    this.priceRange,
    this.notes,
    this.voteCount = 0,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] as String,
      name: json['name'] as String,
      cuisine: (json['cuisine_type'] as String?) ?? '',
      dist: '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      eta: '',
      tileColor: _colorFromCuisine((json['cuisine_type'] as String?) ?? ''),
      address: json['address'] as String?,
      mapsUrl: json['maps_url'] as String?,
      imageUrl: json['image_url'] as String?,
      priceRange: json['price_range'] as String?,
      notes: json['notes'] as String?,
      voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'cuisine_type': cuisine,
        'address': address,
        'maps_url': mapsUrl,
        'image_url': imageUrl,
        'price_range': priceRange,
        'rating': rating,
        'notes': notes,
      };

  static int _colorFromCuisine(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'i̇talyan':
      case 'italian':
        return 0xFFE8490F;
      case 'türk':
      case 'turkish':
        return 0xFFB23408;
      case 'japon':
      case 'japanese':
        return 0xFF2E3658;
      case 'salata':
      case 'vegan':
        return 0xFF16A34A;
      case 'burger':
        return 0xFFF4A52A;
      case 'meksika':
      case 'mexican':
        return 0xFFD9447E;
      default:
        return 0xFF6C5CE7;
    }
  }

  @override
  List<Object?> get props => [id];
}

// ─── TeamMember (→ profiles tablosu) ──────────────────────────────────────

class TeamMember extends Equatable {
  final String id;
  final String name;
  final String initials;
  final int color;
  final int color;
  final String? avatarUrl;
  final String? department;

  const TeamMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
    this.avatarUrl,
    this.department,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    final fullName = (json['full_name'] as String?) ?? '';
    return TeamMember(
      id: json['id'] as String,
      name: fullName.split(' ').first,
      initials: _initials(fullName),
      color: _colorFromId(json['id'] as String),
      avatarUrl: json['avatar_url'] as String?,
      department: json['department'] as String?,
    );
  }

  static String _initials(String fullName) {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return fullName.isNotEmpty ? fullName[0].toUpperCase() : '?';
  }

  static int _colorFromId(String id) {
    const colors = [
      0xFFE8490F, 0xFF2E3658, 0xFF6C5CE7, 0xFF16A34A,
      0xFFF4A52A, 0xFF0EA5A0, 0xFFD9447E, 0xFF3B82F6,
    ];
    return colors[id.hashCode.abs() % colors.length];
  }

  @override
  List<Object?> get props => [id];
}

// ─── LunchEvent (→ events tablosu) ────────────────────────────────────────

class LunchEvent extends Equatable {
  final String id;
  final EventType type;
  final String title;
  final String time;        // display string
  final String organizer;
  final List<String> memberIds;
  final String place;
  final EventStatus storedStatus; // sadece başlangıç değeri
  final String remaining;
  final List<RestaurantVote> votes;
  final String? duration;
  final DateTime? startDateTime;   // gerçek başlangıç zamanı
  final int durationMinutes;       // kaç dakika sürer
  final String? companyId;
  final String? creatorId;
  final DateTime? startsAt;

  const LunchEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.time,
    required this.organizer,
    required this.memberIds,
    required this.place,
    required this.storedStatus,
    required this.remaining,
    this.votes = const [],
    this.duration,
    this.startDateTime,
    this.durationMinutes = 60,
    this.companyId,
    this.creatorId,
    this.startsAt,
  });

  factory LunchEvent.fromJson(Map<String, dynamic> json) {
    final startsAt = json['starts_at'] != null
        ? DateTime.parse(json['starts_at'] as String).toLocal()
        : null;

    final participants = (json['event_participants'] as List<dynamic>?) ?? [];
    final memberIds = participants
        .map((p) => p['user_id'] as String)
        .toList();

    final creator = json['creator'] as Map<String, dynamic>?;
    final creatorName = creator != null
        ? (creator['full_name'] as String?)?.split(' ').first ?? 'Bilinmiyor'
        : 'Bilinmiyor';

    final restaurantId = json['suggested_restaurant_id'] as String?;

    return LunchEvent(
      id: json['id'] as String,
      type: _parseEventType(json['event_type'] as String? ?? ''),
      title: json['title'] as String,
      time: startsAt != null
          ? '${startsAt.hour.toString().padLeft(2, '0')}:${startsAt.minute.toString().padLeft(2, '0')}'
          : '',
      organizer: creatorName,
      memberIds: memberIds,
      place: json['location'] as String? ?? '',
      status: _parseEventStatus(
        json['status'] as String? ?? '',
        json['max_participants'] as int?,
        memberIds.length,
      ),
      remaining: _calcRemaining(startsAt),
      companyId: json['company_id'] as String?,
      creatorId: json['creator_id'] as String?,
      startsAt: startsAt,
      votes: restaurantId != null
          ? [RestaurantVote(restaurantId: restaurantId, count: memberIds.length)]
          : [],
    );
  }

  Map<String, dynamic> toInsertJson({
    required String companyId,
    required String creatorId,
    required DateTime startsAt,
  }) =>
      {
        'company_id': companyId,
        'creator_id': creatorId,
        'title': title,
        'event_type': type == EventType.lunch ? 'lunch' : 'coffee',
        'location': place,
        'starts_at': startsAt.toIso8601String(),
        'status': 'open',
      };

  static EventType _parseEventType(String s) =>
      s == 'coffee' ? EventType.coffee : EventType.lunch;

  static EventStatus _parseEventStatus(
      String s, int? max, int current) {
    if (s == 'cancelled' || s == 'done') return EventStatus.done;
    if (max != null && current >= max) return EventStatus.full;
    return EventStatus.active;
  }

  static String _calcRemaining(DateTime? startsAt) {
    if (startsAt == null) return '';
    final diff = startsAt.difference(DateTime.now());
    if (diff.isNegative) return 'Tamamlandı';
    if (diff.inHours > 0) return '${diff.inHours} sa ${diff.inMinutes.remainder(60)} dk';
    return '${diff.inMinutes} dk';
  }

  @override
  List<Object?> get props => [id];
}

// ─── RestaurantVote (→ suggestion_votes tablosu) ──────────────────────────

class RestaurantVote extends Equatable {
  final String restaurantId;
  final int count;

  const RestaurantVote({required this.restaurantId, required this.count});

  @override
  List<Object?> get props => [restaurantId, count];
}

// ─── AiSuggestion ─────────────────────────────────────────────────────────

class AiSuggestion extends Equatable {
  final String restaurantId;
  final String reason;
  final int matchPercent;

  const AiSuggestion({
    required this.restaurantId,
    required this.reason,
    required this.matchPercent,
  });

  @override
  List<Object?> get props => [restaurantId];
}

// ─── ActivityItem (→ notifications tablosu) ───────────────────────────────

class ActivityItem extends Equatable {
  final String id;
  final ActivityType type;
  final String title;
  final String when;
  final int xp;
  final bool isRead;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.when,
    required this.xp,
    this.isRead = false,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.parse(json['created_at'] as String).toLocal();
    return ActivityItem(
      id: json['id'] as String,
      type: _parseType(json['type'] as String? ?? ''),
      title: json['title'] as String,
      when: _formatWhen(createdAt),
      xp: (json['data']?['xp'] as num?)?.toInt() ?? 0,
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  static ActivityType _parseType(String s) {
    switch (s) {
      case 'event_joined':
        return ActivityType.join;
      case 'event_created':
        return ActivityType.create;
      case 'vote_cast':
        return ActivityType.vote;
      case 'level_up':
        return ActivityType.level;
      default:
        return ActivityType.join;
    }
  }

  static String _formatWhen(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk önce';
    if (diff.inHours < 24) return '${diff.inHours} sa önce';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    return 'Geçen hafta';
  }

  @override
  List<Object?> get props => [id];
}

// ─── UserProfile (→ profiles tablosu) ─────────────────────────────────────

class UserProfile extends Equatable {
  final String id;
  final String name;
  final String fullName;
  final String dept;
  final String initials;
  final int color;
  final int level;
  final int xp;
  final int xpNext;
  final int joined;   // etkinliğe katılım sayısı
  final int created;  // oluşturulan etkinlik sayısı
  final String favoriteRestaurant;
  final String? avatarUrl;
  final String? companyId;
  final String? title;
  final String phone;

  const UserProfile({
    required this.id,
    required this.name,
    required this.fullName,
    required this.dept,
    required this.initials,
    required this.color,
    required this.level,
    required this.xp,
    required this.xpNext,
    required this.joined,
    required this.created,
    required this.favoriteRestaurant,
    this.avatarUrl,
    this.companyId,
    this.title,
    this.phone = '',
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final fullName = (json['full_name'] as String?) ?? 'Kullanıcı';
    final parts = fullName.trim().split(' ');
    final initials = parts.length >= 2
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : fullName.isNotEmpty
            ? fullName[0].toUpperCase()
            : '?';

    return UserProfile(
      id: json['id'] as String,
      name: parts.first,
      fullName: fullName,
      dept: (json['department'] as String?) ?? '',
      initials: initials,
      color: 0xFFE8490F,
      level: 1,
      xp: 0,
      xpNext: 500,
      joined: 0,
      created: 0,
      favoriteRestaurant: '',
      avatarUrl: json['avatar_url'] as String?,
      companyId: json['company_id'] as String?,
      title: json['title'] as String?,
    );
  }

  Map<String, dynamic> toUpdateJson() => {
        'full_name': fullName,
        'department': dept,
        'title': title,
        'avatar_url': avatarUrl,
      };

  UserProfile copyWith({
    String? fullName,
    String? dept,
    String? phone,
    int? xp,
  }) => UserProfile(
        id: id,
        name: name,
        fullName: fullName ?? this.fullName,
        dept: dept ?? this.dept,
        initials: initials,
        color: color,
        level: level,
        xp: xp ?? this.xp,
        xpNext: xpNext,
        joined: joined,
        created: created,
        favoriteRestaurant: favoriteRestaurant,
        phone: phone ?? this.phone,
      );

  @override
  List<Object?> get props => [id, xp, fullName, phone];
}

class AppNotification extends Equatable {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime time;
  final bool isRead;
  final String? eventId;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.time,
    this.isRead = false,
    this.eventId,
  });

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id, title: title, body: body, type: type,
        time: time, isRead: isRead ?? this.isRead, eventId: eventId,
      );

  @override
  List<Object?> get props => [id];
}

// ─── Enums ─────────────────────────────────────────────────────────────────

enum EventType { lunch, coffee }
enum EventStatus { active, full, done }
enum ActivityType { join, create, vote, level }
enum FoodCategory { all, lunch, coffee, mine }
enum NotificationType { eventEnd, newEvent, vote, system }
