import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_providers.dart';
import '../data/models/user_settings_model.dart';

/// Provides user settings from Hive, with Supabase sync
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettingsModel?>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final user = ref.watch(currentUserProvider);
  return UserSettingsNotifier(supabase: supabase, userId: user?.id);
});

class UserSettingsNotifier extends StateNotifier<UserSettingsModel?> {
  final Box<UserSettingsModel> _box;
  final SupabaseClient _supabase;
  final String? _userId;

  UserSettingsNotifier({
    required SupabaseClient supabase,
    required String? userId,
  })  : _box = Hive.box<UserSettingsModel>(AppConstants.settingsBoxName),
        _supabase = supabase,
        _userId = userId,
        super(null) {
    _loadSettings();
  }

  void _loadSettings() {
    if (_box.isNotEmpty) {
      state = _box.getAt(0);
    } else {
      final defaultSettings = UserSettingsModel();
      _box.add(defaultSettings);
      state = defaultSettings;
    }
  }

  Future<void> updateSettings(UserSettingsModel settings) async {
    await _box.putAt(0, settings);
    state = settings;
    // Push to Supabase in the background
    _pushToSupabase(settings);
  }

  Future<void> _pushToSupabase(UserSettingsModel settings) async {
    if (_userId == null || _userId.isEmpty) return;
    try {
      final data = settings.toJson();
      data['user_id'] = _userId;
      data['updated_at'] = DateTime.now().toIso8601String();
      await _supabase.from('user_settings').upsert(data, onConflict: 'user_id');
    } catch (_) {
      // Silently fail — settings are stored locally and will sync later
    }
  }

  Future<void> setDailyTapGoal(int goal) async {
    final current = state ?? UserSettingsModel();
    final updated = current.copyWith(dailyTapGoal: goal);
    await updateSettings(updated);
  }

  Future<void> setDailyTimeGoal(int seconds) async {
    final current = state ?? UserSettingsModel();
    final updated = current.copyWith(dailyTimeGoalSeconds: seconds);
    await updateSettings(updated);
  }

  Future<void> setHapticInterval(int interval) async {
    final current = state ?? UserSettingsModel();
    final updated = current.copyWith(hapticInterval: interval);
    await updateSettings(updated);
  }

  Future<void> setAudioReminderEnabled(bool enabled) async {
    final current = state ?? UserSettingsModel();
    final updated = current.copyWith(audioReminderEnabled: enabled);
    await updateSettings(updated);
  }

  Future<void> setAudioReminderSound(String sound) async {
    final current = state ?? UserSettingsModel();
    final updated = current.copyWith(audioReminderSound: sound);
    await updateSettings(updated);
  }
}
