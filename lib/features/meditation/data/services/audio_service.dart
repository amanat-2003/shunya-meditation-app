import 'dart:async';

import 'package:just_audio/just_audio.dart';

import '../../../../core/constants/app_constants.dart';

class AudioService {
  AudioPlayer? _player;
  Timer? _reminderTimer;
  bool _isEnabled = false;
  String _soundName = 'om';

  AudioService();

  /// Initialize the audio player
  Future<void> init() async {
    _player = AudioPlayer();
  }

  /// Configure and start audio reminders
  void startReminders({required bool enabled, required String soundName}) {
    _isEnabled = enabled;
    _soundName = soundName;

    if (!_isEnabled) return;

    _scheduleNextReminder();
  }

  /// Schedule the next audio reminder at a random interval
  void _scheduleNextReminder() {
    _reminderTimer?.cancel();
    final interval = AppConstants.getRandomReminderInterval();
    _reminderTimer = Timer(interval, () async {
      await _playSound();
      _scheduleNextReminder(); // Schedule the next one
    });
  }

  /// Play the configured reminder sound
  Future<void> _playSound() async {
    if (_player == null) return;
    try {
      // Use bundled audio asset
      await _player!.setAsset('assets/audio/$_soundName.mp3');
      await _player!.setVolume(0.7);
      await _player!.play();
    } catch (e) {
      // Silently fail - don't disrupt meditation
    }
  }

  /// Stop all reminders
  void stopReminders() {
    _reminderTimer?.cancel();
    _reminderTimer = null;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    stopReminders();
    await _player?.dispose();
    _player = null;
  }
}
