/// Dependency Injection Container
///
/// Responsibility:
/// - Registers all application dependencies
/// - Manages singleton instances
/// - Provides dependency resolution
/// - Centralizes service instantiation
///
/// Using GetIt for service locator pattern.
/// Initialized in main.dart before app bootstrap.

import 'package:get_it/get_it.dart';
import '../socket/socket_service.dart';
import '../../features/operator/bloc/operator_bloc.dart';
import '../../features/operator/repository/operator_repository.dart';
import '../../features/recorder/cubit/recorder_cubit.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
///
/// Called once during app startup in main.dart
/// Sets up all services, repositories, blocs, and cubits
Future<void> setupDependencies() async {
  // ============================================
  // Core Services
  // ============================================

  // Socket Service - singleton for realtime communication
  getIt.registerSingleton<SocketService>(SocketService());

  // Operator Repository - socket-backed control channel
  getIt.registerSingleton<OperatorRepository>(
    OperatorRepository(socketService: getIt<SocketService>()),
  );

  // ============================================
  // Repositories
  // ============================================

  // Room Repository - placeholder
  // getIt.registerSingleton<RoomRepository>(
  //   RoomRepository(socketService: getIt<SocketService>()),
  // );

  // ============================================
  // BLoCs - Feature orchestration
  // ============================================

  // Room Bloc - manages room state and socket synchronization
  // getIt.registerSingleton<RoomBloc>(
  //   RoomBloc(repository: getIt<RoomRepository>()),
  // );

  // ============================================
  // Cubits - Local UI state
  // ============================================

  // Recorder Cubit - manages recorder local state
  // Provide a factory so callers (screens) receive a fresh cubit instance
  getIt.registerFactory<RecorderCubit>(
    () => RecorderCubit(socketService: getIt<SocketService>()),
  );

  // Operator Bloc - route-scoped control orchestration
  getIt.registerFactory<OperatorBloc>(
    () => OperatorBloc(repository: getIt<OperatorRepository>()),
  );
}

/// Clean up resources
///
/// Called on app shutdown
Future<void> teardownDependencies() async {
  await getIt<SocketService>().dispose();
  await getIt.reset();
}
