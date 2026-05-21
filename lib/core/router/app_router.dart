/// App Router Configuration
///
/// Responsibility:
/// - Defines all application routes
/// - Manages navigation paths and parameters
/// - Provides named route references
/// - Centralizes routing logic
///
/// Routes are feature-oriented to support scalability.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Placeholder screens - replace with actual screen imports
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Home Screen')));
}

class RecorderScreen extends StatelessWidget {
  const RecorderScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Recorder Screen')));
}

class OperatorScreen extends StatelessWidget {
  const OperatorScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Operator Screen')));
}

class CommenterScreen extends StatelessWidget {
  const CommenterScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Commenter Screen')));
}

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Join Room Screen')));
}

/// Route paths as constants for type-safe navigation
class RoutePaths {
  static const String home = '/';
  static const String joinRoom = '/join-room';
  static const String recorder = '/recorder';
  static const String operator = '/operator';
  static const String commenter = '/commenter';
}

/// GoRouter configuration
///
/// Central navigation hub for the application.
/// Provides all route definitions and navigation rules.
final appRouter = GoRouter(
  initialLocation: RoutePaths.home,
  routes: <RouteBase>[
    GoRoute(
      path: RoutePaths.home,
      name: 'home',
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: RoutePaths.joinRoom,
      name: 'joinRoom',
      builder: (BuildContext context, GoRouterState state) =>
          const JoinRoomScreen(),
    ),
    GoRoute(
      path: RoutePaths.recorder,
      name: 'recorder',
      builder: (BuildContext context, GoRouterState state) =>
          const RecorderScreen(),
    ),
    GoRoute(
      path: RoutePaths.operator,
      name: 'operator',
      builder: (BuildContext context, GoRouterState state) =>
          const OperatorScreen(),
    ),
    GoRoute(
      path: RoutePaths.commenter,
      name: 'commenter',
      builder: (BuildContext context, GoRouterState state) =>
          const CommenterScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text('Route not found: ${state.location}'))),
);
