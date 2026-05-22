// App Router Configuration
//
// Responsibility:
// - Defines all application routes
// - Manages navigation paths and parameters
// - Provides named route references
// - Centralizes routing logic
//
// Routes are feature-oriented to support scalability.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../dependency_injection/injection.dart';
import '../../features/operator/bloc/operator_bloc.dart';
import '../../features/operator/screens/operator_screen.dart';
import '../../features/room/screens/waiting_room_screen.dart';
import '../../features/recorder/screens/recorder_screen.dart';
import '../../features/recorder/cubit/recorder_cubit.dart';

/// Placeholder screens - replace with actual screen imports when available
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () => context.go('/recorder'),
            child: const Text('Recorder'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () =>
                context.go('${RoutePaths.operator}?roomCode=ROOM-1001'),
            child: const Text('Operator'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go('/commenter'),
            child: const Text('Commenter'),
          ),
        ],
      ),
    ),
  );
}

class CommenterScreen extends StatelessWidget {
  const CommenterScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: Text('Commenter Screen')));
}

class JoinRoomScreen extends StatelessWidget {
  const JoinRoomScreen({super.key});
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
      builder: (BuildContext context, GoRouterState state) {
        return BlocProvider<RecorderCubit>(
          create: (_) => getIt<RecorderCubit>()..initialize(),
          child: const RecorderScreen(),
        );
      },
    ),
    GoRoute(
      path: '/waiting-room',
      name: 'waitingRoom',
      builder: (BuildContext context, GoRouterState state) =>
          const WaitingRoomScreen(),
    ),
    GoRoute(
      path: RoutePaths.operator,
      name: 'operator',
      builder: (BuildContext context, GoRouterState state) {
        final roomCode =
            state.uri.queryParameters['roomCode']?.trim().isNotEmpty == true
            ? state.uri.queryParameters['roomCode']!.trim()
            : 'ROOM-1001';

        return BlocProvider<OperatorBloc>(
          create: (_) =>
              getIt<OperatorBloc>()..add(OperatorStarted(roomCode: roomCode)),
          child: const OperatorScreen(),
        );
      },
    ),
    GoRoute(
      path: RoutePaths.commenter,
      name: 'commenter',
      builder: (BuildContext context, GoRouterState state) =>
          const CommenterScreen(),
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(child: Text('Route not found: ${state.uri.toString()}')),
  ),
);
