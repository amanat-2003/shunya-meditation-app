import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../sync/providers/sync_providers.dart';

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

      bool usedCustom = false;
      if (customAudioPath.isNotEmpty) {
        if (File(customAudioPath).existsSync()) {
          try {
            await _loopPlayer!.setFilePath(customAudioPath);
            usedCustom = true;
          } catch (e) {
            _notifyCustomAudioFailure();
          }
        } else {
          _notifyCustomAudioFailure();
        }
      }

      if (!usedCustom) {
        await _loopPlayer!.setAsset('assets/audio/$soundName.mp3');
      }

      await _loopPlayer!.setLoopMode(LoopMode.one); // Infinite loop
      await _loopPlayer!.setVolume(1.0); // Full capacity
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
      bool usedCustom = false;
      if (_customAudioPath.isNotEmpty) {
        if (File(_customAudioPath).existsSync()) {
          try {
            await _player!.setFilePath(_customAudioPath);
            usedCustom = true;
          } catch (e) {
            _notifyCustomAudioFailure();
            _customAudioPath = ''; // clear it so we don't repeatedly fail on reminders
          }
        } else {
          _notifyCustomAudioFailure();
          _customAudioPath = '';
        }
      }

      if (!usedCustom) {
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

  /// Notify user if custom audio is corrupt or missing
  void _notifyCustomAudioFailure() {
    final messenger = syncScaffoldMessengerKey.currentState;
    if (messenger != null) {
      messenger.clearSnackBars();
      messenger.showSnackBar(
        SnackBar(
          content: const Text(
            'Custom audio file not found or corrupted. Using default sound.',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFFE57373),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
