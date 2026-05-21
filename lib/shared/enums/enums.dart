/// Shared Enums
///
/// Responsibility:
/// - Define common enum types used across features
/// - Provide type safety for status and state values
/// - Centralize enum definitions

/// User role in the application
enum UserRole { recorder, operator, commenter, viewer }

/// Participant role in a room
enum ParticipantRole { recorder, operator, commenter }

/// Connection status
enum ConnectionStatus { connected, disconnected, connecting, error }

/// Overlay display type
enum OverlayType { product, discount, announcement, alert }

/// Room status
enum RoomStatus { waiting, active, ended, error }
