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

  const RecorderReady({
    this.controller,
    this.activeCamera,
    this.overlaysVisible = true,
    this.comments = const [],
    this.statusText = 'Ready',
  });

  RecorderReady copyWith({
    CameraController? controller,
    CameraDescription? activeCamera,
    bool? overlaysVisible,
    List<CommentOverlayItem>? comments,
    String? statusText,
  }) {
    return RecorderReady(
      controller: controller ?? this.controller,
      activeCamera: activeCamera ?? this.activeCamera,
      overlaysVisible: overlaysVisible ?? this.overlaysVisible,
      comments: comments ?? this.comments,
      statusText: statusText ?? this.statusText,
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
