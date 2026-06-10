import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/restaurant_local_datasource.dart';
import '../../data/repositories/event_repository.dart';
import '../../data/repositories/restaurant_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../../profile/data/repositories/profile_repository.dart';
import '../../../../core/services/auth_service.dart';
import '../../domain/entities/restaurant.dart';

enum HomeState { idle, loading, loaded, error }

class HomeViewModel extends ChangeNotifier {
  final EventRepository _eventRepo;
  final RestaurantRepository _restaurantRepo;
  final NotificationRepository _notificationRepo;
  final ProfileRepository _profileRepo;
  final AuthService _auth;

  final _client = Supabase.instance.client;

  HomeState _state = HomeState.idle;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ── Kullanıcı ──────────────────────────────────────────
  late UserProfile _user;
  UserProfile get user => _user;

  // ── Etkinlikler ────────────────────────────────────────
  List<LunchEvent> _events = [];
  List<LunchEvent> get events => _events;

  final Set<String> _joinedIds = {};
  final Set<String> _userVoteIds = {};
  final Map<String, int> _eventRatings = {};    // evId → 1..5
  String _currentEventId = '';
  FoodCategory _eventsFilter = FoodCategory.all;

  // ── AI ─────────────────────────────────────────────────
  List<AiSuggestion> _aiSuggestions = [];
  bool _aiLoading = false;
  final Set<String> _aiAdded = {};
  // AI → Create akışı: seçili restoran ID'leri
  final List<String> _pendingAiPicks = [];

  // ── Şirket Restoranları & Ekip ────────────────────────
  List<Restaurant> _restaurants = [];
  List<Restaurant> get restaurants => _restaurants;

  List<TeamMember> _team = [];
  List<TeamMember> get team => _team;

  // ── Aktivite ───────────────────────────────────────────
  List<ActivityItem> _activity = [];
  List<ActivityItem> get activity => _activity;

  // ── Bildirimler ────────────────────────────────────────
  final List<AppNotification> _notifications = [];
  int get unreadCount =>
      _notifications.where((n) => !n.isRead).length;

  // ── Timer (otomatik durum güncelleme) ──────────────────
  Timer? _statusTimer;
  StreamSubscription? _eventsSub;
  StreamSubscription? _restaurantsSub;
  StreamSubscription? _notificationsSub;

  HomeViewModel({
    required EventRepository eventRepo,
    required RestaurantRepository restaurantRepo,
    required NotificationRepository notificationRepo,
    required ProfileRepository profileRepo,
    required AuthService auth,
  })  : _eventRepo = eventRepo,
        _restaurantRepo = restaurantRepo,
        _notificationRepo = notificationRepo,
        _profileRepo = profileRepo,
        _auth = auth {
    init();
  }

  Future<void> init() async {
    final uid = _auth.userId;
    if (uid == null) {
      _state = HomeState.error;
      _errorMessage = 'Oturum bulunamadı';
      notifyListeners();
      return;
    }

    _state = HomeState.loading;
    notifyListeners();

    try {
      _user = (await _profileRepo.getProfile(uid))!;
      final companyId = _user.companyId!;
      _events = await _eventRepo.getEvents(companyId);
      _restaurants = await _restaurantRepo.getRestaurants(companyId);
      _team = await _profileRepo.getTeamMembers(companyId);
      _joinedIds.clear();
      _joinedIds.addAll(await _eventRepo.getUserJoinedEventIds(uid));
      _userVoteIds.clear();
      _userVoteIds.addAll(await _restaurantRepo.getUserVotes(uid));
      _activity = await _notificationRepo.getNotifications(uid);
      _notifications.clear();
      _notifications.addAll(await _notificationRepo.getAppNotifications(uid));
      
      _aiSuggestions = MockData.aiSuggestions; // Mock fallback
      
      if (_events.isNotEmpty) {
        _currentEventId = _events.first.id;
      }
      
      _subscribeRealtime();
      _startStatusTimer();
      _state = HomeState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = HomeState.error;
    }
    notifyListeners();
  }

  void _subscribeRealtime() {
    final uid = _auth.userId!;
    final companyId = _user.companyId!;

    _eventsSub?.cancel();
    _eventsSub = _eventRepo.watchEvents(companyId).listen((data) async {
      _events = await _eventRepo.getEvents(companyId);
      notifyListeners();
    });

    _restaurantsSub?.cancel();
    _restaurantsSub = _restaurantRepo.watchRestaurants(companyId).listen((data) async {
      _restaurants = await _restaurantRepo.getRestaurants(companyId);
      notifyListeners();
    });

    _notificationsSub?.cancel();
    _notificationsSub = _notificationRepo.watchNotifications(uid).listen((data) async {
      _activity = await _notificationRepo.getNotifications(uid);
      _notifications.clear();
      _notifications.addAll(await _notificationRepo.getAppNotifications(uid));
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _eventsSub?.cancel();
    _restaurantsSub?.cancel();
    _notificationsSub?.cancel();
    super.dispose();
  }

  // ── Timer başlat ───────────────────────────────────────
  void _startStatusTimer() {
    _statusTimer?.cancel();
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

  Future<void> _markEventDone(String evId) async {
    try {
      await _eventRepo.updateEventStatus(evId, 'completed');
    } catch (_) {}
  }

  // ── Getterlar ──────────────────────────────────────────
  List<AiSuggestion> get aiSuggestions => _computedAiSuggestions;
  bool get aiLoading => _aiLoading;
  Set<String> get aiAdded => _aiAdded;
  List<String> get pendingAiPicks => List.unmodifiable(_pendingAiPicks);
  List<AppNotification> get notifications =>
      List.unmodifiable(_notifications);
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
          orElse: () => _events.isNotEmpty ? _events.first : MockData.events.first);

  bool isJoined(String evId) => _joinedIds.contains(evId);
  
  String? userVoteFor(String evId) {
    try {
      final ev = _events.firstWhere((e) => e.id == evId);
      for (final v in ev.votes) {
        if (_userVoteIds.contains(v.restaurantId)) {
          return v.restaurantId;
        }
      }
    } catch (_) {}
    return null;
  }

  int? ratingFor(String evId) => _eventRatings[evId];
  bool isAiAdded(String restId) => _aiAdded.contains(restId);

  List<AiSuggestion> get _computedAiSuggestions {
    return _aiSuggestions.map((s) {
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

  Restaurant? restaurantById(String id) {
    try {
      return _restaurants.firstWhere((r) => r.id == id);
    } catch (_) {
      try {
        return MockData.restaurantById(id);
      } catch (_) {
        return null;
      }
    }
  }

  void setCurrentEvent(String id) {
    _currentEventId = id;
    notifyListeners();
  }

  Future<void> join(String evId) async {
    final uid = _auth.userId;
    if (uid == null) return;
    try {
      await _eventRepo.joinEvent(evId, uid);
      _joinedIds.add(evId);
      
      final idx = _events.indexWhere((e) => e.id == evId);
      if (idx != -1) {
        final ev = _events[idx];
        if (!ev.memberIds.contains(uid)) {
          final newMembers = [...ev.memberIds, uid];
          _events[idx] = LunchEvent(
            id: ev.id, type: ev.type, title: ev.title, time: ev.time,
            organizer: ev.organizer, memberIds: newMembers, place: ev.place,
            storedStatus: ev.storedStatus, remaining: ev.remaining,
            votes: ev.votes, duration: ev.duration,
            startDateTime: ev.startDateTime, durationMinutes: ev.durationMinutes,
            companyId: ev.companyId, creatorId: ev.creatorId, startsAt: ev.startsAt,
          );
        }
      }
      
      _user = _user.copyWith(xp: _user.xp + 10);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> vote(String evId, String restaurantId) async {
    final uid = _auth.userId;
    if (uid == null) return;
    try {
      final voted = await _restaurantRepo.toggleVote(restaurantId, uid);
      if (voted) {
        _userVoteIds.add(restaurantId);
        _user = _user.copyWith(xp: _user.xp + 5);
      } else {
        _userVoteIds.remove(restaurantId);
      }
      _restaurants = await _restaurantRepo.getRestaurants(_user.companyId!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void rateEvent(String evId, int stars) {
    _eventRatings[evId] = stars;
    if (stars >= 4) _user = _user.copyWith(xp: _user.xp + 5);
    notifyListeners();
  }

  Future<void> createEvent({
    required String title,
    required EventType type,
    required DateTime startsAt,
    String? location,
    String? suggestedRestaurantId,
    List<String> invitedUserIds = const [],
  }) async {
    final uid = _auth.userId;
    if (uid == null) return;
    try {
      final newEvent = await _eventRepo.createEvent(
        companyId: _user.companyId!,
        creatorId: uid,
        title: title,
        type: type,
        startsAt: startsAt,
        location: location,
      );
      
      await _eventRepo.joinEvent(newEvent.id, uid);
      
      if (suggestedRestaurantId != null) {
        await _client
            .from('events')
            .update({'suggested_restaurant_id': suggestedRestaurantId})
            .eq('id', newEvent.id);
      }
      
      if (invitedUserIds.isNotEmpty) {
        for (final inviteeId in invitedUserIds) {
          await _client.from('notifications').insert({
            'user_id': inviteeId,
            'type': 'event_created',
            'title': 'Yeni Etkinlik Daveti 🍽️',
            'body': '${_user.fullName} seni "${title}" etkinliğine davet etti.',
            'data': {'event_id': newEvent.id},
          });
        }
      }
      
      _events = await _eventRepo.getEvents(_user.companyId!);
      _joinedIds.add(newEvent.id);
      
      _user = _user.copyWith(xp: _user.xp + 25);
      _pendingAiPicks.clear();
      
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> coffeeStarted({
    required String message,
    required String location,
    required int durationMinutes,
    List<String> invitedUserIds = const [],
  }) async {
    final uid = _auth.userId;
    if (uid == null) return;
    try {
      final now = DateTime.now();
      final newEvent = await _eventRepo.createEvent(
        companyId: _user.companyId!,
        creatorId: uid,
        title: message,
        type: EventType.coffee,
        startsAt: now,
        location: location,
      );
      
      await _eventRepo.joinEvent(newEvent.id, uid);
      
      if (invitedUserIds.isNotEmpty) {
        for (final inviteeId in invitedUserIds) {
          await _client.from('notifications').insert({
            'user_id': inviteeId,
            'type': 'event_created',
            'title': 'Mola Daveti ☕',
            'body': '${_user.fullName}: $message',
            'data': {'event_id': newEvent.id},
          });
        }
      }
      
      _events = await _eventRepo.getEvents(_user.companyId!);
      _joinedIds.add(newEvent.id);
      
      _user = _user.copyWith(xp: _user.xp + 15);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void setEventsFilter(FoodCategory f) {
    _eventsFilter = f;
    notifyListeners();
  }

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

  Future<void> updateProfile({String? fullName, String? dept, String? phone}) async {
    final uid = _auth.userId;
    if (uid == null) return;
    try {
      final updates = <String, dynamic>{};
      if (fullName != null) updates['full_name'] = fullName;
      if (dept != null) updates['department'] = dept;
      
      final updatedProfile = await _profileRepo.updateProfile(uid, updates);
      if (updatedProfile != null) {
        _user = updatedProfile;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    final uid = _auth.userId;
    if (uid == null) return;
    try {
      await _notificationRepo.markAllAsRead(uid);
      for (int i = 0; i < _notifications.length; i++) {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  List<RestaurantVote> enrichedVotes(LunchEvent ev) {
    final myVote = userVoteFor(ev.id);
    return ev.votes.map((v) {
      final extra = (myVote == v.restaurantId) ? 1 : 0;
      return RestaurantVote(
          restaurantId: v.restaurantId, count: v.count + extra);
    }).toList();
  }
}
