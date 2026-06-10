import 'package:flutter/material.dart';
import '../../domain/entities/restaurant.dart';

abstract final class MockData {
  static final UserProfile me = const UserProfile(
    id: 'me',
    name: 'Ada',
    fullName: 'Ada Yılmaz',
    dept: 'Ürün Tasarım',
    initials: 'AY',
    color: 0xFFE8490F,
    level: 7,
    xp: 1240,
    xpNext: 1500,
    joined: 28,
    created: 11,
    favoriteRestaurant: 'Bella Napoli',
  );

  static final List<TeamMember> team = const [
    TeamMember(id: 'me',     name: 'Ada',    initials: 'AY', color: 0xFFE8490F),
    TeamMember(id: 'mert',   name: 'Mert',   initials: 'MD', color: 0xFF2E3658),
    TeamMember(id: 'zeynep', name: 'Zeynep', initials: 'ZK', color: 0xFF6C5CE7),
    TeamMember(id: 'can',    name: 'Can',    initials: 'CÖ', color: 0xFF16A34A),
    TeamMember(id: 'elif',   name: 'Elif',   initials: 'EŞ', color: 0xFFF4A52A),
    TeamMember(id: 'burak',  name: 'Burak',  initials: 'BA', color: 0xFF0EA5A0),
    TeamMember(id: 'selin',  name: 'Selin',  initials: 'SA', color: 0xFFD9447E),
    TeamMember(id: 'deniz',  name: 'Deniz',  initials: 'DY', color: 0xFF3B82F6),
  ];

  static final List<Restaurant> restaurants = const [
    Restaurant(id: 'bella',   name: 'Bella Napoli',  cuisine: 'İtalyan',        dist: '0.4 km', rating: 4.7, eta: '25 dk', tileColor: 0xFFE8490F),
    Restaurant(id: 'kofteci', name: 'Köfteci Yusuf', cuisine: 'Türk',           dist: '0.2 km', rating: 4.5, eta: '15 dk', tileColor: 0xFFB23408),
    Restaurant(id: 'sushi',   name: 'Sushi Co.',     cuisine: 'Japon',          dist: '0.8 km', rating: 4.6, eta: '30 dk', tileColor: 0xFF2E3658),
    Restaurant(id: 'green',   name: 'Green Bowl',    cuisine: 'Salata · Vegan', dist: '0.3 km', rating: 4.4, eta: '18 dk', tileColor: 0xFF16A34A),
    Restaurant(id: 'burger',  name: 'Burger Lab',    cuisine: 'Burger',         dist: '0.6 km', rating: 4.3, eta: '22 dk', tileColor: 0xFFF4A52A),
    Restaurant(id: 'taco',    name: 'Taco Fiesta',   cuisine: 'Meksika',        dist: '0.9 km', rating: 4.2, eta: '28 dk', tileColor: 0xFFD9447E),
  ];

  static final List<LunchEvent> events = [
    LunchEvent(
      id: 'ev1',
      type: EventType.lunch,
      title: 'Cuma Öğle Yemeği',
      time: '12:30',
      organizer: 'Mert',
      memberIds: ['mert', 'zeynep', 'can', 'elif', 'burak', 'deniz'],
      place: 'Bella Napoli',
      status: EventStatus.active,
      remaining: '45 dk',
      votes: const [
        RestaurantVote(restaurantId: 'bella',   count: 4),
        RestaurantVote(restaurantId: 'kofteci', count: 2),
        RestaurantVote(restaurantId: 'green',   count: 1),
        RestaurantVote(restaurantId: 'sushi',   count: 1),
      ],
    ),
    LunchEvent(
      id: 'ev2',
      type: EventType.coffee,
      title: 'Ekip Kahvesi',
      time: '15:00',
      organizer: 'Zeynep',
      memberIds: ['zeynep', 'selin', 'can'],
      place: '3. Kat Mutfak',
      status: EventStatus.active,
      remaining: '1 sa 10 dk',
      duration: '15 dk',
    ),
    LunchEvent(
      id: 'ev3',
      type: EventType.lunch,
      title: 'Sprint Kutlaması',
      time: '13:00',
      organizer: 'Can',
      memberIds: ['can', 'mert', 'zeynep', 'elif', 'burak', 'selin', 'deniz'],
      place: 'Burger Lab',
      status: EventStatus.full,
      remaining: '1 sa 30 dk',
      votes: const [
        RestaurantVote(restaurantId: 'burger', count: 5),
        RestaurantVote(restaurantId: 'taco',   count: 3),
        RestaurantVote(restaurantId: 'sushi',  count: 1),
      ],
    ),
    LunchEvent(
      id: 'ev4',
      type: EventType.coffee,
      title: 'Tasarım Sync Kahve',
      time: '11:00',
      organizer: 'Elif',
      memberIds: ['elif', 'selin'],
      place: '2. Kat Teras',
      status: EventStatus.done,
      remaining: '',
      duration: '20 dk',
    ),
  ];

  static final List<AiSuggestion> aiSuggestions = const [
    AiSuggestion(
      restaurantId: 'bella',
      reason: "Ekibinin %80'i son ayda İtalyan mutfağını tercih etti.",
      matchPercent: 94,
    ),
    AiSuggestion(
      restaurantId: 'green',
      reason: '3 kişi bu hafta hafif öğünler seçti — sağlıklı bir mola.',
      matchPercent: 88,
    ),
    AiSuggestion(
      restaurantId: 'burger',
      reason: 'Cuma öğleleri burger tercih oranınız %65.',
      matchPercent: 81,
    ),
  ];

  static final List<ActivityItem> activity = const [
    ActivityItem(id: 'a1', type: ActivityType.join,   title: "Cuma Öğle Yemeği'ne katıldın",    when: '2 sa önce',  xp: 10),
    ActivityItem(id: 'a2', type: ActivityType.vote,   title: "Bella Napoli'ye oy verdin",         when: '2 sa önce',  xp: 5),
    ActivityItem(id: 'a3', type: ActivityType.create, title: 'Ekip Kahvesi oluşturdun',           when: 'Dün',        xp: 25),
    ActivityItem(id: 'a4', type: ActivityType.level,  title: 'Seviye atladın! 🎉 Lv 7',           when: '3 gün önce', xp: 100),
    ActivityItem(id: 'a5', type: ActivityType.join,   title: "Sprint Kutlaması'na katıldın",      when: 'Geçen hafta', xp: 10),
  ];

  // Helpers
  static Restaurant? restaurantById(String id) =>
      restaurants.cast<Restaurant?>().firstWhere((r) => r?.id == id, orElse: () => null);

  static TeamMember? memberById(String id) =>
      team.cast<TeamMember?>().firstWhere((m) => m?.id == id, orElse: () => null);

  static LunchEvent? eventById(String id) =>
      events.cast<LunchEvent?>().firstWhere((e) => e?.id == id, orElse: () => null);
}
