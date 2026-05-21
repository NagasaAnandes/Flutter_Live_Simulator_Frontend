/// Room Widgets
///
/// Responsibility:
/// - Provide reusable widgets specific to room feature
/// - Handle room-specific UI components

import 'package:flutter/material.dart';

class RoomHeader extends StatelessWidget {
  final String roomTitle;

  const RoomHeader({Key? key, required this.roomTitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16), child: Text(roomTitle));
  }
}
