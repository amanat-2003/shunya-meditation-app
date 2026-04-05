
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../meditation/providers/meditation_providers.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/heatmap_widget.dart';
import '../widgets/stats_cards.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifetimeTaps = ref.watch(lifetimeTapsProvider);
    final streak = ref.watch(currentStreakProvider);
    final weeklyTaps = ref.watch(weeklyTapsProvider);
    final weeklyTime = ref.watch(weeklyTimeSecondsProvider);
    final monthlyFrequency = ref.watch(monthlyFrequencyProvider);
    final todayTaps = ref.watch(todayTapsProvider);
    final lifetimeTime = ref.watch(lifetimeTimeSecondsProvider);
    final todayTime = ref.watch(todayTimeSecondsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),

            // Quick stats row
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: StatsCards(
                  lifetimeTaps: lifetimeTaps,
                  currentStreak: streak,
                  todayTaps: todayTaps,
                  lifetimeTimeSeconds: lifetimeTime,
                  todayTimeSeconds: todayTime,
                ),
              ),
            ),

            // Weekly bar chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'This Week',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Taps per day',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: WeeklyBarChart(weeklyData: weeklyTaps),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'Time per day',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 180,
                        child: WeeklyBarChart(weeklyData: weeklyTime, isTimeData: true),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Monthly heatmap
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceCard,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMMM yyyy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Meditation sessions frequency',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 16),
                      MonthlyHeatmap(frequency: monthlyFrequency),
                    ],
                  ),
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
    );
  }

}
