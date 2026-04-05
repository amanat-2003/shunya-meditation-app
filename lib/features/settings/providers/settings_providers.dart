import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../data/models/user_settings_model.dart';

/// Provides user settings from Hive
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettingsModel?>((ref) {
  return UserSettingsNotifier();
});

class UserSettingsNotifier extends StateNotifier<UserSettingsModel?> {
  final Box<UserSettingsModel> _box;

  UserSettingsNotifier()
      : _box = Hive.box<UserSettingsModel>(AppConstants.settingsBoxName),
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
