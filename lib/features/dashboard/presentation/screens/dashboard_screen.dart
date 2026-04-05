import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_utils.dart';
import '../../../auth/providers/auth_providers.dart';
import '../../../meditation/providers/meditation_providers.dart';
import '../../../settings/providers/settings_providers.dart';
import '../../../sync/providers/sync_providers.dart';
import '../widgets/quote_card.dart';
import '../widgets/stats_cards.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final PageController _progressPageController = PageController();
  int _progressPageIndex = 0;

  @override
  void dispose() {
    _progressPageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Initialize data on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    final syncNotifier = ref.read(syncStateProvider.notifier);
    final userId = ref.read(currentUserProvider)?.id;

    // 1. If fresh install, aggressively sync down data from cloud FIRST
    await syncNotifier.syncDownIfFreshInstall(userId);
    
    // Invalidate cached providers so the UI updates instantly with the new data
    ref.invalidate(userSessionsProvider);
    ref.invalidate(todayTapsProvider);
    ref.invalidate(todayTimeSecondsProvider);
    ref.invalidate(lifetimeTapsProvider);
    ref.invalidate(lifetimeTimeSecondsProvider);
    ref.invalidate(currentStreakProvider);
    ref.invalidate(weeklyTapsProvider);
    ref.invalidate(weeklyTimeSecondsProvider);
    ref.invalidate(monthlyFrequencyProvider);
    ref.invalidate(userSettingsProvider);

    // 2. Check for offline sessions pending upload
    final hasPending = await syncNotifier.hasPendingSessions();
    if (hasPending && mounted) {
      _showPendingSessionDialog();
    }
    
    // 3. Attempt background sync up
    syncNotifier.syncAll(showNotification: false);
  }

  void _showPendingSessionDialog() {
    final pendingCount = ref.read(pendingSessionsCountProvider);
    if (pendingCount == 0) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.cloud_upload_outlined, color: AppTheme.primaryGold, size: 22),
            const SizedBox(width: 10),
            Text(
              'Unsaved Sessions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'You have $pendingCount session${pendingCount > 1 ? 's' : ''} waiting to be synced to the cloud.',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(syncStateProvider.notifier).syncAll(showNotification: true);
            },
            child: const Text('Sync Now'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final settings = ref.watch(userSettingsProvider);
    final todayTaps = ref.watch(todayTapsProvider);
    final todaySeconds = ref.watch(todayTimeSecondsProvider);
    final lifetimeTaps = ref.watch(lifetimeTapsProvider);
    final streak = ref.watch(currentStreakProvider);
    final syncState = ref.watch(syncStateProvider);
    
    final dailyGoal = settings?.dailyTapGoal ?? 1080;
    final timeGoalSeconds = settings?.dailyTimeGoalSeconds ?? 600;

    final goalPercent = dailyGoal > 0 ? (todayTaps / dailyGoal).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textMuted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.userMetadata?['full_name'] as String? ??
                              user?.email?.split('@').first ??
                              'Seeker',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Sync indicator
                    if (syncState.pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.accentWarm.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              syncState.isSyncing ? Icons.sync_rounded : Icons.cloud_upload_outlined,
                              size: 14,
                              color: AppTheme.accentWarm,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${syncState.pendingCount}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppTheme.accentWarm,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Quote
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: QuoteCard(quote: AppConstants.getQuoteOfTheDay()),
              ),
            ),

            // Daily progress circle
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Today\'s Progress',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 160,
                        child: PageView(
                          controller: _progressPageController,
                          onPageChanged: (index) {
                            setState(() {
                              _progressPageIndex = index;
                            });
                          },
                          children: [
                            // PAGE 1: Taps Progress
                            _buildProgressCircle(
                              percent: goalPercent,
                              valueStr: '${(goalPercent * 100).round()}%',
                              subText: '$todayTaps / $dailyGoal taps',
                              color: goalPercent >= 1.0 ? AppTheme.successGreen : AppTheme.primaryGold,
                            ),
                            // PAGE 2: Time Progress
                            _buildProgressCircle(
                              percent: timeGoalSeconds > 0 ? (todaySeconds / timeGoalSeconds).clamp(0.0, 1.0) : 0.0,
                              valueStr: '${(timeGoalSeconds > 0 ? (todaySeconds / timeGoalSeconds).clamp(0.0, 1.0) * 100 : 0.0).round()}%',
                              subText: '${TimeUtils.formatDuration(todaySeconds)} / ${TimeUtils.formatDuration(timeGoalSeconds)}',
                              color: (timeGoalSeconds > 0 && todaySeconds >= timeGoalSeconds) ? AppTheme.successGreen : AppTheme.accentWarm,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildPageDot(0),
                          const SizedBox(width: 8),
                          _buildPageDot(1),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Stats cards
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: StatsCards(
                  lifetimeTaps: lifetimeTaps,
                  currentStreak: streak,
                  todayTaps: todayTaps,
                  lifetimeTimeSeconds: ref.watch(lifetimeTimeSecondsProvider),
                  todayTimeSeconds: todaySeconds,
                ),
              ),
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 64,
        height: 64,
        margin: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton(
          onPressed: () => context.push('/meditate'),
          backgroundColor: AppTheme.primaryGold,
          foregroundColor: Colors.black,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(Icons.self_improvement_rounded, size: 30),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 5) return 'Good night';
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildProgressCircle({
    required double percent,
    required String valueStr,
    required String subText,
    required Color color,
  }) {
    return Center(
      child: SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 8,
                strokeCap: StrokeCap.round,
                backgroundColor: AppTheme.dividerColor,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  valueStr,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subText,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageDot(int index) {
    final isActive = _progressPageIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 6,
      width: isActive ? 16 : 6,
      decoration: BoxDecoration(
        color: isActive ? AppTheme.primaryGold : AppTheme.dividerColor,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
