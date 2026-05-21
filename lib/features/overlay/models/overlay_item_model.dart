/// Overlay Models
///
/// Responsibility:
/// - Define data models for overlay feature
/// - Handle overlay-specific data structures

import 'package:equatable/equatable.dart';

class OverlayItem extends Equatable {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  const OverlayItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, type, data, createdAt];
}
