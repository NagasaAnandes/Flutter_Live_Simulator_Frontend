/// Shared Enums
///
/// Responsibility:
/// - Define common enum types used across features
/// - Provide type safety for status and state values
/// - Centralize enum definitions

/// User role in the application
enum UserRole { recorder, operator, commenter, viewer }

/// Connection status
enum ConnectionStatus { connected, disconnected, connecting, error }

/// Overlay display type
enum OverlayType { product, discount, announcement, alert }
