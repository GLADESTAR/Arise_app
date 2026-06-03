import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/achievement_popup.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/tasks/presentation/screens/tasks_screen.dart';
import 'features/habits/presentation/screens/habits_screen.dart';
import 'features/player/presentation/screens/stats_screen.dart';
import 'features/analytics/presentation/screens/analytics_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/habits/presentation/providers/habit_provider.dart';
import 'features/calendar/presentation/screens/calendar_screen.dart';

class AriseApp extends ConsumerWidget {
  const AriseApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) => const TasksScreen(),
        ),
        GoRoute(
          path: '/habits',
          builder: (context, state) => const HabitsScreen(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
        GoRoute(
  path: '/calendar',
  builder: (context, state) => const CalendarScreen(),
),
      ],
    ),
  ],
);

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _routes = [
    '/', '/tasks', '/habits', '/stats', '/analytics','/calendar'
  ];

  int _indexForLocation(String location) {
    for (int i = 0; i < _routes.length; i++) {
      if (_routes[i] == '/' && location == '/') return 0;
      if (_routes[i] != '/' && location.startsWith(_routes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexForLocation(location);

    return Consumer(
      builder: (context, ref, _) {
        final achievementState = ref.watch(achievementProvider);
        final newlyUnlocked = achievementState.newlyUnlocked;

        return AchievementPopupOverlay(
          achievements: newlyUnlocked,
          onDismissed: () =>
              ref.read(achievementProvider.notifier).clearNewlyUnlocked(),
          child: Scaffold(
            body: child,
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: AppColors.surfaceBorder, width: 0.5),
                ),
              ),
              child: NavigationBar(
                selectedIndex: currentIndex,
                onDestinationSelected: (index) =>
                    context.go(_routes[index]),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home),
                    label: AppStrings.navDashboard,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.assignment_outlined),
                    selectedIcon: Icon(Icons.assignment),
                    label: AppStrings.navTasks,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.loop_outlined),
                    selectedIcon: Icon(Icons.loop),
                    label: AppStrings.navHabits,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.person_outlined),
                    selectedIcon: Icon(Icons.person),
                    label: AppStrings.navStats,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart_outlined),
                    selectedIcon: Icon(Icons.bar_chart),
                    label: AppStrings.navAnalytics,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.calendar_today_outlined),
                    selectedIcon: Icon(Icons.calendar_today),
                    label: AppStrings.navCalendar,
                  ),
                ],
              ),
            ),
            // Settings reachable via floating button on dashboard
            // or add it to app bar actions
          ),
        );
      },
    );
  }
}