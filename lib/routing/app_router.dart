import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../di/injection_container.dart';
import '../features/onboarding/presentation/views/splash_screen.dart';
import '../features/onboarding/presentation/views/login_screen.dart';
import '../features/home/presentation/views/home_screen.dart';
import '../features/home/presentation/views/create_screen.dart';
import '../features/home/presentation/views/coffee_screen.dart';
import '../features/restaurant_detail/presentation/views/detail_screen.dart';
import '../features/explore/presentation/views/ai_screen.dart';
import '../features/saved/presentation/views/events_screen.dart';
import '../features/profile/presentation/views/profile_screen.dart';
import '../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',  builder: (_, __) => const LoginScreen()),

    // Modal routes (push on top of shell)
    GoRoute(path: '/create', builder: (_, __) => const CreateScreen()),
    GoRoute(path: '/coffee', builder: (_, __) => const CoffeeScreen()),
    GoRoute(path: '/detail', builder: (_, __) => const DetailScreen()),

    // Main shell with bottom nav
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _MainShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/events', builder: (_, __) => const EventsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/ai', builder: (_, __) => const AiScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        ]),
      ],
    ),
  ],
);

class _MainShell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const _MainShell({required this.shell});

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Ana Sayfa',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_today_outlined),
      selectedIcon: Icon(Icons.calendar_today_rounded),
      label: 'Etkinlikler',
    ),
    NavigationDestination(
      icon: Icon(Icons.auto_awesome_outlined),
      selectedIcon: Icon(Icons.auto_awesome_rounded),
      label: 'AI Öneri',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: _destinations,
      ),
    );
  }
}
