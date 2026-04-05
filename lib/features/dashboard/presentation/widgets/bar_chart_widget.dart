import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';

import '../../../../core/utils/time_utils.dart';

class WeeklyBarChart extends StatelessWidget {
  final Map<DateTime, int> weeklyData;
  final bool isTimeData;

  const WeeklyBarChart({
    super.key,
    required this.weeklyData,
    this.isTimeData = false,
  });

  @override
  Widget build(BuildContext context) {
    final entries = weeklyData.entries.toList();
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No data yet. Start a session!',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
        ),
      );
    }

    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final normalizedMax = maxY > 0 ? maxY.toDouble() : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: normalizedMax * 1.2,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => AppTheme.surfaceElevated,
            tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = entries[group.x.toInt()].key;
              final valString = isTimeData 
                  ? TimeUtils.formatDuration(rod.toY.toInt()) 
                  : '${rod.toY.toInt()} taps';
              
              return BarTooltipItem(
                '${DateFormat('EEE').format(date)}\n$valString',
                TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= entries.length) return const SizedBox();
                final date = entries[index].key;
                final isToday = _isToday(date);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('E').format(date).substring(0, 2),
                    style: TextStyle(
                      fontSize: 11,
                      color: isToday ? AppTheme.primaryGold : AppTheme.textMuted,
                      fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: entries.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value.value.toDouble();
          final isToday = _isToday(entry.value.key);

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value > 0 ? value : 0,
                width: 24,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: isToday
                      ? [
                          AppTheme.primaryGold.withValues(alpha: 0.5),
                          AppTheme.primaryGold,
                        ]
                      : [
                          AppTheme.primaryGold.withValues(alpha: 0.15),
                          AppTheme.primaryGold.withValues(alpha: 0.4),
                        ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
