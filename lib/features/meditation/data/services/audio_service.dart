import 'dart:async';
import 'dart:io';

import 'package:just_audio/just_audio.dart';

import '../../../../core/constants/app_constants.dart';

class AudioService {
  AudioPlayer? _player;
  AudioPlayer? _loopPlayer; // Dedicated player for continuous loop
  Timer? _reminderTimer;
  bool _isEnabled = false;
  String _soundName = 'om';
  String _customAudioPath = '';

  AudioService();

  /// Initialize audio players
  Future<void> init() async {
    _player = AudioPlayer();
    _loopPlayer = AudioPlayer();
  }

  /// Configure and start audio reminders (periodic random-interval pings)
  void startReminders({
    required bool enabled,
    required String soundName,
    String customAudioPath = '',
  }) {
    _isEnabled = enabled;
    _soundName = soundName;
    _customAudioPath = customAudioPath;

    if (!_isEnabled) return;

    _scheduleNextReminder();
  }

  /// Start continuous looping playback of the selected sound
  Future<void> startContinuousLoop({
    required String soundName,
    String customAudioPath = '',
  }) async {
    if (_loopPlayer == null) return;
    try {
      await _loopPlayer!.stop();

      if (customAudioPath.isNotEmpty && File(customAudioPath).existsSync()) {
        await _loopPlayer!.setFilePath(customAudioPath);
      } else {
        await _loopPlayer!.setAsset('assets/audio/$soundName.mp3');
      }

      await _loopPlayer!.setLoopMode(LoopMode.one); // Infinite loop
      await _loopPlayer!.setVolume(0.5);
      // DO NOT await play() on an infinite loop, it will block execution forever
      _loopPlayer!.play();
    } catch (_) {
      // Silently fail — don't disrupt meditation
    }
  }

  /// Stop continuous loop playback
  Future<void> stopContinuousLoop() async {
    await _loopPlayer?.stop();
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

  /// Play the configured reminder sound once
  Future<void> _playSound() async {
    if (_player == null) return;
    try {
      if (_customAudioPath.isNotEmpty && File(_customAudioPath).existsSync()) {
        await _player!.setFilePath(_customAudioPath);
      } else {
        await _player!.setAsset('assets/audio/$_soundName.mp3');
      }
      await _player!.setVolume(0.7);
      await _player!.play();
    } catch (_) {
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
    await _loopPlayer?.stop();
    await _loopPlayer?.dispose();
    await _player?.dispose();
    _player = null;
    _loopPlayer = null;
  }
}
