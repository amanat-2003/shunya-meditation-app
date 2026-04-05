import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/providers/settings_providers.dart';
import '../../data/services/haptic_service.dart';
import '../../providers/meditation_providers.dart';
import '../widgets/hint_overlay.dart';

class MeditationScreen extends ConsumerStatefulWidget {
  const MeditationScreen({super.key});

  @override
  ConsumerState<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends ConsumerState<MeditationScreen> {
  int _tapCount = 0;
  int _elapsedSeconds = 0;
  Timer? _timerTick;
  bool _showHint = false;
  Timer? _hintTimer;

  // Exit gesture state
  bool _isLongPressing = false;
  bool _exitReady = false;
  Timer? _longPressTimer;
  double _exitProgress = 0.0;
  Timer? _exitProgressTimer;

  bool _sessionStarted = false;

  @override
  void initState() {
    super.initState();
    _initMeditationMode();
  }

  Future<void> _initMeditationMode() async {
    // Enable wakelock
    await WakelockPlus.enable();

    // Set minimum brightness
    try {
      await ScreenBrightness().setScreenBrightness(0.01);
    } catch (_) {}

    // Hide system UI — fully immersive, hides all bars and prevents pull-down
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Start the service
    final meditationService = ref.read(meditationServiceProvider);
    await meditationService.startSession();

    final settings = ref.read(userSettingsProvider);

    // Start audio reminders if enabled
    final audioService = ref.read(audioServiceProvider);
    await audioService.init();

    final customPath = settings?.customAudioPath ?? '';
    final soundName = settings?.audioReminderSound ?? 'om';

    audioService.startReminders(
      enabled: settings?.audioReminderEnabled ?? false,
      soundName: soundName,
      customAudioPath: customPath,
    );

    // Start continuous audio loop if enabled
    if (settings?.continuousAudioEnabled ?? false) {
      await audioService.startContinuousLoop(
        soundName: soundName,
        customAudioPath: customPath,
      );
    }

    meditationService.onTapRegistered = () {
      if (mounted) {
        setState(() {
          _tapCount = meditationService.tapCount;
        });
      }
    };

    meditationService.onShowHint = () {
      _showExitHint();
    };

    // Timer tick for elapsed time
    _timerTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsedSeconds = meditationService.elapsedSeconds;
        });
      }
    });

    setState(() => _sessionStarted = true);
  }

  void _showExitHint() {
    if (_showHint) return;
    setState(() => _showHint = true);
    _hintTimer?.cancel();
    _hintTimer = Timer(AppConstants.hintDisplayDuration, () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  void _onTapDown(TapDownDetails details) {
    if (!_sessionStarted) return;
    final meditationService = ref.read(meditationServiceProvider);
    meditationService.processTap();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isLongPressing = true;
      _exitProgress = 0.0;
    });

    // Start progress animation
    _exitProgressTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (mounted) {
        setState(() {
          _exitProgress = (_exitProgress + 0.05 / 3.0).clamp(0.0, 1.0);
        });
      }
    });

    // 3-second timer for exit readiness
    _longPressTimer = Timer(AppConstants.exitLongPressDuration, () {
      setState(() => _exitReady = true);
      HapticService.triggerExitReady();
    });
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _longPressTimer?.cancel();
    _exitProgressTimer?.cancel();

    if (_exitReady) {
      _endSession();
    } else {
      setState(() {
        _isLongPressing = false;
        _exitProgress = 0.0;
      });
    }
  }

  Future<void> _endSession() async {
    // Restore screen
    try {
      await ScreenBrightness().resetScreenBrightness();
    } catch (_) {}
    await WakelockPlus.disable();
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    _timerTick?.cancel();
    _hintTimer?.cancel();
    _longPressTimer?.cancel();
    _exitProgressTimer?.cancel();

    final meditationService = ref.read(meditationServiceProvider);
    final audioService = ref.read(audioServiceProvider);
    await audioService.stopContinuousLoop();
    final session = await meditationService.endSession();

    // Invalidate dashboard providers so they re-read fresh Hive data
    ref.invalidate(todayTapsProvider);
    ref.invalidate(todayTimeSecondsProvider);
    ref.invalidate(lifetimeTapsProvider);
    ref.invalidate(lifetimeTimeSecondsProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(weeklyTapsProvider);
    ref.invalidate(weeklyTimeSecondsProvider);
    ref.invalidate(monthlyFrequencyProvider);
    ref.invalidate(pendingSessionsCountProvider);

    if (mounted && session != null) {
      context.go('/meditate/summary', extra: {'sessionId': session.id});
    } else if (mounted) {
      context.go('/');
    }
  }

  @override
  void dispose() {
    _timerTick?.cancel();
    _hintTimer?.cancel();
    _longPressTimer?.cancel();
    _exitProgressTimer?.cancel();

    // Restore screen settings
    ScreenBrightness().resetScreenBrightness().catchError((_) {});
    WakelockPlus.disable().catchError((_) {});
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final isBrightMode = ref.watch(userSettingsProvider)?.brightModeEnabled ?? true;

    return PopScope(
      canPop: false, // Disable back button / swipe-to-go-back
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTapDown: _onTapDown,
          onLongPressStart: _onLongPressStart,
          onLongPressEnd: _onLongPressEnd,
          behavior: HitTestBehavior.opaque,
          child: SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Hint overlay — Absolute positioned at top
                if (_showHint)
                  Positioned(
                    top: 80,
                    child: HintOverlay(isBrightMode: isBrightMode),
                  ),

                // Main content
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                        // Tap count
                        Text(
                          '$_tapCount',
                          style: TextStyle(
                            fontSize: 72,
                            fontWeight: isBrightMode ? FontWeight.w500 : FontWeight.w200,
                            color: Colors.white.withValues(
                                alpha: isBrightMode ? 0.90 : 0.06),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTime(_elapsedSeconds),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: isBrightMode ? FontWeight.w400 : FontWeight.w300,
                            color: Colors.white.withValues(
                                alpha: isBrightMode ? 0.70 : 0.04),
                          ),
                        ),
                  ],
                ),

                // Exit progress indicator
                if (_isLongPressing)
                  Positioned(
                    bottom: 60,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            value: _exitProgress,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _exitReady
                                  ? AppTheme.successGreen
                                  : AppTheme.primaryGold,
                            ),
                            minHeight: 6,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _exitReady ? 'Release to exit' : 'Hold to exit...',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
