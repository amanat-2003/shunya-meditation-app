import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class MonthlyHeatmap extends StatelessWidget {
  final Map<DateTime, int> frequency;

  const MonthlyHeatmap({super.key, required this.frequency});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    // Day labels
    const dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        // Day labels row
        Row(
          children: dayLabels.map((label) {
            return Expanded(
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 6),

        // Calendar grid
        ...List.generate(_getWeekCount(startingWeekday, daysInMonth), (weekIndex) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: List.generate(7, (dayOfWeek) {
                final dayNumber = weekIndex * 7 + dayOfWeek - startingWeekday + 1;

                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return Expanded(child: SizedBox(height: 36));
                }

                final date = DateTime(now.year, now.month, dayNumber);
                final sessionCount = _getSessionCount(date);
                final isToday = dayNumber == now.day;
                final isFuture = date.isAfter(now);

                return Expanded(
                  child: Container(
                    height: 36,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isFuture
                          ? Colors.transparent
                          : _getColorForCount(sessionCount),
                      borderRadius: BorderRadius.circular(8),
                      border: isToday
                          ? Border.all(
                              color: AppTheme.primaryGold.withValues(alpha: 0.6),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                          color: isFuture
                              ? AppTheme.textMuted.withValues(alpha: 0.3)
                              : sessionCount > 0
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : AppTheme.textMuted.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),

        const SizedBox(height: 12),

        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendItem(color: AppTheme.heatmapEmpty, label: 'None'),
            const SizedBox(width: 12),
            _LegendItem(color: AppTheme.heatmapLow, label: '1'),
            const SizedBox(width: 12),
            _LegendItem(color: AppTheme.heatmapMedium, label: '2'),
            const SizedBox(width: 12),
            _LegendItem(color: AppTheme.heatmapHigh, label: '3+'),
          ],
        ),
      ],
    );
  }

  int _getWeekCount(int startingWeekday, int daysInMonth) {
    return ((startingWeekday + daysInMonth + 6) / 7).floor();
  }

  int _getSessionCount(DateTime date) {
    for (final entry in frequency.entries) {
      if (entry.key.year == date.year &&
          entry.key.month == date.month &&
          entry.key.day == date.day) {
        return entry.value;
      }
    }
    return 0;
  }

  Color _getColorForCount(int count) {
    if (count <= 0) return AppTheme.heatmapEmpty;
    if (count == 1) return AppTheme.heatmapLow;
    if (count == 2) return AppTheme.heatmapMedium;
    return AppTheme.heatmapHigh;
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}
