import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/log/logger.dart';
import '../../../core/socket/socket_service.dart';
import '../../../shared/models/overlay_models.dart';

part 'recorder_state.dart';

class RecorderCubit extends Cubit<RecorderState> with WidgetsBindingObserver {
  final SocketService _socketService;
  StreamSubscription<SocketConnectionStatus>? _socketStatusSub;
  bool _socketListenersAttached = false;
  late final SocketEventCallback _showProductListener;
  late final SocketEventCallback _clearProductListener;
  late final SocketEventCallback _startDiscountListener;
  late final SocketEventCallback _stopDiscountListener;
  late final SocketEventCallback _triggerCommentListener;

  RecorderCubit({required SocketService socketService})
    : _socketService = socketService,
      super(const RecorderInitial()) {
    WidgetsBinding.instance.addObserver(this);
    _socketStatusSub = _socketService.connectionStatusStream.listen(
      _onSocketStatusChanged,
    );
    _showProductListener = _handleShowProduct;
    _clearProductListener = _handleClearProduct;
    _startDiscountListener = _handleStartDiscount;
    _stopDiscountListener = _handleStopDiscount;
    _triggerCommentListener = _handleTriggerComment;
    _attachSocketListeners();
  }

  final List<CameraDescription> _available = [];
  final List<Timer> _commentTimers = [];

  CameraController? _controller;
  CameraDescription? _activeCamera;
  bool _initializing = false;
  bool _disposed = false;
  int _sessionToken = 0;

  void _attachSocketListeners() {
    if (_socketListenersAttached) {
      return;
    }

    _socketListenersAttached = true;

    _socketService.on('SHOW_PRODUCT', _showProductListener);

    _socketService.on('CLEAR_PRODUCT', _clearProductListener);

    _socketService.on('START_DISCOUNT', _startDiscountListener);

    _socketService.on('STOP_DISCOUNT', _stopDiscountListener);

    _socketService.on('TRIGGER_COMMENT', _triggerCommentListener);
  }

  Future<void> initialize() async {
    if (_disposed || _initializing) {
      return;
    }

    _initializing = true;
    final int token = ++_sessionToken;
    emit(const RecorderLoading());

    try {
      if (_available.isEmpty) {
        final cameras = await availableCameras();
        if (_disposed || token != _sessionToken) {
          return;
        }
        _available
          ..clear()
          ..addAll(cameras);
      }

      final selected = _chooseDefault(_available);
      if (selected == null) {
        if (!_disposed && token == _sessionToken) {
          emit(const RecorderError('No cameras available'));
        }
        return;
      }

      final controller = await _createController(selected, token);
      if (controller == null) {
        return;
      }

      _controller = controller;
      _activeCamera = selected;

      if (!_disposed && token == _sessionToken) {
        emit(
          RecorderReady(
            controller: _controller,
            activeCamera: _activeCamera,
            overlaysVisible: true,
            comments: const [],
            statusText: 'Ready',
          ),
        );
      }
    } on CameraException catch (error) {
      _logCameraFailure('initialize', error);
      if (!_disposed && token == _sessionToken) {
        emit(RecorderError(_cameraErrorMessage(error)));
      }
    } catch (error) {
      AppLogger.e('[Recorder] initialize failed: $error');
      if (!_disposed && token == _sessionToken) {
        emit(const RecorderError('Recorder initialization failed'));
      }
    } finally {
      _initializing = false;
    }
  }

  CameraDescription? _chooseDefault(List<CameraDescription> cameras) {
    if (cameras.isEmpty) {
      return null;
    }

    return cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
  }

  Future<CameraController?> _createController(
    CameraDescription camera,
    int token,
  ) async {
    try {
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();

      if (_disposed || token != _sessionToken) {
        await controller.dispose();
        return null;
      }

      return controller;
    } on CameraException catch (error) {
      _logCameraFailure('createController', error);
      rethrow;
    }
  }

  Future<void> switchCamera() async {
    if (_disposed || _initializing || state is! RecorderReady) {
      return;
    }

    if (_available.length < 2) {
      AppLogger.w('[Recorder] switchCamera skipped: less than 2 cameras');
      return;
    }

    _initializing = true;
    final int token = ++_sessionToken;
    final current = _activeCamera;
    final oldController = _controller;

    try {
      final next = _nextCamera(current);
      if (next == null) {
        return;
      }

      final controller = await _createController(next, token);
      if (controller == null) {
        return;
      }

      _controller = controller;
      _activeCamera = next;

      if (!_disposed && token == _sessionToken && state is RecorderReady) {
        emit(
          (state as RecorderReady).copyWith(
            controller: _controller,
            activeCamera: _activeCamera,
            statusText: 'Camera switched',
          ),
        );
      }

      if (oldController != null) {
        await oldController.dispose();
      }
    } on CameraException catch (error) {
      _logCameraFailure('switchCamera', error);
      if (!_disposed && token == _sessionToken) {
        emit(RecorderError(_cameraErrorMessage(error)));
      }
    } catch (error) {
      AppLogger.e('[Recorder] switchCamera failed: $error');
      if (!_disposed && token == _sessionToken) {
        emit(const RecorderError('Failed to switch camera'));
      }
    } finally {
      _initializing = false;
    }
  }

  CameraDescription? _nextCamera(CameraDescription? current) {
    if (_available.isEmpty) {
      return null;
    }

    if (current == null) {
      return _available.first;
    }

    final index = _available.indexWhere(
      (camera) => camera.name == current.name,
    );
    if (index < 0) {
      return _available.first;
    }

    return _available[(index + 1) % _available.length];
  }

  void toggleOverlays() {
    final current = state;
    if (current is RecorderReady && !_disposed) {
      emit(current.copyWith(overlaysVisible: !current.overlaysVisible));
    }
  }

  void _onSocketStatusChanged(SocketConnectionStatus status) {
    final current = state;
    if (current is! RecorderReady || _disposed) {
      return;
    }

    switch (status) {
      case SocketConnectionStatus.connected:
        emit(current.copyWith(statusText: 'Ready'));
        break;
      case SocketConnectionStatus.reconnecting:
        emit(current.copyWith(statusText: 'Reconnecting control link'));
        break;
      case SocketConnectionStatus.disconnected:
        emit(current.copyWith(statusText: 'Socket disconnected'));
        break;
      case SocketConnectionStatus.connecting:
        emit(current.copyWith(statusText: 'Connecting...'));
        break;
      case SocketConnectionStatus.error:
        emit(current.copyWith(statusText: 'Socket error'));
        break;
    }
  }

  void _handleShowProduct(dynamic data) {
    final current = state;
    if (current is! RecorderReady || _disposed) {
      return;
    }

    final payload = _asMap(data);
    final productPayload = _asMap(payload['product'] ?? payload);
    final name =
        productPayload['name']?.toString() ??
        payload['productName']?.toString() ??
        'Product';

    final priceValue = productPayload['price'] ?? payload['price'];
    final price = priceValue is num
        ? priceValue.toDouble()
        : double.tryParse(priceValue?.toString() ?? '') ?? 0.0;

    emit(
      current.copyWith(
        activeProduct: ProductOverlay(
          productId:
              productPayload['id']?.toString() ??
              payload['productId']?.toString() ??
              name,
          name: name,
          price: price,
          imageUrl:
              productPayload['imageUrl']?.toString() ??
              payload['imageUrl']?.toString() ??
              '',
          description:
              productPayload['category']?.toString() ??
              payload['category']?.toString() ??
              'Live product',
          stock: 0,
          displayedAt: DateTime.now(),
        ),
        statusText: 'Showing $name',
      ),
    );
  }

  void _handleClearProduct(dynamic data) {
    final current = state;
    if (current is! RecorderReady || _disposed) {
      return;
    }

    emit(current.copyWith(activeProduct: null, statusText: 'Product cleared'));
  }

  void _handleStartDiscount(dynamic data) {
    final current = state;
    if (current is! RecorderReady || _disposed) {
      return;
    }

    final payload = _asMap(data);
    final title = payload['title']?.toString() ?? 'Discount';
    final percentageValue = payload['discountPercentage'];
    final percentage = percentageValue is num
        ? percentageValue.toDouble()
        : double.tryParse(percentageValue?.toString() ?? '') ?? 0.0;

    emit(
      current.copyWith(
        activeDiscount: DiscountOverlay(
          discountId: payload['discountId']?.toString() ?? title,
          title: title,
          discountPercentage: percentage,
          startsAt: DateTime.now(),
          expiresAt: DateTime.now().add(const Duration(minutes: 5)),
          usageLimit: 9999,
          usageCount: 0,
        ),
        statusText: percentage > 0 ? '$title live' : title,
      ),
    );
  }

  void _handleStopDiscount(dynamic data) {
    final current = state;
    if (current is! RecorderReady || _disposed) {
      return;
    }

    emit(
      current.copyWith(activeDiscount: null, statusText: 'Discount stopped'),
    );
  }

  void _handleTriggerComment(dynamic data) {
    final current = state;
    if (current is! RecorderReady || _disposed) {
      return;
    }

    final payload = _asMap(data);
    final text = _commentTextFromPayload(payload);
    if (text.isEmpty) {
      return;
    }

    addComment(text);
  }

  String _commentTextFromPayload(Map<String, dynamic> payload) {
    final message =
        payload['message']?.toString().trim() ??
        payload['text']?.toString().trim() ??
        payload['template']?.toString().trim() ??
        payload['comment']?.toString().trim() ??
        '';

    final username =
        payload['userName']?.toString().trim() ??
        payload['username']?.toString().trim() ??
        payload['displayName']?.toString().trim() ??
        '';

    if (username.isNotEmpty && message.isNotEmpty) {
      return '$username: $message';
    }

    if (message.isNotEmpty) {
      return message;
    }

    final category = payload['category']?.toString().trim() ?? '';
    if (category.isNotEmpty) {
      return _fallbackCommentText(category);
    }

    return '';
  }

  String _fallbackCommentText(String category) {
    switch (category.toUpperCase()) {
      case 'PRICE':
        return 'Is this price final?';
      case 'HYPE':
        return 'This live is going crazy!';
      case 'DISCOUNT':
        return 'Need more discount details!';
      case 'STOCK':
        return 'How much stock is left?';
      case 'COD':
        return 'Can I pay cash on delivery?';
      case 'CHECKOUT':
        return 'Ready to checkout now.';
      default:
        return category;
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }

    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }

    return <String, dynamic>{};
  }

  void addComment(String text) {
    final current = state;
    if (current is! RecorderReady || _disposed) {
      return;
    }

    final item = CommentOverlayItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now(),
    );

    final comments = List<CommentOverlayItem>.from(current.comments)..add(item);
    emit(current.copyWith(comments: comments, statusText: current.statusText));

    final timer = Timer(const Duration(seconds: 6), () {
      final activeState = state;
      if (_disposed || activeState is! RecorderReady) {
        return;
      }

      final pruned = List<CommentOverlayItem>.from(activeState.comments)
        ..removeWhere((comment) => comment.id == item.id);
      emit(activeState.copyWith(comments: pruned));
    });

    _commentTimers.add(timer);
  }

  Future<void> pauseCamera() async {
    final controller = _controller;
    if (controller == null || _disposed) {
      return;
    }

    _sessionToken++;
    try {
      await controller.dispose();
    } catch (error) {
      AppLogger.w('[Recorder] pauseCamera dispose warning: $error');
    } finally {
      if (identical(_controller, controller)) {
        _controller = null;
      }
    }

    final current = state;
    if (!_disposed && current is RecorderReady) {
      emit(current.copyWith(controller: null, statusText: 'Camera paused'));
    }
  }

  Future<void> resumeCamera() async {
    if (_disposed || _initializing) {
      return;
    }

    if (_controller != null && _controller!.value.isInitialized) {
      return;
    }

    await initialize();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) {
      return;
    }

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        unawaited(pauseCamera());
        break;
      case AppLifecycleState.resumed:
        unawaited(resumeCamera());
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _logCameraFailure(String action, CameraException error) {
    AppLogger.e(
      '[Recorder] $action failed: ${error.code} ${error.description}',
    );
  }

  String _cameraErrorMessage(CameraException error) {
    final description = error.description?.trim();
    if (error.code == 'CameraAccessDenied' ||
        error.code == 'CameraAccessDeniedWithoutPrompt') {
      return 'Camera permission denied';
    }

    if (description != null && description.isNotEmpty) {
      return description;
    }

    return 'Camera unavailable';
  }

  @override
  Future<void> close() async {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    await _socketStatusSub?.cancel();

    for (final timer in _commentTimers) {
      timer.cancel();
    }
    _commentTimers.clear();

    final controller = _controller;
    _controller = null;

    if (controller != null) {
      try {
        await controller.dispose();
      } catch (error) {
        AppLogger.w('[Recorder] controller dispose warning: $error');
      }
    }

    try {
      _socketService.off('SHOW_PRODUCT', _showProductListener);
      _socketService.off('CLEAR_PRODUCT', _clearProductListener);
      _socketService.off('START_DISCOUNT', _startDiscountListener);
      _socketService.off('STOP_DISCOUNT', _stopDiscountListener);
      _socketService.off('TRIGGER_COMMENT', _triggerCommentListener);
    } catch (_) {}

    return super.close();
  }
}
