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

    // Hide system UI
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Start the service
    final meditationService = ref.read(meditationServiceProvider);
    await meditationService.startSession();

    final settings = ref.read(userSettingsProvider);

    // Start audio reminders if enabled
    final audioService = ref.read(audioServiceProvider);
    await audioService.init();
    audioService.startReminders(
      enabled: settings?.audioReminderEnabled ?? false,
      soundName: settings?.audioReminderSound ?? 'om',
    );

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
      // Now the user needs to swipe up — but since long press just ended,
      // we give a small window for detection through the vertical drag
      // For simplicity, if exitReady is true when long press ends, end session
      _endSession();
    } else {
      setState(() {
        _isLongPressing = false;
        _exitProgress = 0.0;
      });
    }
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_exitReady && details.primaryVelocity != null && details.primaryVelocity! < -200) {
      _endSession();
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
    final session = await meditationService.endSession();

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
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: _onTapDown,
        onLongPressStart: _onLongPressStart,
        onLongPressEnd: _onLongPressEnd,
        onVerticalDragEnd: _onVerticalDragEnd,
        behavior: HitTestBehavior.opaque,
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Main content — very subtle to not disturb
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tap count — very dim
                    Text(
                      '$_tapCount',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.w200,
                        color: Colors.white.withValues(alpha: 0.06),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(_elapsedSeconds),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withValues(alpha: 0.04),
                      ),
                    ),
                  ],
                ),
              ),

              // Exit progress indicator
              if (_isLongPressing)
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: _exitProgress,
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _exitReady
                                ? AppTheme.successGreen.withValues(alpha: 0.5)
                                : AppTheme.primaryGold.withValues(alpha: 0.3),
                          ),
                          minHeight: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _exitReady ? 'Release & swipe up' : 'Hold to exit...',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),

              // Hint overlay
              if (_showHint) const HintOverlay(),
            ],
          ),
        ),
      ),
    );
  }
}
