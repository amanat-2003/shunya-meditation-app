import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/time_utils.dart';

class StatsCards extends StatelessWidget {
  final int lifetimeTaps;
  final int currentStreak;
  final int todayTaps;
  final int lifetimeTimeSeconds;
  final int todayTimeSeconds;

  const StatsCards({
    super.key,
    required this.lifetimeTaps,
    required this.currentStreak,
    required this.todayTaps,
    required this.lifetimeTimeSeconds,
    required this.todayTimeSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          SizedBox(
            width: 105,
            child: _MiniStatCard(
              icon: Icons.touch_app_rounded,
              iconColor: AppTheme.primaryGold,
              label: 'Total Taps',
              value: _formatCount(lifetimeTaps),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: _MiniStatCard(
              icon: Icons.local_fire_department_rounded,
              iconColor: AppTheme.accentWarm,
              label: 'Streak',
              value: '$currentStreak day${currentStreak != 1 ? 's' : ''}',
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: _MiniStatCard(
              icon: Icons.today_rounded,
              iconColor: AppTheme.successGreen,
              label: 'Today Taps',
              value: _formatCount(todayTaps),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: _MiniStatCard(
              icon: Icons.timer_rounded,
              iconColor: AppTheme.primaryGold,
              label: 'Total Time',
              value: TimeUtils.formatDuration(lifetimeTimeSeconds),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 105,
            child: _MiniStatCard(
              icon: Icons.access_time_rounded,
              iconColor: AppTheme.successGreen,
              label: 'Today Time',
              value: TimeUtils.formatDuration(todayTimeSeconds),
            ),
          ),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _MiniStatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _MiniStatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
