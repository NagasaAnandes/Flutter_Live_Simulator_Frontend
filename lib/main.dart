/// Flutter Live Commerce Simulator
///
/// Main entry point for the application.
///
/// Responsibilities:
/// - Initialize Hive for local storage
/// - Set up dependency injection
/// - Configure router
/// - Initialize socket service
/// - Setup BLoC/Cubit providers
/// - Launch MaterialApp with proper configuration

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/log/logger.dart';

import 'core/constants/app_constants.dart';
import 'core/dependency_injection/injection.dart';
import 'core/router/app_router.dart';
import 'core/socket/socket_service.dart';
import 'core/theme/app_theme.dart';
import 'features/room/bloc/room_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await _initializeHive();

  // Setup dependency injection
  await setupDependencies();

  // Initialize socket service
  await _initializeSocket();

  runApp(const MyApp());
}

/// Initialize Hive database
///
/// Sets up local persistence for offline-first architecture
Future<void> _initializeHive() async {
  try {
    await Hive.initFlutter();
    await Hive.openBox(AppConstants.hiveBoxName);
    AppLogger.i('[Hive] Initialized successfully');
  } catch (e) {
    AppLogger.e('[Hive] Initialization error: $e');
    rethrow;
  }
}

/// Initialize Socket.IO service
///
/// Prepares socket connection for realtime communication
Future<void> _initializeSocket() async {
  try {
    final socketService = getIt<SocketService>();
    await socketService.initialize(
      serverUrl: AppConstants.socketServerUrl,
      connectOptions: {},
    );
    AppLogger.i('[Socket] Initialized successfully');
  } catch (e) {
    AppLogger.e('[Socket] Initialization error: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BLoCs - Feature orchestration with socket sync
        BlocProvider<RoomBloc>(create: (context) => RoomBloc()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.dark,
        routerConfig: appRouter,
        // Remove debug banner
        debugShowCheckedModeBanner: false,
        // Material version controlled via ThemeData
      ),
    );
  }
}
