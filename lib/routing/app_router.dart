import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/onboarding/presentation/views/splash_screen.dart';
import '../features/onboarding/presentation/views/login_screen.dart';
import '../features/onboarding/presentation/views/register_screen.dart';
import '../features/home/presentation/views/home_screen.dart';
import '../features/home/presentation/views/create_screen.dart';
import '../features/home/presentation/views/coffee_screen.dart';
import '../features/home/presentation/views/notifications_screen.dart';
import '../features/restaurant_detail/presentation/views/detail_screen.dart';
import '../features/explore/presentation/views/ai_screen.dart';
import '../features/saved/presentation/views/events_screen.dart';
import '../features/profile/presentation/views/profile_screen.dart';
import '../features/profile/presentation/views/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  // DEMO modu — sunum için oturum kontrolü devre dışı
  redirect: (context, state) => null,
  routes: [
    // ── Onboarding ────────────────────────────────────────
    GoRoute(path: '/splash',   builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),

    // ── Modal (push üstüne gelir) ─────────────────────────
    GoRoute(path: '/create',        builder: (_, __) => const CreateScreen()),
    GoRoute(path: '/coffee',        builder: (_, __) => const CoffeeScreen()),
    GoRoute(path: '/detail',        builder: (_, __) => const DetailScreen()),
    GoRoute(path: '/notifications', builder: (_, __) => const NotificationsScreen()),
    GoRoute(path: '/settings',      builder: (_, __) => const SettingsScreen()),
    // AI'ı hem tab hem push olarak açabilmek için standalone route
    GoRoute(
      path: '/ai-select',
      builder: (_, __) => const AiScreen(selectionMode: true),
    ),

    // ── Ana shell — bottom nav ────────────────────────────
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => _MainShell(shell: shell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/home',    builder: (_, __) => const HomeScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/events',  builder: (_, __) => const EventsScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/ai',      builder: (_, __) => const AiScreen()),
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
