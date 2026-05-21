/// Room Repository
///
/// Responsibility:
/// - Manage data access for room feature
/// - Coordinate with socket service
/// - Handle API calls related to rooms
/// - Abstract data sources from BLoC

abstract class RoomRepository {
  Future<void> joinRoom(String roomId);
  Future<void> leaveRoom();
  Stream<Map<String, dynamic>> watchRoomUpdates();
}

class RoomRepositoryImpl implements RoomRepository {
  @override
  Future<void> joinRoom(String roomId) async {
    // TODO: Implement
  }

  @override
  Future<void> leaveRoom() async {
    // TODO: Implement
  }

  @override
  Stream<Map<String, dynamic>> watchRoomUpdates() {
    // TODO: Implement
    throw UnimplementedError();
  }
}
