import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../home/domain/entities/restaurant.dart';

class NotificationRepository {
  NotificationRepository._();
  static final NotificationRepository instance = NotificationRepository._();

  final _client = Supabase.instance.client;

  static const _table = 'notifications';
  static const _tokensTable = 'push_tokens';

  // ── Okuma ───────────────────────────────────────────────────────────────

  Future<List<ActivityItem>> getNotifications(String userId,
      {int limit = 30}) async {
    final data = await _client
        .from(_table)
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List<dynamic>)
        .map((json) => ActivityItem.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<AppNotification>> getAppNotifications(String userId,
      {int limit = 30}) async {
    final data = await _client
        .from(_table)
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List<dynamic>)
        .map((json) => AppNotification.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final result = await _client
        .from(_table)
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false)
        .count();
    return result.count;
  }

  // ── Güncelleme ────────────────────────────────────────────────────────────

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  // ── Push Token Kayıt ─────────────────────────────────────────────────────

  Future<void> upsertPushToken({
    required String userId,
    required String token,
    required String platform, // 'android' | 'ios'
  }) async {
    await _client.from(_tokensTable).upsert(
      {
        'user_id': userId,
        'token': token,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'user_id,token',
    );
  }

  Future<void> removePushToken(String userId, String token) async {
    await _client
        .from(_tokensTable)
        .delete()
        .eq('user_id', userId)
        .eq('token', token);
  }

  // ── Realtime Stream ───────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(30);
  }
}
