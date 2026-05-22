part of 'commenter_bloc.dart';

abstract class CommenterState extends Equatable {
  const CommenterState();

  @override
  List<Object?> get props => [];
}

class CommenterInitial extends CommenterState {
  const CommenterInitial();
}

class CommenterReady extends CommenterState {
  final String roomCode;
  final SocketConnectionStatus socketStatus;
  final String statusText;
  final String detailText;
  final CommentCategory? lastCategory;
  final Map<CommentCategory, DateTime> cooldownUntil;
  final bool burstInProgress;
  final int burstProgress;
  final int burstTotal;
  final bool emitInFlight;

  const CommenterReady({
    required this.roomCode,
    required this.socketStatus,
    required this.statusText,
    required this.detailText,
    this.lastCategory,
    this.cooldownUntil = const {},
    this.burstInProgress = false,
    this.burstProgress = 0,
    this.burstTotal = 0,
    this.emitInFlight = false,
  });

  static const Object _valueUnset = Object();

  CommenterReady copyWith({
    String? roomCode,
    SocketConnectionStatus? socketStatus,
    String? statusText,
    String? detailText,
    Object? lastCategory = _valueUnset,
    Map<CommentCategory, DateTime>? cooldownUntil,
    bool? burstInProgress,
    int? burstProgress,
    int? burstTotal,
    bool? emitInFlight,
  }) {
    return CommenterReady(
      roomCode: roomCode ?? this.roomCode,
      socketStatus: socketStatus ?? this.socketStatus,
      statusText: statusText ?? this.statusText,
      detailText: detailText ?? this.detailText,
      lastCategory: identical(lastCategory, _valueUnset)
          ? this.lastCategory
          : lastCategory as CommentCategory?,
      cooldownUntil: cooldownUntil ?? this.cooldownUntil,
      burstInProgress: burstInProgress ?? this.burstInProgress,
      burstProgress: burstProgress ?? this.burstProgress,
      burstTotal: burstTotal ?? this.burstTotal,
      emitInFlight: emitInFlight ?? this.emitInFlight,
    );
  }

  bool get isConnected => socketStatus == SocketConnectionStatus.connected;

  bool get isReconnecting =>
      socketStatus == SocketConnectionStatus.reconnecting;

  bool get hasActiveCooldowns => cooldownUntil.isNotEmpty;

  bool isCategoryCoolingDown(CommentCategory category) {
    final expiry = cooldownUntil[category];
    if (expiry == null) {
      return false;
    }

    return expiry.isAfter(DateTime.now());
  }

  Duration cooldownRemaining(CommentCategory category) {
    final expiry = cooldownUntil[category];
    if (expiry == null) {
      return Duration.zero;
    }

    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

class CommenterError extends CommenterState {
  final String message;

  const CommenterError(this.message);

  @override
  List<Object?> get props => [message];
}
