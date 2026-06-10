import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../home/domain/entities/restaurant.dart';

class ProfileRepository {
  ProfileRepository._();
  static final ProfileRepository instance = ProfileRepository._();

  final _client = Supabase.instance.client;

  static const _profilesTable = 'profiles';
  static const _bucket = 'avatars';

  // ── Okuma ───────────────────────────────────────────────────────────────

  Future<UserProfile?> getProfile(String userId) async {
    final data = await _client
        .from(_profilesTable)
        .select('*')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return UserProfile.fromJson(data as Map<String, dynamic>);
  }

  /// Aynı şirketteki tüm profilleri getirir (team listesi için).
  Future<List<TeamMember>> getTeamMembers(String companyId) async {
    final data = await _client
        .from(_profilesTable)
        .select('id, full_name, avatar_url, department')
        .eq('company_id', companyId)
        .eq('is_active', true)
        .order('full_name', ascending: true);

    return (data as List<dynamic>)
        .map((json) => TeamMember.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Güncelleme ────────────────────────────────────────────────────────────

  Future<UserProfile?> updateProfile(
      String userId, Map<String, dynamic> updates) async {
    final result = await _client
        .from(_profilesTable)
        .update({...updates, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', userId)
        .select()
        .single();
    return UserProfile.fromJson(result as Map<String, dynamic>);
  }

  // ── FCM Token Güncelleme ─────────────────────────────────────────────────

  Future<void> updateFcmToken(String userId, String token) async {
    await _client
        .from(_profilesTable)
        .update({'fcm_token': token, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', userId);
  }

  // ── Avatar Upload ─────────────────────────────────────────────────────────

  Future<String?> uploadAvatar(String userId, Uint8List bytes, String extension) async {
    final path = '$userId/avatar.$extension';
    await _client.storage.from(_bucket).uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(
        upsert: true,
        contentType: 'image/$extension',
      ),
    );
    return _client.storage.from(_bucket).getPublicUrl(path);
  }

  // ── Realtime ─────────────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> watchProfile(String userId) {
    return _client
        .from(_profilesTable)
        .stream(primaryKey: ['id'])
        .eq('id', userId);
  }
}
