import 'package:flutter/foundation.dart';
import '../../data/datasources/restaurant_local_datasource.dart';
import '../../domain/entities/restaurant.dart';

enum ViewState { idle, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  // ── State ──────────────────────────────────────────────
  late UserProfile _user;
  late List<LunchEvent> _events;
  late List<Restaurant> _restaurants;
  late List<AiSuggestion> _aiSuggestions;
  late List<ActivityItem> _activity;

  final Set<String> _joinedIds = {};
  final Map<String, String> _userVotes = {};  // evId -> restaurantId
  final Set<String> _aiAdded = {};

  String _currentEventId = 'ev1';
  FoodCategory _eventsFilter = FoodCategory.all;
  ViewState _state = ViewState.idle;
  bool _aiLoading = false;

  // XP floats
  int _xp = 0;
  int get xp => _xp;

  // ── Init ───────────────────────────────────────────────
  HomeViewModel() {
    _user = MockData.me;
    _events = List.from(MockData.events);
    _restaurants = MockData.restaurants;
    _aiSuggestions = MockData.aiSuggestions;
    _activity = MockData.activity;
    _xp = _user.xp;
  }

  // ── Getters ────────────────────────────────────────────
  UserProfile get user => _user;
  List<Restaurant> get restaurants => _restaurants;
  List<AiSuggestion> get aiSuggestions => _aiSuggestions;
  List<ActivityItem> get activity => _activity;
  String get currentEventId => _currentEventId;
  FoodCategory get eventsFilter => _eventsFilter;
  ViewState get state => _state;
  bool get aiLoading => _aiLoading;
  Set<String> get aiAdded => _aiAdded;

  List<LunchEvent> get activeEvents =>
      _events.where((e) => e.status != EventStatus.done).toList();

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
      MockData.eventById(_currentEventId) ?? _events.first;

  bool isJoined(String evId) => _joinedIds.contains(evId);
  String? userVoteFor(String evId) => _userVotes[evId];
  bool isAiAdded(String restId) => _aiAdded.contains(restId);

  // ── Actions ────────────────────────────────────────────
  void setCurrentEvent(String id) {
    _currentEventId = id;
    notifyListeners();
  }

  void join(String evId) {
    if (_joinedIds.contains(evId)) return;
    _joinedIds.add(evId);
    _xp += 10;
    notifyListeners();
  }

  void vote(String evId, String restaurantId) {
    if (_userVotes.containsKey(evId)) return;
    _userVotes[evId] = restaurantId;
    _xp += 5;
    notifyListeners();
  }

  void createEvent() {
    _currentEventId = 'ev1';
    _joinedIds.add('ev1');
    _xp += 25;
    notifyListeners();
  }

  void coffeeStarted() {
    _xp += 15;
    notifyListeners();
  }

  void setEventsFilter(FoodCategory f) {
    _eventsFilter = f;
    notifyListeners();
  }

  void addAiSuggestion(String restaurantId) {
    _aiAdded.add(restaurantId);
    notifyListeners();
  }

  Future<void> refreshAi() async {
    _aiLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 950));
    _aiLoading = false;
    notifyListeners();
  }

  // Vote counts including user's own vote
  List<RestaurantVote> enrichedVotes(LunchEvent ev) {
    final myVote = _userVotes[ev.id];
    return ev.votes.map((v) {
      final extra = (myVote == v.restaurantId) ? 1 : 0;
      return RestaurantVote(restaurantId: v.restaurantId, count: v.count + extra);
    }).toList();
  }
}
