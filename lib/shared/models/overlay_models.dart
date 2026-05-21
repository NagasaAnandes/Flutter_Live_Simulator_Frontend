/// Shared Models
///
/// Responsibility:
/// - Define common data structures used across features
/// - Ensure strong typing throughout the application
/// - Provide serialization/deserialization capabilities
///
/// These models bridge socket events and UI state.

import 'package:equatable/equatable.dart';

/// Room snapshot - represents current state of a live session
class RoomSnapshot extends Equatable {
  final String roomId;
  final String title;
  final DateTime startedAt;
  final int viewerCount;
  final bool isLive;

  const RoomSnapshot({
    required this.roomId,
    required this.title,
    required this.startedAt,
    required this.viewerCount,
    required this.isLive,
  });

  @override
  List<Object?> get props => [roomId, title, startedAt, viewerCount, isLive];
}

/// Product overlay - represents a product displayed on stream
class ProductOverlay extends Equatable {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final int stock;
  final DateTime displayedAt;

  const ProductOverlay({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.stock,
    required this.displayedAt,
  });

  @override
  List<Object?> get props => [
    productId,
    name,
    price,
    imageUrl,
    description,
    stock,
    displayedAt,
  ];
}

/// Discount overlay - represents active discount/promotion
class DiscountOverlay extends Equatable {
  final String discountId;
  final String title;
  final double discountPercentage;
  final DateTime startsAt;
  final DateTime expiresAt;
  final int usageLimit;
  final int usageCount;

  const DiscountOverlay({
    required this.discountId,
    required this.title,
    required this.discountPercentage,
    required this.startsAt,
    required this.expiresAt,
    required this.usageLimit,
    required this.usageCount,
  });

  bool get isActive =>
      DateTime.now().isAfter(startsAt) && DateTime.now().isBefore(expiresAt);
  bool get isExhausted => usageCount >= usageLimit;

  @override
  List<Object?> get props => [
    discountId,
    title,
    discountPercentage,
    startsAt,
    expiresAt,
    usageLimit,
    usageCount,
  ];
}

/// Comment overlay - represents a comment on stream
class CommentOverlay extends Equatable {
  final String commentId;
  final String userId;
  final String userName;
  final String message;
  final DateTime sentAt;
  final bool isPinned;

  const CommentOverlay({
    required this.commentId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.sentAt,
    required this.isPinned,
  });

  @override
  List<Object?> get props => [
    commentId,
    userId,
    userName,
    message,
    sentAt,
    isPinned,
  ];
}
