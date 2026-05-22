part of 'recorder_cubit.dart';

@immutable
abstract class RecorderState {
  const RecorderState();
}

class RecorderInitial extends RecorderState {
  const RecorderInitial();
}

class RecorderLoading extends RecorderState {
  const RecorderLoading();
}

class RecorderReady extends RecorderState {
  final CameraController? controller;
  final CameraDescription? activeCamera;
  final bool overlaysVisible;
  final List<CommentOverlayItem> comments;
  final String statusText;
  final ProductOverlay? activeProduct;
  final DiscountOverlay? activeDiscount;

  const RecorderReady({
    this.controller,
    this.activeCamera,
    this.overlaysVisible = true,
    this.comments = const [],
    this.statusText = 'Ready',
    this.activeProduct,
    this.activeDiscount,
  });

  static const Object _valueUnset = Object();

  RecorderReady copyWith({
    CameraController? controller,
    CameraDescription? activeCamera,
    bool? overlaysVisible,
    List<CommentOverlayItem>? comments,
    String? statusText,
    Object? activeProduct = _valueUnset,
    Object? activeDiscount = _valueUnset,
  }) {
    return RecorderReady(
      controller: controller ?? this.controller,
      activeCamera: activeCamera ?? this.activeCamera,
      overlaysVisible: overlaysVisible ?? this.overlaysVisible,
      comments: comments ?? this.comments,
      statusText: statusText ?? this.statusText,
      activeProduct: identical(activeProduct, _valueUnset)
          ? this.activeProduct
          : activeProduct as ProductOverlay?,
      activeDiscount: identical(activeDiscount, _valueUnset)
          ? this.activeDiscount
          : activeDiscount as DiscountOverlay?,
    );
  }
}

class RecorderError extends RecorderState {
  final String message;

  const RecorderError(this.message);
}

@immutable
class CommentOverlayItem {
  final String id;
  final String text;
  final DateTime createdAt;

  const CommentOverlayItem({
    required this.id,
    required this.text,
    required this.createdAt,
  });
}
