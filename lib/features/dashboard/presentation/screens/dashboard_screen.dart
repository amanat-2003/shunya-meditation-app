import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
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
    final lifetimeTaps = ref.watch(lifetimeTapsProvider);
    final streak = ref.watch(currentStreakProvider);
    final syncState = ref.watch(syncStateProvider);
    final dailyGoal = settings?.dailyTapGoal ?? 1080;

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
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 140,
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 140,
                              height: 140,
                              child: CircularProgressIndicator(
                                value: goalPercent,
                                strokeWidth: 8,
                                strokeCap: StrokeCap.round,
                                backgroundColor: AppTheme.dividerColor,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  goalPercent >= 1.0
                                      ? AppTheme.successGreen
                                      : AppTheme.primaryGold,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${(goalPercent * 100).round()}%',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  '$todayTaps / $dailyGoal',
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
}
