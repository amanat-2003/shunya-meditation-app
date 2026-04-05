import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/meditation_session.dart';
import '../repositories/meditation_repository.dart';
import 'audio_service.dart';
import 'haptic_service.dart';

class MeditationService with WidgetsBindingObserver {
  final MeditationRepository _repository;
  final AudioService _audioService;
  final String _userId;

  MeditationSession? _currentSession;
  final Stopwatch _stopwatch = Stopwatch();
  DateTime? _lastTapTime;
  int _hapticInterval;
  final String _hapticIntensity;

  // Rapid tap detection
  final List<DateTime> _recentTaps = [];

  // Callbacks
  VoidCallback? onTapRegistered;
  VoidCallback? onShowHint;
  VoidCallback? onSessionSaved;

  MeditationService({
    required MeditationRepository repository,
    required AudioService audioService,
    required String userId,
    int hapticInterval = 1,
    String hapticIntensity = 'light',
  })  : _repository = repository,
        _audioService = audioService,
        _userId = userId,
        _hapticInterval = hapticInterval,
        _hapticIntensity = hapticIntensity;

  MeditationSession? get currentSession => _currentSession;
  int get tapCount => _currentSession?.totalTaps ?? 0;
  int get elapsedSeconds => _stopwatch.elapsed.inSeconds;
  bool get isActive => _stopwatch.isRunning;

  /// Start a new meditation session
  Future<void> startSession() async {
    const uuid = Uuid();
    _currentSession = MeditationSession(
      id: uuid.v4(),
      userId: _userId,
      totalTaps: 0,
      durationSeconds: 0,
      goalReached: false,
      syncStatus: 'pending',
    );

    _stopwatch.reset();
    _stopwatch.start();
    _recentTaps.clear();

    // Register lifecycle observer
    WidgetsBinding.instance.addObserver(this);

    // Save initial session
    await _repository.saveSessionLocally(_currentSession!);
  }

  /// Process a tap event (returns true if tap was registered)
  bool processTap() {
    if (_currentSession == null || !_stopwatch.isRunning) return false;

    final now = DateTime.now();

    // Apply 150ms throttle
    if (_lastTapTime != null &&
        now.difference(_lastTapTime!) < AppConstants.tapThrottleDuration) {
      return false;
    }

    _lastTapTime = now;
    _currentSession!.totalTaps++;
    _currentSession!.durationSeconds = _stopwatch.elapsed.inSeconds;

    // Trigger haptic feedback
    HapticService.triggerTapFeedback(
      _currentSession!.totalTaps,
      _hapticInterval,
      intensity: _hapticIntensity,
    );

    // Track rapid taps for hint display
    _recentTaps.add(now);
    _recentTaps.removeWhere(
      (t) => now.difference(t) > AppConstants.rapidTapWindow,
    );
    if (_recentTaps.length >= AppConstants.rapidTapThreshold) {
      onShowHint?.call();
      _recentTaps.clear();
    }

    // Auto-save every N taps
    if (_currentSession!.totalTaps % AppConstants.autoSaveInterval == 0) {
      _saveProgress();
    }

    onTapRegistered?.call();
    return true;
  }

  /// Save current progress to Hive
  Future<void> _saveProgress() async {
    if (_currentSession == null) return;
    _currentSession!.durationSeconds = _stopwatch.elapsed.inSeconds;
    await _repository.saveSessionLocally(_currentSession!);
    onSessionSaved?.call();
  }

  /// Pause the session (e.g., when app loses focus)
  Future<void> pauseSession() async {
    _stopwatch.stop();
    await _saveProgress();
  }

  /// Resume the session
  void resumeSession() {
    _stopwatch.start();
  }

  /// End the session and return the final session data
  Future<MeditationSession?> endSession({bool goalReached = false}) async {
    if (_currentSession == null) return null;

    _stopwatch.stop();
    _currentSession!.durationSeconds = _stopwatch.elapsed.inSeconds;
    _currentSession!.goalReached = goalReached;

    await _repository.saveSessionLocally(_currentSession!);
    _audioService.stopReminders();

    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);

    final session = _currentSession!;
    _currentSession = null;
    _stopwatch.reset();
    _lastTapTime = null;
    _recentTaps.clear();

    return session;
  }

  /// Update haptic interval
  void setHapticInterval(int interval) {
    _hapticInterval = interval;
  }

  /// Handle app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        // Immediately save progress when app loses focus
        pauseSession();
        break;
      case AppLifecycleState.resumed:
        if (_currentSession != null) {
          resumeSession();
        }
        break;
      default:
        break;
    }
  }

  /// Dispose of resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopwatch.stop();
  }
}
