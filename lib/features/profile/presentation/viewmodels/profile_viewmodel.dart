import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../home/domain/entities/restaurant.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/push_notification_service.dart';

enum ProfileState { idle, loading, success, error }

class ProfileViewModel extends ChangeNotifier {
  final _repo = ProfileRepository.instance;
  final _auth = AuthService.instance;

  UserProfile? _profile;
  List<TeamMember> _team = [];
  ProfileState _state = ProfileState.idle;
  String? _errorMessage;

  StreamSubscription? _profileSub;

  UserProfile? get profile => _profile;
  List<TeamMember> get team => _team;
  ProfileState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _auth.isLoggedIn;

  ProfileViewModel() {
    loadProfile();
  }

  Future<void> loadProfile() async {
    final uid = _auth.userId;
    if (uid == null) return;

    _setState(ProfileState.loading);
    try {
      _profile = await _repo.getProfile(uid);
      final companyId = _profile?.companyId;
      if (companyId != null) {
        _team = await _repo.getTeamMembers(companyId);
      }
      _subscribeRealtime(uid);
      _setState(ProfileState.success);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ProfileState.error);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final uid = _auth.userId;
    if (uid == null) return;

    try {
      _profile = await _repo.updateProfile(uid, updates);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  void _subscribeRealtime(String uid) {
    _profileSub?.cancel();
    _profileSub = _repo.watchProfile(uid).listen((rows) {
      if (rows.isNotEmpty) {
        _profile = UserProfile.fromJson(rows.first);
        notifyListeners();
      }
    });
  }

  void _setState(ProfileState s) {
    _state = s;
    notifyListeners();
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }
}
