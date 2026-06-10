import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantRepository {
  RestaurantRepository._();
  static final RestaurantRepository instance = RestaurantRepository._();

  final _client = Supabase.instance.client;

  static const _table = 'restaurant_suggestions';
  static const _votesTable = 'suggestion_votes';

  // ── Okuma ───────────────────────────────────────────────────────────────

  /// Şirkete ait tüm restoran önerilerini getirir; her birinin oy sayısıyla birlikte.
  Future<List<Restaurant>> getRestaurants(String companyId) async {
    final data = await _client
        .from(_table)
        .select('*, suggestion_votes(count)')
        .eq('company_id', companyId)
        .order('created_at', ascending: false);

    return (data as List<dynamic>).map((json) {
      final votes = (json['suggestion_votes'] as List<dynamic>?) ?? [];
      final voteCount = votes.isNotEmpty ? (votes.first['count'] as num?)?.toInt() ?? 0 : 0;
      return Restaurant.fromJson({...json as Map<String, dynamic>, 'vote_count': voteCount});
    }).toList();
  }

  // ── Ekleme ───────────────────────────────────────────────────────────────

  Future<Restaurant> addRestaurant({
    required String companyId,
    required String suggestedBy,
    required Map<String, dynamic> data,
  }) async {
    final result = await _client
        .from(_table)
        .insert({
          ...data,
          'company_id': companyId,
          'suggested_by': suggestedBy,
        })
        .select()
        .single();

    return Restaurant.fromJson(result as Map<String, dynamic>);
  }

  // ── Oylama ──────────────────────────────────────────────────────────────

  /// Kullanıcı daha önce oy verdiyse siler (toggle), yoksa ekler.
  Future<bool> toggleVote(String suggestionId, String userId) async {
    // Mevcut oy var mı?
    final existing = await _client
        .from(_votesTable)
        .select('id')
        .eq('suggestion_id', suggestionId)
        .eq('user_id', userId)
        .maybeSingle();

    if (existing != null) {
      await _client
          .from(_votesTable)
          .delete()
          .eq('suggestion_id', suggestionId)
          .eq('user_id', userId);
      return false; // oy geri alındı
    } else {
      await _client.from(_votesTable).insert({
        'suggestion_id': suggestionId,
        'user_id': userId,
      });
      return true; // oy verildi
    }
  }

  /// Kullanıcının belirli bir öneri için oy durumunu döner.
  Future<bool> hasVoted(String suggestionId, String userId) async {
    final result = await _client
        .from(_votesTable)
        .select('id')
        .eq('suggestion_id', suggestionId)
        .eq('user_id', userId)
        .maybeSingle();
    return result != null;
  }

  /// Birden fazla öneri için oy durumlarını tek sorguda döner.
  Future<Set<String>> getUserVotes(String userId) async {
    final data = await _client
        .from(_votesTable)
        .select('suggestion_id')
        .eq('user_id', userId);

    return (data as List<dynamic>)
        .map((row) => row['suggestion_id'] as String)
        .toSet();
  }

  // ── Güncelleme ────────────────────────────────────────────────────────────

  Future<void> updateRestaurant(String id, Map<String, dynamic> data) async {
    await _client.from(_table).update(data).eq('id', id);
  }

  // ── Silme ────────────────────────────────────────────────────────────────

  Future<void> deleteRestaurant(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  // ── Realtime Stream ───────────────────────────────────────────────────────

  Stream<List<Map<String, dynamic>>> watchRestaurants(String companyId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .eq('company_id', companyId)
        .order('created_at', ascending: false);
  }
}
