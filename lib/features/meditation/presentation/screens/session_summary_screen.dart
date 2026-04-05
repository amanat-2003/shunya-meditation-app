import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../sync/providers/sync_providers.dart';
import '../../providers/meditation_providers.dart';

class SessionSummaryScreen extends ConsumerStatefulWidget {
  final String sessionId;

  const SessionSummaryScreen({super.key, required this.sessionId});

  @override
  ConsumerState<SessionSummaryScreen> createState() => _SessionSummaryScreenState();
}

class _SessionSummaryScreenState extends ConsumerState<SessionSummaryScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    );
    _animController.forward();

    // Auto-sync
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncStateProvider.notifier).syncAll();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(meditationRepositoryProvider);
    final session = repo.getSession(widget.sessionId);
    final syncState = ref.watch(syncStateProvider);

    if (session == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Session not found',
            style: TextStyle(color: AppTheme.textMuted),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 40),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Text(
                  'Session Complete',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryGold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Main tap count
              ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    Text(
                      '${session.totalTaps}',
                      style: TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w200,
                        color: AppTheme.textPrimary,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'taps',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Stats row
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.timer_outlined,
                            label: 'Duration',
                            value: _formatDuration(session.durationSeconds),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.speed_rounded,
                            label: 'Avg Rate',
                            value: session.durationSeconds > 0
                                ? '${(session.totalTaps / (session.durationSeconds / 60)).toStringAsFixed(1)}/min'
                                : '—',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Sync status
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            syncState.isSyncing
                                ? Icons.sync_rounded
                                : session.syncStatus == 'synced'
                                    ? Icons.cloud_done_rounded
                                    : Icons.cloud_upload_outlined,
                            size: 18,
                            color: session.syncStatus == 'synced'
                                ? AppTheme.successGreen
                                : AppTheme.primaryGold,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            syncState.isSyncing
                                ? 'Syncing...'
                                : session.syncStatus == 'synced'
                                    ? 'Saved to cloud'
                                    : 'Saved locally · Will sync when online',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Return button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // Invalidate providers so dashboard re-reads fresh Hive data
                    ref.invalidate(meditationRepositoryProvider);
                    context.go('/');
                  },
                  child: const Text('Return to Dashboard'),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.textMuted),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
