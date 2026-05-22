part of 'operator_bloc.dart';

enum OperatorPhase { initial, loading, ready, error }

enum OperatorDiscountPreset {
  tenPercent(label: '10%', percentage: 10),
  twentyPercent(label: '20%', percentage: 20),
  flashSale(label: 'FLASH SALE', percentage: 0),
  freeShipping(label: 'FREE SHIPPING', percentage: 0);

  final String label;
  final double percentage;

  const OperatorDiscountPreset({required this.label, required this.percentage});
}

const Object _operatorValueUnset = Object();

class OperatorState extends Equatable {
  final OperatorPhase phase;
  final String roomCode;
  final List<OperatorProduct> products;
  final OperatorProduct? activeProduct;
  final OperatorDiscountPreset? activeDiscount;
  final SocketConnectionStatus connectionStatus;
  final String statusMessage;
  final String? errorMessage;
  final DateTime? lastActionAt;

  const OperatorState({
    required this.phase,
    required this.roomCode,
    required this.products,
    required this.connectionStatus,
    required this.statusMessage,
    this.activeProduct,
    this.activeDiscount,
    this.errorMessage,
    this.lastActionAt,
  });

  factory OperatorState.initial({
    String roomCode = '',
    List<OperatorProduct> products = const [],
  }) {
    final normalizedProducts = List<OperatorProduct>.unmodifiable(products);
    return OperatorState(
      phase: OperatorPhase.initial,
      roomCode: roomCode,
      products: normalizedProducts,
      connectionStatus: SocketConnectionStatus.disconnected,
      statusMessage: roomCode.isEmpty ? 'Set a room code to begin' : 'Ready',
    );
  }

  bool get isConnected => connectionStatus == SocketConnectionStatus.connected;

  bool get isReconnecting =>
      connectionStatus == SocketConnectionStatus.reconnecting;

  String get overlayStateLabel {
    if (phase == OperatorPhase.loading) {
      return 'LOADING';
    }

    if (isReconnecting) {
      return 'RECONNECTING';
    }

    if (!isConnected) {
      return 'SYNC LOST';
    }

    if (activeProduct != null && activeDiscount != null) {
      return 'PRODUCT + DISCOUNT';
    }

    if (activeProduct != null) {
      return 'PRODUCT LIVE';
    }

    if (activeDiscount != null) {
      return 'DISCOUNT LIVE';
    }

    return 'IDLE';
  }

  OperatorState copyWith({
    OperatorPhase? phase,
    String? roomCode,
    List<OperatorProduct>? products,
    Object? activeProduct = _operatorValueUnset,
    Object? activeDiscount = _operatorValueUnset,
    SocketConnectionStatus? connectionStatus,
    String? statusMessage,
    Object? errorMessage = _operatorValueUnset,
    DateTime? lastActionAt,
  }) {
    return OperatorState(
      phase: phase ?? this.phase,
      roomCode: roomCode ?? this.roomCode,
      products: List<OperatorProduct>.unmodifiable(products ?? this.products),
      activeProduct: identical(activeProduct, _operatorValueUnset)
          ? this.activeProduct
          : activeProduct as OperatorProduct?,
      activeDiscount: identical(activeDiscount, _operatorValueUnset)
          ? this.activeDiscount
          : activeDiscount as OperatorDiscountPreset?,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      statusMessage: statusMessage ?? this.statusMessage,
      errorMessage: identical(errorMessage, _operatorValueUnset)
          ? this.errorMessage
          : errorMessage as String?,
      lastActionAt: lastActionAt ?? this.lastActionAt,
    );
  }

  @override
  List<Object?> get props => [
    phase,
    roomCode,
    products,
    activeProduct,
    activeDiscount,
    connectionStatus,
    statusMessage,
    errorMessage,
    lastActionAt,
  ];
}
