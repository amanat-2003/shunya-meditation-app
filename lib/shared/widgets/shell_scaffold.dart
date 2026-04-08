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

  void _onDestinationSelected(BuildContext context, int index) {
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
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _currentIndex(context);
    final isWide = MediaQuery.sizeOf(context).width >= 800;

    return PopScope(
      canPop: currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && currentIndex != 0) {
          context.go('/');
        }
      },
      child: Scaffold(
        body: isWide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: currentIndex,
                    onDestinationSelected: (i) =>
                        _onDestinationSelected(context, i),
                    backgroundColor: AppTheme.surfaceElevated,
                    indicatorColor:
                        AppTheme.primaryGold.withValues(alpha: 0.2),
                    labelType: NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 24),
                      child: Text(
                        'शून्य',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryGold,
                        ),
                      ),
                    ),
                    destinations: [
                      NavigationRailDestination(
                        icon: Icon(Icons.home_outlined,
                            color: AppTheme.textSecondary),
                        selectedIcon: Icon(Icons.home_rounded,
                            color: AppTheme.primaryGold),
                        label: const Text('Home'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.insights_outlined,
                            color: AppTheme.textSecondary),
                        selectedIcon: Icon(Icons.insights_rounded,
                            color: AppTheme.primaryGold),
                        label: const Text('Stats'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.settings_outlined,
                            color: AppTheme.textSecondary),
                        selectedIcon: Icon(Icons.settings_rounded,
                            color: AppTheme.primaryGold),
                        label: const Text('Settings'),
                      ),
                    ],
                  ),
                  const VerticalDivider(
                    width: 1,
                    color: AppTheme.dividerColor,
                  ),
                  Expanded(child: child),
                ],
              )
            : child,
        bottomNavigationBar: isWide
            ? null
            : NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (i) =>
                    _onDestinationSelected(context, i),
                backgroundColor: AppTheme.surfaceElevated,
                indicatorColor:
                    AppTheme.primaryGold.withValues(alpha: 0.2),
                surfaceTintColor: Colors.transparent,
                height: 68,
                labelBehavior:
                    NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined,
                        color: AppTheme.textSecondary),
                    selectedIcon: Icon(Icons.home_rounded,
                        color: AppTheme.primaryGold),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.insights_outlined,
                        color: AppTheme.textSecondary),
                    selectedIcon: Icon(Icons.insights_rounded,
                        color: AppTheme.primaryGold),
                    label: 'Stats',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.settings_outlined,
                        color: AppTheme.textSecondary),
                    selectedIcon: Icon(Icons.settings_rounded,
                        color: AppTheme.primaryGold),
                    label: 'Settings',
                  ),
                ],
              ),
      ),
    );
  }
}

