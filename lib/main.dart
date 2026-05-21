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

import 'core/constants/app_constants.dart';
import 'core/dependency_injection/injection.dart';
import 'core/router/app_router.dart';
import 'core/socket/socket_service.dart';
import 'core/theme/app_theme.dart';
import 'features/room/bloc/room_bloc.dart';
import 'features/operator/bloc/operator_bloc.dart';
import 'features/commenter/bloc/commenter_bloc.dart';
import 'features/recorder/cubit/recorder_cubit.dart';

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
    print('[Hive] Initialized successfully');
  } catch (e) {
    print('[Hive] Initialization error: $e');
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
    print('[Socket] Initialized successfully');
  } catch (e) {
    print('[Socket] Initialization error: $e');
    rethrow;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BLoCs - Feature orchestration with socket sync
        BlocProvider<RoomBloc>(create: (context) => RoomBloc()),
        BlocProvider<OperatorBloc>(create: (context) => OperatorBloc()),
        BlocProvider<CommenterBloc>(create: (context) => CommenterBloc()),

        // Cubits - Local UI state management
        BlocProvider<RecorderCubit>(create: (context) => RecorderCubit()),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        theme: AppTheme.dark,
        routerConfig: appRouter,
        // Remove debug banner
        debugShowCheckedModeBanner: false,
        // Enable Material 3
        useMaterial3: true,
      ),
    );
  }
}
