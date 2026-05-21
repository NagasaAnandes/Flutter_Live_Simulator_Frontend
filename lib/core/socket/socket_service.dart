// Socket Service
//
// Responsibility:
// - Manages Socket.IO connection lifecycle
// - Handles connect/disconnect operations
// - Provides event emission and listening capabilities
// - Manages reconnection logic
// - Coordinates socket state across the application
// - Provides connection status stream for reactive UI
// - Handles safe listener cleanup
//
// This is the foundation for all realtime communication.
// Business event handlers are implemented in respective feature blocs/cubits.

import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../log/logger.dart';

enum SocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class SocketService {
  late IO.Socket _socket;

  /// Socket connection state
  SocketConnectionStatus _connectionStatus =
      SocketConnectionStatus.disconnected;

  /// Stream controller for connection status updates
  final _connectionStatusController =
      StreamController<SocketConnectionStatus>.broadcast();

  /// Listeners map to track active listeners for cleanup
  final Map<String, Function> _listeners = {};

  /// Get connection status
  bool get isConnected => _connectionStatus == SocketConnectionStatus.connected;

  /// Get current connection status enum
  SocketConnectionStatus get connectionStatus => _connectionStatus;

  /// Stream of connection status changes
  Stream<SocketConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

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
      AppLogger.e('[Socket] Initialization error: $e');
      _updateConnectionStatus(SocketConnectionStatus.error);
      rethrow;
    }
  }

  /// Setup comprehensive connection handlers
  void _setupConnectionHandlers() {
    _socket.onConnect((_) {
      _updateConnectionStatus(SocketConnectionStatus.connected);
      AppLogger.i('[Socket] Connected');
    });

    _socket.onDisconnect((_) {
      _updateConnectionStatus(SocketConnectionStatus.disconnected);
      AppLogger.i('[Socket] Disconnected');
    });

    _socket.onConnectError((error) {
      _updateConnectionStatus(SocketConnectionStatus.error);
      AppLogger.e('[Socket] Connection error: $error');
    });

    _socket.onError((error) {
      _updateConnectionStatus(SocketConnectionStatus.error);
      AppLogger.e('[Socket] Error: $error');
    });

    _socket.onReconnect((_) {
      _updateConnectionStatus(SocketConnectionStatus.connected);
      AppLogger.i('[Socket] Reconnected');
    });

    // socket_io_client doesn't expose `onReconnecting` like the Node.js client.
    // Use reconnect attempts events if needed via raw event names.
    _socket.on('reconnect_attempt', (data) {
      _updateConnectionStatus(SocketConnectionStatus.reconnecting);
      AppLogger.i('[Socket] Reconnect attempt: $data');
    });
  }

  /// Update connection status and emit to stream
  void _updateConnectionStatus(SocketConnectionStatus status) {
    _connectionStatus = status;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }

  /// Emit event to server
  void emit(String event, dynamic data) {
    if (isConnected) {
      _socket.emit(event, data);
    } else {
      AppLogger.w(
        '[Socket] Cannot emit $event - not connected (status: $_connectionStatus)',
      );
    }
  }

  /// Emit event with callback
  void emitWithAck(String event, dynamic data, Function(dynamic) ackCallback) {
    if (isConnected) {
      try {
        // Most dart socket_io_client implementations accept a callback as the
        // third positional parameter for acknowledgements.
        try {
          // Use dynamic call to attempt different emitWithAck signatures at runtime
          try {
            (_socket as dynamic).emitWithAck(event, data, ackCallback);
          } catch (_) {
            // Try two-argument form
            try {
              (_socket as dynamic).emitWithAck(event, data);
              // no ack available; log and move on
              AppLogger.w(
                '[Socket] emitWithAck called without ack callback available',
              );
            } catch (_) {
              // Last resort: plain emit
              _socket.emit(event, data);
            }
          }
        } catch (e) {
          AppLogger.e('[Socket] emitWithAck invocation error: $e');
        }
      } catch (e) {
        AppLogger.e('[Socket] emitWithAck failed: $e');
      }
    } else {
      AppLogger.w(
        '[Socket] Cannot emit $event - not connected (status: $_connectionStatus)',
      );
    }
  }

  /// Listen to event from server
  void on(String event, Function(dynamic) callback) {
    _listeners[event] = callback;
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

  /// Stop listening to specific event
  void off(String event) {
    _listeners.remove(event);
    _socket.off(event);
  }

  /// Stop listening to all events
  void offAll() {
    _listeners.clear();
    // socket_io_client for Dart does not expose `offAll`; use `clearListeners` instead
    try {
      _socket.clearListeners();
    } catch (e) {
      AppLogger.w('[Socket] clearListeners not available: $e');
    }
  }

  /// Connect to socket server
  Future<void> connect() async {
    if (!isConnected &&
        _connectionStatus != SocketConnectionStatus.connecting) {
      _updateConnectionStatus(SocketConnectionStatus.connecting);
      _socket.connect();
    }
  }

  /// Disconnect from socket server
  Future<void> disconnect() async {
    _socket.disconnect();
    _updateConnectionStatus(SocketConnectionStatus.disconnected);
  }

  /// Reconnect to socket server
  Future<void> reconnect() async {
    await disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  /// Cleanup resources
  Future<void> dispose() async {
    await disconnect();
    _listeners.clear();
    if (!_connectionStatusController.isClosed) {
      await _connectionStatusController.close();
    }
  }
}
