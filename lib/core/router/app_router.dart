import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halkaarzbilgi/core/widgets/app_bottom_nav_bar.dart';
import 'package:halkaarzbilgi/features/auth/welcome_screen.dart';
import 'package:halkaarzbilgi/features/auth/register_screen.dart';
import 'package:halkaarzbilgi/features/auth/forgot_password_screen.dart';
import 'package:halkaarzbilgi/features/auth/login_screen.dart';
import 'package:halkaarzbilgi/features/home/home_screen.dart';
import 'package:halkaarzbilgi/features/news/news_screen.dart';
import 'package:halkaarzbilgi/features/notifications/notification_settings_screen.dart';
import 'package:halkaarzbilgi/features/search/search_screen.dart';
import 'package:halkaarzbilgi/features/stock_detail/stock_detail_screen.dart';
import 'package:halkaarzbilgi/features/ipo_detail/ipo_detail_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/welcome',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/stock/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return StockDetailScreen(id: id);
      },
    ),
    GoRoute(
      path: '/ipo/:symbol',
      builder: (context, state) {
        final symbol = state.pathParameters['symbol']!;
        return IpoDetailScreen(symbol: symbol);
      },
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return AppBottomNavBar(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/news',
              builder: (context, state) => const NewsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/notifications',
              builder: (context, state) => const NotificationSettingsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/search',
              builder: (context, state) => const SearchScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
