import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


import '../models/meditation_session.dart';

class MeditationRepository {
  final Box<MeditationSession> _sessionsBox;
  final SupabaseClient _supabase;

  MeditationRepository({
    required Box<MeditationSession> sessionsBox,
    required SupabaseClient supabase,
  })  : _sessionsBox = sessionsBox,
        _supabase = supabase;

  /// Save or update a session locally in Hive
  Future<void> saveSessionLocally(MeditationSession session) async {
    await _sessionsBox.put(session.id, session);
  }

  /// Get all sessions from local storage
  List<MeditationSession> getLocalSessions() {
    return _sessionsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get sessions with pending sync status
  List<MeditationSession> getPendingSessions() {
    return _sessionsBox.values
        .where((s) => s.syncStatus == 'pending')
        .toList();
  }

  /// Get sessions for a specific user
  List<MeditationSession> getUserSessions(String userId) {
    return _sessionsBox.values
        .where((s) => s.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get today's sessions for a user
  List<MeditationSession> getTodaySessions(String userId) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    return getUserSessions(userId)
        .where((s) => s.createdAt.isAfter(startOfDay))
        .toList();
  }

  /// Get sessions for a date range
  List<MeditationSession> getSessionsInRange(
    String userId,
    DateTime start,
    DateTime end,
  ) {
    return getUserSessions(userId)
        .where((s) => s.createdAt.isAfter(start) && s.createdAt.isBefore(end))
        .toList();
  }

  /// Push a single session to Supabase
  Future<bool> pushSessionToSupabase(MeditationSession session) async {
    try {
      final data = session.toJson();
      data.remove('sync_status'); // Don't send sync_status to server
      await _supabase.from('meditation_sessions').upsert(data);
      session.syncStatus = 'synced';
      await _sessionsBox.put(session.id, session);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Fetch all remote sessions for a user
  Future<List<MeditationSession>> fetchRemoteSessions(String userId) async {
    try {
      final response = await _supabase
          .from('meditation_sessions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => MeditationSession.fromJson(json))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Sync all pending sessions
  Future<int> syncAllPending() async {
    final pending = getPendingSessions();
    int synced = 0;
    for (final session in pending) {
      final success = await pushSessionToSupabase(session);
      if (success) synced++;
    }
    return synced;
  }

  /// Mark a session as synced
  Future<void> markAsSynced(String sessionId) async {
    final session = _sessionsBox.get(sessionId);
    if (session != null) {
      session.syncStatus = 'synced';
      await _sessionsBox.put(sessionId, session);
    }
  }

  /// Get a session by ID
  MeditationSession? getSession(String id) {
    return _sessionsBox.get(id);
  }

  /// Calculate total lifetime taps for a user
  int getLifetimeTaps(String userId) {
    return getUserSessions(userId).fold<int>(
      0,
      (sum, session) => sum + session.totalTaps,
    );
  }

  /// Calculate current streak (consecutive days with sessions)
  int getCurrentStreak(String userId) {
    final sessions = getUserSessions(userId);
    if (sessions.isEmpty) return 0;

    final today = DateTime.now();
    int streak = 0;
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    // Check if there's a session today
    bool hasSessionOnDate(DateTime date) {
      return sessions.any((s) {
        final sessionDate = DateTime(
          s.createdAt.year,
          s.createdAt.month,
          s.createdAt.day,
        );
        return sessionDate == date;
      });
    }

    // Start from today and go backwards
    while (hasSessionOnDate(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(const Duration(days: 1));
    }

    return streak;
  }

  /// Get taps per day for the last 7 days
  Map<DateTime, int> getWeeklyTaps(String userId) {
    final today = DateTime.now();
    final Map<DateTime, int> weeklyTaps = {};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final nextDate = date.add(const Duration(days: 1));
      final sessions = getSessionsInRange(userId, date, nextDate);
      weeklyTaps[date] = sessions.fold<int>(
        0,
        (sum, s) => sum + s.totalTaps,
      );
    }

    return weeklyTaps;
  }

  /// Get lifetime total meditated time in seconds
  int getLifetimeTimeSeconds(String userId) {
    return getUserSessions(userId).fold<int>(
      0,
      (sum, session) => sum + session.durationSeconds,
    );
  }

  /// Get monthly session frequency (sessions per day for current month)
  Map<DateTime, int> getMonthlyFrequency(String userId) {
    final today = DateTime.now();
    final startOfMonth = DateTime(today.year, today.month, 1);
    final Map<DateTime, int> frequency = {};

    for (int i = 0; i < today.day; i++) {
      final date = startOfMonth.add(Duration(days: i));
      final nextDate = date.add(const Duration(days: 1));
      final sessions = getSessionsInRange(userId, date, nextDate);
      frequency[date] = sessions.length;
    }

    return frequency;
  }

  /// Get time meditated per day for the last 7 days (in seconds)
  Map<DateTime, int> getWeeklyTime(String userId) {
    final today = DateTime.now();
    final Map<DateTime, int> weeklyTime = {};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final nextDate = date.add(const Duration(days: 1));
      final sessions = getSessionsInRange(userId, date, nextDate);
      weeklyTime[date] = sessions.fold<int>(
        0,
        (sum, s) => sum + s.durationSeconds,
      );
    }

    return weeklyTime;
  }
}
