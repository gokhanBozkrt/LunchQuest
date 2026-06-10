import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final String id;
  final String name;
  final String cuisine;
  final String dist;
  final double rating;
  final String eta;
  final int tileColor; // ARGB int

  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.dist,
    required this.rating,
    required this.eta,
    required this.tileColor,
  });

  @override
  List<Object?> get props => [id];
}

class TeamMember extends Equatable {
  final String id;
  final String name;
  final String initials;
  final int color; // ARGB int

  const TeamMember({
    required this.id,
    required this.name,
    required this.initials,
    required this.color,
  });

  @override
  List<Object?> get props => [id];
}

class LunchEvent extends Equatable {
  final String id;
  final EventType type;
  final String title;
  final String time;
  final String organizer;
  final List<String> memberIds;
  final String place;
  final EventStatus status;
  final String remaining;
  final List<RestaurantVote> votes;
  final String? duration;

  const LunchEvent({
    required this.id,
    required this.type,
    required this.title,
    required this.time,
    required this.organizer,
    required this.memberIds,
    required this.place,
    required this.status,
    required this.remaining,
    this.votes = const [],
    this.duration,
  });

  @override
  List<Object?> get props => [id];
}

class RestaurantVote extends Equatable {
  final String restaurantId;
  final int count;

  const RestaurantVote({required this.restaurantId, required this.count});

  @override
  List<Object?> get props => [restaurantId, count];
}

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

class ActivityItem extends Equatable {
  final String id;
  final ActivityType type;
  final String title;
  final String when;
  final int xp;

  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.when,
    required this.xp,
  });

  @override
  List<Object?> get props => [id];
}

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
  final int joined;
  final int created;
  final String favoriteRestaurant;

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
  });

  @override
  List<Object?> get props => [id, xp];
}

enum EventType { lunch, coffee }
enum EventStatus { active, full, done }
enum ActivityType { join, create, vote, level }
enum FoodCategory { all, lunch, coffee, mine }
