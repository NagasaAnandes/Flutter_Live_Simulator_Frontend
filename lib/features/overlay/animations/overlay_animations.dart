/// Overlay Animations
///
/// Responsibility:
/// - Define animations for overlay display and transitions
/// - Provide animation utilities for overlay feature

import 'package:flutter/material.dart';

class OverlayAnimations {
  /// Fade in animation for overlays
  static AnimationController createFadeInController(
    TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return AnimationController(duration: duration, vsync: vsync);
  }

  /// Scale animation for overlays
  static AnimationController createScaleController(
    TickerProvider vsync, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return AnimationController(duration: duration, vsync: vsync);
  }
}
