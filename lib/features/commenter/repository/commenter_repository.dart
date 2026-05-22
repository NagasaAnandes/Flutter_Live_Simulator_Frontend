import '../../../core/log/logger.dart';
import '../../../core/socket/socket_service.dart';

class CommenterRepository {
  final SocketService _socketService;

  CommenterRepository({required SocketService socketService})
    : _socketService = socketService;

  Stream<SocketConnectionStatus> get connectionStatusStream =>
      _socketService.connectionStatusStream;

  SocketConnectionStatus get connectionStatus =>
      _socketService.connectionStatus;

  bool get isConnected => _socketService.isConnected;

  Future<void> reconnect() => _socketService.reconnect();

  Future<bool> triggerComment({
    required String roomCode,
    required String category,
  }) async {
    if (roomCode.trim().isEmpty) {
      AppLogger.w('[Commenter] TRIGGER_COMMENT skipped: missing room code');
      return false;
    }

    if (!isConnected) {
      return false;
    }

    try {
      _socketService.emit('TRIGGER_COMMENT', {
        'roomCode': roomCode,
        'category': category,
        'source': 'commenter',
      });
      AppLogger.i('[Commenter] TRIGGER_COMMENT emitted: $category');
      return true;
    } catch (error, stackTrace) {
      AppLogger.e('[Commenter] TRIGGER_COMMENT emit failed', error, stackTrace);
      return false;
    }
  }
}
