part of 'commenter_bloc.dart';

enum CommentCategory { price, hype, discount, stock, cod, checkout }

extension CommentCategoryX on CommentCategory {
  String get label {
    switch (this) {
      case CommentCategory.price:
        return 'PRICE';
      case CommentCategory.hype:
        return 'HYPE';
      case CommentCategory.discount:
        return 'DISCOUNT';
      case CommentCategory.stock:
        return 'STOCK';
      case CommentCategory.cod:
        return 'COD';
      case CommentCategory.checkout:
        return 'CHECKOUT';
    }
  }

  String get socketValue => label;

  String get subtitle {
    switch (this) {
      case CommentCategory.price:
        return 'Pricing pressure';
      case CommentCategory.hype:
        return 'Audience energy';
      case CommentCategory.discount:
        return 'Promo demand';
      case CommentCategory.stock:
        return 'Inventory checks';
      case CommentCategory.cod:
        return 'Payment preference';
      case CommentCategory.checkout:
        return 'Conversion intent';
    }
  }

  String get shortHint {
    switch (this) {
      case CommentCategory.price:
        return 'Price?';
      case CommentCategory.hype:
        return 'Hype!';
      case CommentCategory.discount:
        return 'Discount?';
      case CommentCategory.stock:
        return 'Stock?';
      case CommentCategory.cod:
        return 'COD?';
      case CommentCategory.checkout:
        return 'Checkout';
    }
  }
}

abstract class CommenterEvent extends Equatable {
  const CommenterEvent();

  @override
  List<Object?> get props => [];
}

class CommenterStarted extends CommenterEvent {
  final String roomCode;

  const CommenterStarted({required this.roomCode});

  @override
  List<Object?> get props => [roomCode];
}

class CommentCategoryTriggered extends CommenterEvent {
  final CommentCategory category;

  const CommentCategoryTriggered(this.category);

  @override
  List<Object?> get props => [category];
}

class CommentBurstRequested extends CommenterEvent {
  const CommentBurstRequested();
}

class CommenterReconnectRequested extends CommenterEvent {
  const CommenterReconnectRequested();
}

class _CommenterSocketStatusChanged extends CommenterEvent {
  final SocketConnectionStatus status;

  const _CommenterSocketStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class _CommenterCooldownExpired extends CommenterEvent {
  final CommentCategory category;

  const _CommenterCooldownExpired(this.category);

  @override
  List<Object?> get props => [category];
}
