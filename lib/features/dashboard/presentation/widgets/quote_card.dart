import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class QuoteCard extends StatelessWidget {
  final String quote;

  const QuoteCard({super.key, required this.quote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGold.withValues(alpha: 0.06),
            AppTheme.accentWarm.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryGold.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.format_quote_rounded,
            color: AppTheme.primaryGold.withValues(alpha: 0.4),
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            quote,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
