import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_providers.dart';
import '../../sync/providers/sync_providers.dart';
import '../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(userSettingsProvider);
    final settingsNotifier = ref.read(userSettingsProvider.notifier);
    final syncState = ref.watch(syncStateProvider);

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
                  'Settings',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ),

            // Daily Goals section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Daily Goals'),
                    const SizedBox(height: 12),

                    // Tap goal
                    _SettingsCard(
                      icon: Icons.touch_app_rounded,
                      title: 'Daily Tap Goal',
                      subtitle: '${settings?.dailyTapGoal ?? 1080} taps',
                      trailing: SizedBox(
                        width: 200,
                        child: Slider(
                          value: (settings?.dailyTapGoal ?? 1080).toDouble(),
                          min: 108,
                          max: 10800,
                          divisions: 99,
                          activeColor: AppTheme.primaryGold,
                          inactiveColor: AppTheme.dividerColor,
                          onChanged: (value) {
                            settingsNotifier.setDailyTapGoal(value.round());
                          },
                        ),
                      ),
                    ),

                    // Time goal
                    _SettingsCard(
                      icon: Icons.timer_outlined,
                      title: 'Daily Time Goal',
                      subtitle: '${((settings?.dailyTimeGoalSeconds ?? 600) / 60).round()} minutes',
                      trailing: SizedBox(
                        width: 200,
                        child: Slider(
                          value: ((settings?.dailyTimeGoalSeconds ?? 600) / 60).roundToDouble(),
                          min: 5,
                          max: 120,
                          divisions: 23,
                          activeColor: AppTheme.primaryGold,
                          inactiveColor: AppTheme.dividerColor,
                          onChanged: (value) {
                            settingsNotifier.setDailyTimeGoal((value * 60).round());
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Haptic & Audio section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Meditation'),
                    const SizedBox(height: 12),

                    // Haptic interval
                    _SettingsCard(
                      icon: Icons.vibration_rounded,
                      title: 'Haptic Feedback Interval',
                      subtitle: 'Every ${settings?.hapticInterval ?? 1} tap${(settings?.hapticInterval ?? 1) > 1 ? 's' : ''}',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceElevated,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: DropdownButton<int>(
                          value: settings?.hapticInterval ?? 1,
                          dropdownColor: AppTheme.surfaceElevated,
                          underline: const SizedBox(),
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                          ),
                          items: AppConstants.hapticIntervalOptions.map((interval) {
                            return DropdownMenuItem(
                              value: interval,
                              child: Text('$interval'),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              settingsNotifier.setHapticInterval(value);
                            }
                          },
                        ),
                      ),
                    ),

                    // Audio reminders
                    _SettingsCard(
                      icon: Icons.music_note_rounded,
                      title: 'Audio Reminders',
                      subtitle: settings?.audioReminderEnabled == true
                          ? 'Play "${settings?.audioReminderSound ?? 'om'}" every 8-15 min'
                          : 'Disabled',
                      trailing: Switch(
                        value: settings?.audioReminderEnabled ?? false,
                        activeTrackColor: AppTheme.primaryGold,
                        onChanged: (value) {
                          settingsNotifier.setAudioReminderEnabled(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sync section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Data'),
                    const SizedBox(height: 12),

                    _SettingsCard(
                      icon: Icons.cloud_sync_rounded,
                      title: 'Sync Status',
                      subtitle: syncState.pendingCount > 0
                          ? '${syncState.pendingCount} session${syncState.pendingCount > 1 ? 's' : ''} pending'
                          : 'All data synced',
                      trailing: syncState.isSyncing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.primaryGold,
                              ),
                            )
                          : syncState.pendingCount > 0
                              ? TextButton(
                                  onPressed: () {
                                    ref.read(syncStateProvider.notifier).syncAll();
                                  },
                                  child: Text(
                                    'Sync',
                                    style: TextStyle(color: AppTheme.primaryGold),
                                  ),
                                )
                              : Icon(
                                  Icons.check_circle_rounded,
                                  color: AppTheme.successGreen,
                                  size: 20,
                                ),
                    ),
                  ],
                ),
              ),
            ),

            // Account section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('Account'),
                    const SizedBox(height: 12),

                    GestureDetector(
                      onTap: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.surfaceElevated,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            title: Text(
                              'Sign Out?',
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                            content: Text(
                              'Make sure your sessions are synced before signing out.',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: AppTheme.textMuted),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.errorRed,
                                ),
                                child: const Text('Sign Out'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await ref.read(authRepositoryProvider).signOut();
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.errorRed.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.logout_rounded, color: AppTheme.errorRed, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              'Sign Out',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.errorRed,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Version
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
                child: Center(
                  child: Text(
                    'Shunya v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.textMuted.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppTheme.textMuted,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.primaryGold, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
