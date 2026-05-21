/// Socket Service
///
/// Responsibility:
/// - Manages Socket.IO connection lifecycle
/// - Handles connect/disconnect operations
/// - Provides event emission and listening capabilities
/// - Manages reconnection logic
/// - Coordinates socket state across the application
///
/// This is the foundation for all realtime communication.
/// Business event handlers are implemented in respective feature blocs/cubits.

import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  late IO.Socket _socket;

  /// Socket connection state
  bool _isConnected = false;

  /// Get connection status
  bool get isConnected => _isConnected;

  /// Get socket instance
  IO.Socket get socket => _socket;

  /// Initialize socket connection
  ///
  /// Called during app bootstrap in main.dart
  /// Configures basic connection settings and error handlers
  Future<void> initialize({
    required String serverUrl,
    required Map<String, dynamic> connectOptions,
  }) async {
    try {
      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );

      _setupConnectionHandlers();
    } catch (e) {
      print('SocketService initialization error: $e');
      rethrow;
    }
  }

  /// Setup basic connection handlers
  void _setupConnectionHandlers() {
    _socket.onConnect((_) {
      _isConnected = true;
      print('[Socket] Connected');
    });

    _socket.onDisconnect((_) {
      _isConnected = false;
      print('[Socket] Disconnected');
    });

    _socket.onError((error) {
      print('[Socket] Error: $error');
    });
  }

  /// Emit event to server
  void emit(String event, dynamic data) {
    if (_isConnected) {
      _socket.emit(event, data);
    } else {
      print('[Socket] Cannot emit $event - not connected');
    }
  }

  /// Listen to event from server
  void on(String event, Function(dynamic) callback) {
    _socket.on(event, (data) {
      callback(data);
    });
  }

  /// Listen to event once
  void once(String event, Function(dynamic) callback) {
    _socket.once(event, (data) {
      callback(data);
    });
  }

  /// Stop listening to event
  void off(String event) {
    _socket.off(event);
  }

  /// Connect to socket server
  Future<void> connect() async {
    if (!_isConnected) {
      _socket.connect();
    }
  }

  /// Disconnect from socket server
  Future<void> disconnect() async {
    _socket.disconnect();
    _isConnected = false;
  }

  /// Cleanup resources
  Future<void> dispose() async {
    await disconnect();
  }
}
