import '../../../core/log/logger.dart';
import '../../../core/socket/socket_service.dart';
import '../models/operator_product.dart';

class OperatorRepository {
  final SocketService _socketService;

  OperatorRepository({required SocketService socketService})
    : _socketService = socketService;

  Stream<SocketConnectionStatus> get connectionStatusStream =>
      _socketService.connectionStatusStream;

  SocketConnectionStatus get connectionStatus =>
      _socketService.connectionStatus;

  bool get isConnected => _socketService.isConnected;

  void onSocketEvent(String event, Function(dynamic) callback) {
    _socketService.on(event, callback);
  }

  void offSocketEvent(String event) {
    _socketService.off(event);
  }

  Future<bool> showProduct({
    required String roomCode,
    required OperatorProduct product,
  }) async {
    if (roomCode.trim().isEmpty) {
      AppLogger.w('[Operator] SHOW_PRODUCT skipped: missing room code');
      return false;
    }

    if (!isConnected) {
      AppLogger.w('[Operator] SHOW_PRODUCT skipped: socket disconnected');
      return false;
    }

    try {
      _socketService.emit('SHOW_PRODUCT', {
        'roomCode': roomCode,
        'productId': product.id,
        'productName': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'product': product.toSocketPayload(),
        'source': 'operator',
      });
      AppLogger.i('[Operator] SHOW_PRODUCT emitted for ${product.id}');
      return true;
    } catch (error, stackTrace) {
      AppLogger.e('[Operator] SHOW_PRODUCT emit failed', error, stackTrace);
      return false;
    }
  }

  Future<bool> clearProduct({required String roomCode}) async {
    if (roomCode.trim().isEmpty) {
      AppLogger.w('[Operator] CLEAR_PRODUCT skipped: missing room code');
      return false;
    }

    if (!isConnected) {
      AppLogger.w('[Operator] CLEAR_PRODUCT skipped: socket disconnected');
      return false;
    }

    try {
      _socketService.emit('CLEAR_PRODUCT', {
        'roomCode': roomCode,
        'source': 'operator',
      });
      AppLogger.i('[Operator] CLEAR_PRODUCT emitted');
      return true;
    } catch (error, stackTrace) {
      AppLogger.e('[Operator] CLEAR_PRODUCT emit failed', error, stackTrace);
      return false;
    }
  }

  Future<bool> startDiscount({
    required String roomCode,
    required String title,
    required double percentage,
  }) async {
    if (roomCode.trim().isEmpty) {
      AppLogger.w('[Operator] START_DISCOUNT skipped: missing room code');
      return false;
    }

    if (!isConnected) {
      AppLogger.w('[Operator] START_DISCOUNT skipped: socket disconnected');
      return false;
    }

    try {
      _socketService.emit('START_DISCOUNT', {
        'roomCode': roomCode,
        'title': title,
        'discountPercentage': percentage,
        'source': 'operator',
      });
      AppLogger.i('[Operator] START_DISCOUNT emitted: $title');
      return true;
    } catch (error, stackTrace) {
      AppLogger.e('[Operator] START_DISCOUNT emit failed', error, stackTrace);
      return false;
    }
  }

  Future<bool> stopDiscount({required String roomCode}) async {
    if (roomCode.trim().isEmpty) {
      AppLogger.w('[Operator] STOP_DISCOUNT skipped: missing room code');
      return false;
    }

    if (!isConnected) {
      AppLogger.w('[Operator] STOP_DISCOUNT skipped: socket disconnected');
      return false;
    }

    try {
      _socketService.emit('STOP_DISCOUNT', {
        'roomCode': roomCode,
        'source': 'operator',
      });
      AppLogger.i('[Operator] STOP_DISCOUNT emitted');
      return true;
    } catch (error, stackTrace) {
      AppLogger.e('[Operator] STOP_DISCOUNT emit failed', error, stackTrace);
      return false;
    }
  }
}
