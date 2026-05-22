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
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../constants/app_constants.dart';
import '../log/logger.dart';

typedef SocketEventCallback = void Function(dynamic data);

class _TrackedListener {
  final SocketEventCallback callback;
  final SocketEventCallback wrapper;

  const _TrackedListener({required this.callback, required this.wrapper});
}

enum SocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

class SocketService {
  io.Socket? _socket;

  bool _isInitialized = false;
  bool _isDisposing = false;
  DateTime? _lastManualReconnectAt;

  /// Socket connection state
  SocketConnectionStatus _connectionStatus =
      SocketConnectionStatus.disconnected;

  /// Stream controller for connection status updates
  final _connectionStatusController =
      StreamController<SocketConnectionStatus>.broadcast();

  /// Listeners map to track active listeners for cleanup
  final Map<String, List<_TrackedListener>> _listeners = {};

  /// Get connection status
  bool get isConnected => _connectionStatus == SocketConnectionStatus.connected;

  /// Get current connection status enum
  SocketConnectionStatus get connectionStatus => _connectionStatus;

  /// Stream of connection status changes
  Stream<SocketConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  /// Get socket instance
  io.Socket get socket {
    final activeSocket = _socket;
    if (!_isInitialized || activeSocket == null) {
      throw StateError('SocketService not initialized');
    }
    return activeSocket;
  }

  /// Initialize socket connection
  ///
  /// Called during app bootstrap in main.dart
  /// Configures basic connection settings and error handlers
  Future<void> initialize({
    required String serverUrl,
    required Map<String, dynamic> connectOptions,
  }) async {
    if (_isInitialized && _socket != null) {
      AppLogger.i('[Socket] initialize skipped: already initialized');
      if (_connectionStatus == SocketConnectionStatus.disconnected ||
          _connectionStatus == SocketConnectionStatus.error) {
        await connect();
      }
      return;
    }

    try {
      _isDisposing = false;
      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(AppConstants.socketReconnectDelay)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(AppConstants.socketReconnectMaxAttempts)
            .build(),
      );

      _isInitialized = true;
      _setupConnectionHandlers();
      AppLogger.i(
        '[Socket] Initialized: url=$serverUrl, transport=websocket, reconnectAttempts=${AppConstants.socketReconnectMaxAttempts}',
      );

      if (connectOptions.isNotEmpty) {
        AppLogger.w(
          '[Socket] connectOptions provided but not applied by current transport config: $connectOptions',
        );
      }
    } catch (e) {
      AppLogger.e('[Socket] Initialization error: $e');
      _updateConnectionStatus(SocketConnectionStatus.error);
      rethrow;
    }
  }

  /// Setup comprehensive connection handlers
  void _setupConnectionHandlers() {
    socket.onConnect((_) {
      _updateConnectionStatus(SocketConnectionStatus.connected);
      AppLogger.i('[Socket] Connected');
    });

    socket.onDisconnect((reason) {
      _updateConnectionStatus(SocketConnectionStatus.disconnected);
      AppLogger.i(
        '[Socket] Disconnected${_isDisposing ? ' (dispose)' : ''}: $reason',
      );
    });

    socket.onConnectError((error) {
      _updateConnectionStatus(SocketConnectionStatus.error);
      AppLogger.e('[Socket] Connection error: $error');
    });

    socket.onError((error) {
      _updateConnectionStatus(SocketConnectionStatus.error);
      AppLogger.e('[Socket] Error: $error');
    });

    socket.onReconnect((_) {
      _updateConnectionStatus(SocketConnectionStatus.connected);
      AppLogger.i('[Socket] Reconnect success');
    });

    // socket_io_client doesn't expose `onReconnecting` like the Node.js client.
    // Use reconnect attempts events if needed via raw event names.
    socket.on('reconnect_attempt', (data) {
      _updateConnectionStatus(SocketConnectionStatus.reconnecting);
      AppLogger.i('[Socket] Reconnect attempt: $data');
    });

    socket.on('reconnect_error', (error) {
      _updateConnectionStatus(SocketConnectionStatus.reconnecting);
      AppLogger.e('[Socket] Reconnect error: $error');
    });

    socket.on('reconnect_failed', (data) {
      _updateConnectionStatus(SocketConnectionStatus.error);
      AppLogger.e('[Socket] Reconnect failed: $data');
    });

    socket.on('upgrade', (transport) {
      AppLogger.i('[Socket] Transport upgrade: $transport');
    });
  }

  /// Update connection status and emit to stream
  void _updateConnectionStatus(SocketConnectionStatus status) {
    if (_connectionStatus == status) {
      return;
    }

    _connectionStatus = status;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(status);
    }
  }

  /// Emit event to server
  void emit(String event, dynamic data) {
    if (isConnected) {
      socket.emit(event, data);
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
            (socket as dynamic).emitWithAck(event, data, ackCallback);
          } catch (_) {
            // Try two-argument form
            try {
              (socket as dynamic).emitWithAck(event, data);
              // no ack available; log and move on
              AppLogger.w(
                '[Socket] emitWithAck called without ack callback available',
              );
            } catch (_) {
              // Last resort: plain emit
              socket.emit(event, data);
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
  void on(String event, SocketEventCallback callback) {
    if (!_isInitialized || _socket == null) {
      AppLogger.w('[Socket] on($event) skipped: socket not initialized');
      return;
    }

    final listeners = _listeners.putIfAbsent(event, () => <_TrackedListener>[]);

    if (listeners.any((listener) => identical(listener.callback, callback))) {
      AppLogger.i('[Socket] Listener already registered: $event');
      return;
    }

    void handler(dynamic data) {
      callback(data);
    }

    listeners.add(_TrackedListener(callback: callback, wrapper: handler));
    socket.on(event, handler);
    AppLogger.i(
      '[Socket] Listener registered: $event (count=${listeners.length})',
    );
  }

  /// Listen to event once
  void once(String event, SocketEventCallback callback) {
    if (!_isInitialized || _socket == null) {
      AppLogger.w('[Socket] once($event) skipped: socket not initialized');
      return;
    }

    socket.once(event, (data) {
      callback(data);
    });
    AppLogger.i('[Socket] One-time listener registered: $event');
  }

  /// Stop listening to specific event
  void off(String event, [SocketEventCallback? callback]) {
    if (!_isInitialized || _socket == null) {
      return;
    }

    final listeners = _listeners[event];
    if (listeners == null || listeners.isEmpty) {
      if (callback == null) {
        socket.off(event);
        AppLogger.i(
          '[Socket] Listener cleanup invoked for untracked event: $event',
        );
      }
      return;
    }

    if (callback == null) {
      for (final listener in listeners) {
        socket.off(event, listener.wrapper);
      }
      AppLogger.i(
        '[Socket] Listener cleanup: $event (removed=${listeners.length})',
      );
      _listeners.remove(event);
      return;
    }

    final index = listeners.indexWhere(
      (listener) => identical(listener.callback, callback),
    );
    if (index == -1) {
      return;
    }

    final listener = listeners.removeAt(index);
    socket.off(event, listener.wrapper);
    AppLogger.i(
      '[Socket] Listener cleanup: $event (remaining=${listeners.length})',
    );

    if (listeners.isEmpty) {
      _listeners.remove(event);
    }
  }

  /// Stop listening to all events
  void offAll([String? event]) {
    if (event != null) {
      off(event);
      return;
    }

    clearListeners();
  }

  /// Remove all tracked listeners without affecting connection handlers.
  void clearListeners() {
    if (!_isInitialized || _socket == null) {
      _listeners.clear();
      return;
    }

    final trackedListeners = _listeners.entries.toList(growable: false);
    _listeners.clear();

    for (final entry in trackedListeners) {
      for (final listener in entry.value) {
        try {
          socket.off(entry.key, listener.wrapper);
        } catch (e) {
          AppLogger.w('[Socket] Failed to clear listener for ${entry.key}: $e');
        }
      }
      AppLogger.i(
        '[Socket] Listener cleanup: ${entry.key} (removed=${entry.value.length})',
      );
    }
  }

  /// Connect to socket server
  Future<void> connect() async {
    if (!_isInitialized || _socket == null) {
      AppLogger.w('[Socket] connect skipped: socket not initialized');
      return;
    }

    if (!isConnected &&
        _connectionStatus != SocketConnectionStatus.connecting &&
        _connectionStatus != SocketConnectionStatus.reconnecting) {
      _updateConnectionStatus(SocketConnectionStatus.connecting);
      AppLogger.i('[Socket] Connect requested');
      socket.connect();
    }
  }

  /// Disconnect from socket server
  Future<void> disconnect() async {
    if (!_isInitialized || _socket == null) {
      return;
    }

    socket.disconnect();
    _updateConnectionStatus(SocketConnectionStatus.disconnected);
  }

  /// Reconnect to socket server
  Future<void> reconnect() async {
    final now = DateTime.now();
    if (_lastManualReconnectAt != null &&
        now.difference(_lastManualReconnectAt!).inMilliseconds < 1000) {
      AppLogger.w('[Socket] reconnect throttled to prevent spam loop');
      return;
    }
    _lastManualReconnectAt = now;

    if (_connectionStatus == SocketConnectionStatus.connecting ||
        _connectionStatus == SocketConnectionStatus.reconnecting) {
      AppLogger.i(
        '[Socket] reconnect skipped: already connecting/reconnecting',
      );
      return;
    }

    await disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    await connect();
  }

  /// Cleanup resources
  Future<void> dispose() async {
    _isDisposing = true;
    clearListeners();
    await disconnect();
    try {
      socket.dispose();
    } catch (_) {}

    _socket = null;
    _isInitialized = false;

    if (!_connectionStatusController.isClosed) {
      await _connectionStatusController.close();
    }
  }
}
