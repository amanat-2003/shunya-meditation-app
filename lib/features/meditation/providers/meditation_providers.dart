import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_providers.dart';
import '../../settings/providers/settings_providers.dart';
import '../data/models/meditation_session.dart';
import '../data/repositories/meditation_repository.dart';
import '../data/services/audio_service.dart';
import '../data/services/meditation_service.dart';

/// Provides the MeditationRepository
final meditationRepositoryProvider = Provider<MeditationRepository>((ref) {
  final sessionsBox = Hive.box<MeditationSession>(AppConstants.sessionsBoxName);
  final supabase = ref.watch(supabaseClientProvider);
  return MeditationRepository(sessionsBox: sessionsBox, supabase: supabase);
});

/// Provides the AudioService
final audioServiceProvider = Provider<AudioService>((ref) {
  final service = AudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provides the MeditationService
final meditationServiceProvider = Provider<MeditationService>((ref) {
  final repository = ref.watch(meditationRepositoryProvider);
  final audioService = ref.watch(audioServiceProvider);
  final user = ref.watch(currentUserProvider);
  final settings = ref.watch(userSettingsProvider);

  final service = MeditationService(
    repository: repository,
    audioService: audioService,
    userId: user?.id ?? '',
    hapticInterval: settings?.hapticInterval ?? 1,
    hapticIntensity: settings?.hapticIntensity ?? 'light',
  );

  ref.onDispose(() => service.dispose());
  return service;
});

/// Provides all sessions for the current user
final userSessionsProvider = Provider<List<MeditationSession>>((ref) {
  final repo = ref.watch(meditationRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  return repo.getUserSessions(user.id);
});

/// Provides today's session count
final todayTapsProvider = Provider<int>((ref) {
  final repo = ref.watch(meditationRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  final todaySessions = repo.getTodaySessions(user.id);
  return todaySessions.fold<int>(0, (sum, s) => sum + s.totalTaps);
});

/// Provides lifetime taps
final lifetimeTapsProvider = Provider<int>((ref) {
  final repo = ref.watch(meditationRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  return repo.getLifetimeTaps(user.id);
});

/// Provides current streak
final currentStreakProvider = Provider<int>((ref) {
  final repo = ref.watch(meditationRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return 0;
  return repo.getCurrentStreak(user.id);
});

/// Provides weekly taps data
final weeklyTapsProvider = Provider<Map<DateTime, int>>((ref) {
  final repo = ref.watch(meditationRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return repo.getWeeklyTaps(user.id);
});

/// Provides monthly frequency data
final monthlyFrequencyProvider = Provider<Map<DateTime, int>>((ref) {
  final repo = ref.watch(meditationRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  if (user == null) return {};
  return repo.getMonthlyFrequency(user.id);
});

/// Provides pending session count
final pendingSessionsCountProvider = Provider<int>((ref) {
  final repo = ref.watch(meditationRepositoryProvider);
  return repo.getPendingSessions().length;
});
