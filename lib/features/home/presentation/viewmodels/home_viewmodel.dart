import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/datasources/restaurant_local_datasource.dart';
import '../../domain/entities/restaurant.dart';

class HomeViewModel extends ChangeNotifier {
  // ── Kullanıcı ──────────────────────────────────────────
  late UserProfile _user;
  UserProfile get user => _user;

  // ── Etkinlikler ────────────────────────────────────────
  late List<LunchEvent> _events;
  final Set<String> _joinedIds = {};
  final Map<String, String> _userVotes = {};    // evId → restaurantId
  final Map<String, int> _eventRatings = {};    // evId → 1..5
  String _currentEventId = 'ev1';
  FoodCategory _eventsFilter = FoodCategory.all;

  // ── AI ─────────────────────────────────────────────────
  late List<AiSuggestion> _aiSuggestions;
  bool _aiLoading = false;
  final Set<String> _aiAdded = {};
  // AI → Create akışı: seçili restoran ID'leri
  final List<String> _pendingAiPicks = [];

  // ── Aktivite ───────────────────────────────────────────
  late List<ActivityItem> _activity;

  // ── Bildirimler ────────────────────────────────────────
  final List<AppNotification> _notifications = [];
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  // ── Timer (otomatik durum güncelleme) ──────────────────
  Timer? _statusTimer;

  HomeViewModel() {
    _user = MockData.me;
    _events = MockData.events;
    _aiSuggestions = MockData.aiSuggestions;
    _activity = MockData.activity;
    _startStatusTimer();
    _seedNotifications();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }

  // ── Timer başlat ───────────────────────────────────────
  void _startStatusTimer() {
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkEventStatuses();
    });
    // İlk kontrol hemen
    Future.microtask(_checkEventStatuses);
  }

  void _checkEventStatuses() {
    bool changed = false;
    final now = DateTime.now();
    for (final ev in _events) {
      if (ev.startDateTime == null) continue;
      final endTime =
          ev.startDateTime!.add(Duration(minutes: ev.durationMinutes));
      final isDone = now.isAfter(endTime);
      final wasDone = ev.storedStatus == EventStatus.done;
      if (isDone && !wasDone) {
        _markEventDone(ev.id);
        changed = true;
      }
    }
    if (changed) notifyListeners();
  }

  void _markEventDone(String evId) {
    final idx = _events.indexWhere((e) => e.id == evId);
    if (idx == -1) return;
    final ev = _events[idx];
    // storedStatus güncelle (yeni kopya oluştur)
    _events[idx] = LunchEvent(
      id: ev.id, type: ev.type, title: ev.title, time: ev.time,
      organizer: ev.organizer, memberIds: ev.memberIds, place: ev.place,
      storedStatus: EventStatus.done, remaining: '',
      votes: ev.votes, duration: ev.duration,
      startDateTime: ev.startDateTime,
      durationMinutes: ev.durationMinutes,
    );
    // Restoran olan lunch etkinliklerinde bildirim gönder
    if (ev.type == EventType.lunch && ev.votes.isNotEmpty) {
      _addNotification(AppNotification(
        id: 'notif_end_${ev.id}',
        title: '${ev.title} sona erdi',
        body: '${ev.place}\'ı puanlamayı unutma! ⭐',
        type: NotificationType.eventEnd,
        time: DateTime.now(),
        eventId: ev.id,
      ));
    }
  }

  void _seedNotifications() {
    _notifications.addAll([
      AppNotification(
        id: 'n1',
        title: 'Cuma Öğle Yemeği başladı 🍽️',
        body: "Mert'in organize ettiği etkinlik saat 12:30'da başlıyor.",
        type: NotificationType.newEvent,
        time: DateTime.now().subtract(const Duration(minutes: 20)),
        eventId: 'ev1',
      ),
      AppNotification(
        id: 'n2',
        title: 'Geçen Haftanın Favorisi sona erdi',
        body: "Sushi Co.'yu puanlamayı unutma! ⭐",
        type: NotificationType.eventEnd,
        time: DateTime.now().subtract(const Duration(days: 2)),
        eventId: 'ev5',
      ),
    ]);
  }

  void _addNotification(AppNotification notif) {
    _notifications.insert(0, notif);
    notifyListeners();
  }

  // ── Getterlar ──────────────────────────────────────────
  List<LunchEvent> get events => _events;
  List<AiSuggestion> get aiSuggestions => _computedAiSuggestions;
  bool get aiLoading => _aiLoading;
  Set<String> get aiAdded => _aiAdded;
  List<String> get pendingAiPicks => List.unmodifiable(_pendingAiPicks);
  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);
  List<ActivityItem> get activity => _activity;
  String get currentEventId => _currentEventId;
  FoodCategory get eventsFilter => _eventsFilter;
  int get xp => _user.xp;

  // Etkinliğin gerçek (hesaplanan) durumu
  EventStatus effectiveStatus(LunchEvent ev) {
    if (ev.storedStatus == EventStatus.done) return EventStatus.done;
    if (ev.startDateTime == null) return ev.storedStatus;
    final endTime =
        ev.startDateTime!.add(Duration(minutes: ev.durationMinutes));
    if (DateTime.now().isAfter(endTime)) return EventStatus.done;
    return ev.storedStatus;
  }

  // Kalan süre string'i
  String remainingText(LunchEvent ev) {
    if (ev.startDateTime == null) return ev.remaining;
    final endTime =
        ev.startDateTime!.add(Duration(minutes: ev.durationMinutes));
    final diff = endTime.difference(DateTime.now());
    if (diff.isNegative) return 'Sona erdi';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dk';
    final h = diff.inHours;
    final m = diff.inMinutes % 60;
    return m > 0 ? '$h sa $m dk' : '$h sa';
  }

  List<LunchEvent> get activeEvents => _events
      .where((e) => effectiveStatus(e) != EventStatus.done)
      .toList();

  List<LunchEvent> get filteredEvents {
    switch (_eventsFilter) {
      case FoodCategory.lunch:
        return _events.where((e) => e.type == EventType.lunch).toList();
      case FoodCategory.coffee:
        return _events.where((e) => e.type == EventType.coffee).toList();
      case FoodCategory.mine:
        return _events.where((e) => isJoined(e.id)).toList();
      case FoodCategory.all:
        return _events;
    }
  }

  LunchEvent get currentEvent =>
      _events.firstWhere((e) => e.id == _currentEventId,
          orElse: () => _events.first);

  bool isJoined(String evId) => _joinedIds.contains(evId);
  String? userVoteFor(String evId) => _userVotes[evId];
  int? ratingFor(String evId) => _eventRatings[evId];
  bool isAiAdded(String restId) => _aiAdded.contains(restId);

  // AI öneri — puanları da dikkate al
  List<AiSuggestion> get _computedAiSuggestions {
    return MockData.aiSuggestions.map((s) {
      // Varsa kullanıcı puanı ile match'i ayarla
      final avgRating = _avgRatingForRestaurant(s.restaurantId);
      if (avgRating == null) return s;
      final boost = ((avgRating - 3) * 3).round(); // 1★→-6, 5★→+6
      final newMatch = (s.matchPercent + boost).clamp(10, 99);
      final newReason = avgRating >= 4
          ? '${s.reason} Geçmiş puanın: ${avgRating.toStringAsFixed(1)}★'
          : avgRating <= 2
              ? '⚠️ Bu restorana düşük puan verdin. Yine de öneriliyor.'
              : s.reason;
      return AiSuggestion(
        restaurantId: s.restaurantId,
        reason: newReason,
        matchPercent: newMatch,
      );
    }).toList()
      ..sort((a, b) => b.matchPercent.compareTo(a.matchPercent));
  }

  double? _avgRatingForRestaurant(String restId) {
    // Restoran oylarına sahip bitmiş etkinliklerdeki puanlar
    final ratings = <int>[];
    for (final entry in _eventRatings.entries) {
      final ev = _events.firstWhere((e) => e.id == entry.key,
          orElse: () => _events.first);
      if (ev.votes.any((v) => v.restaurantId == restId)) {
        ratings.add(entry.value);
      }
    }
    if (ratings.isEmpty) return null;
    return ratings.reduce((a, b) => a + b) / ratings.length;
  }

  // ── Eylemler ───────────────────────────────────────────

  void setCurrentEvent(String id) {
    _currentEventId = id;
    notifyListeners();
  }

  void join(String evId) {
    if (_joinedIds.contains(evId)) return;
    _joinedIds.add(evId);
    _user = _user.copyWith(xp: _user.xp + 10);
    notifyListeners();
  }

  void vote(String evId, String restaurantId) {
    if (_userVotes.containsKey(evId)) return;
    _userVotes[evId] = restaurantId;
    _user = _user.copyWith(xp: _user.xp + 5);
    notifyListeners();
  }

  void rateEvent(String evId, int stars) {
    _eventRatings[evId] = stars;
    if (stars >= 4) _user = _user.copyWith(xp: _user.xp + 5);
    notifyListeners();
  }

  void createEvent() {
    _joinedIds.add('ev1');
    _user = _user.copyWith(xp: _user.xp + 25);
    _pendingAiPicks.clear();
    _addNotification(AppNotification(
      id: 'notif_create_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Etkinlik oluşturuldu 🎉',
      body: 'Ekibine bildirim gönderildi. +25 XP kazandın!',
      type: NotificationType.newEvent,
      time: DateTime.now(),
    ));
    notifyListeners();
  }

  void coffeeStarted() {
    _user = _user.copyWith(xp: _user.xp + 15);
    notifyListeners();
  }

  void setEventsFilter(FoodCategory f) {
    _eventsFilter = f;
    notifyListeners();
  }

  // AI → Create akışı
  void toggleAiPick(String restaurantId) {
    if (_aiAdded.contains(restaurantId)) {
      _aiAdded.remove(restaurantId);
      _pendingAiPicks.remove(restaurantId);
    } else {
      _aiAdded.add(restaurantId);
      if (!_pendingAiPicks.contains(restaurantId)) {
        _pendingAiPicks.add(restaurantId);
      }
    }
    notifyListeners();
  }

  void clearAiPicks() {
    _pendingAiPicks.clear();
    _aiAdded.clear();
    notifyListeners();
  }

  Future<void> refreshAi() async {
    _aiLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 950));
    _aiLoading = false;
    notifyListeners();
  }

  // Profil güncelle
  void updateProfile({String? fullName, String? dept, String? phone}) {
    _user = _user.copyWith(
      fullName: fullName, dept: dept, phone: phone);
    notifyListeners();
  }

  // Bildirim okundu
  void markAllRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isRead: true);
    }
    notifyListeners();
  }

  // Vote counts + user vote
  List<RestaurantVote> enrichedVotes(LunchEvent ev) {
    final myVote = _userVotes[ev.id];
    return ev.votes.map((v) {
      final extra = (myVote == v.restaurantId) ? 1 : 0;
      return RestaurantVote(
          restaurantId: v.restaurantId, count: v.count + extra);
    }).toList();
  }
}
