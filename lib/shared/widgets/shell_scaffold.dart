import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';

class ShellScaffold extends StatelessWidget {
  final Widget child;

  const ShellScaffold({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/stats') return 1;
    if (location == '/settings') return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          context.go('/');
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/stats');
                break;
              case 2:
                context.go('/settings');
                break;
            }
          },
          backgroundColor: AppTheme.surfaceElevated,
          indicatorColor: AppTheme.primaryGold.withValues(alpha: 0.2),
          surfaceTintColor: Colors.transparent,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.home_rounded, color: AppTheme.primaryGold),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.insights_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.insights_rounded, color: AppTheme.primaryGold),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined, color: AppTheme.textSecondary),
              selectedIcon: Icon(Icons.settings_rounded, color: AppTheme.primaryGold),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
