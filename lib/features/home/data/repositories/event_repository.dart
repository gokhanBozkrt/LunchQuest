import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/restaurant.dart';

class EventRepository {
  EventRepository._();
  static final EventRepository instance = EventRepository._();

  final _client = Supabase.instance.client;
  RealtimeChannel? _channel;

  static const _eventsTable = 'events';
  static const _participantsTable = 'event_participants';

  // ── Okuma ───────────────────────────────────────────────────────────────

  /// Şirkete ait etkinlikleri katılımcılar ve yaratıcı profiliyle birlikte getirir.
  Future<List<LunchEvent>> getEvents(String companyId) async {
    final data = await _client
        .from(_eventsTable)
        .select('''
          *,
          creator:profiles!events_creator_id_fkey(full_name),
          event_participants(user_id, rsvp_status)
        ''')
        .eq('company_id', companyId)
        .order('starts_at', ascending: true);

    return (data as List<dynamic>)
        .map((json) => LunchEvent.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Oluşturma ────────────────────────────────────────────────────────────

  Future<LunchEvent> createEvent({
    required String companyId,
    required String creatorId,
    required String title,
    required EventType type,
    required DateTime startsAt,
    String? location,
    int? maxParticipants,
    String? description,
  }) async {
    final result = await _client
        .from(_eventsTable)
        .insert({
          'company_id': companyId,
          'creator_id': creatorId,
          'title': title,
          'event_type': type == EventType.lunch ? 'lunch' : 'coffee',
          'starts_at': startsAt.toUtc().toIso8601String(),
          'status': 'open',
          if (location != null) 'location': location,
          if (maxParticipants != null) 'max_participants': maxParticipants,
          if (description != null) 'description': description,
        })
        .select('''
          *,
          creator:profiles!events_creator_id_fkey(full_name),
          event_participants(user_id, rsvp_status)
        ''')
        .single();

    return LunchEvent.fromJson(result as Map<String, dynamic>);
  }

  // ── Katılım ──────────────────────────────────────────────────────────────

  Future<void> joinEvent(String eventId, String userId) async {
    await _client.from(_participantsTable).upsert(
      {
        'event_id': eventId,
        'user_id': userId,
        'rsvp_status': 'going',
      },
      onConflict: 'event_id,user_id',
    );
  }

  Future<void> leaveEvent(String eventId, String userId) async {
    await _client
        .from(_participantsTable)
        .delete()
        .eq('event_id', eventId)
        .eq('user_id', userId);
  }

  /// Kullanıcının katıldığı etkinlik id'lerini döner.
  Future<Set<String>> getUserJoinedEventIds(String userId) async {
    final data = await _client
        .from(_participantsTable)
        .select('event_id')
        .eq('user_id', userId);

    return (data as List<dynamic>)
        .map((row) => row['event_id'] as String)
        .toSet();
  }

  // ── Güncelleme ────────────────────────────────────────────────────────────

  Future<void> updateEventStatus(String eventId, String status) async {
    await _client
        .from(_eventsTable)
        .update({'status': status, 'updated_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', eventId);
  }

  // ── Silme ────────────────────────────────────────────────────────────────

  Future<void> deleteEvent(String eventId) async {
    await _client.from(_eventsTable).delete().eq('id', eventId);
  }

  // ── Realtime ─────────────────────────────────────────────────────────────

  /// Gerçek zamanlı etkinlik güncellemeleri için stream.
  /// companyId RLS ile zaten filtrelendiğinden server-side filtreye gerek yok.
  Stream<List<Map<String, dynamic>>> watchEvents(String companyId) {
    return _client
        .from(_eventsTable)
        .stream(primaryKey: ['id'])
        .eq('company_id', companyId)
        .order('starts_at', ascending: true);
  }

  void dispose() {
    _channel?.unsubscribe();
    _channel = null;
  }
}
