/// Room Models
///
/// Responsibility:
/// - Define data models specific to room feature
/// - Handle serialization/deserialization
/// - Provide feature-specific data structures

import 'package:equatable/equatable.dart';

class Room extends Equatable {
  final String id;
  final String title;
  final DateTime createdAt;

  const Room({required this.id, required this.title, required this.createdAt});

  @override
  List<Object?> get props => [id, title, createdAt];
}
