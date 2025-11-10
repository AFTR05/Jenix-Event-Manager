import 'package:jenix_event_manager/src/domain/entities/enum/room_status_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/campus_status_enum.dart';

import 'campus_entity.dart';

class RoomEntity {
  final String id;
  final String type;
  final int capacity;
  final RoomStatusEnum state;
  final List<String>? equipment;
  final CampusEntity campus;
  final bool isActive;
  final DateTime createdAt;

  RoomEntity({
    required this.id,
    required this.type,
    required this.capacity,
    required this.state,
    this.equipment,
    required this.campus,
    required this.isActive,
    required this.createdAt,
  });

  factory RoomEntity.fromJson(Map<String, dynamic> json) {
    // id and type expected as strings
    final id = json['id']?.toString() ?? '';
    final type = json['type']?.toString() ?? '';

    // capacity may come as int or double
    final capacityRaw = json['capacity'];
    final capacity = capacityRaw is num ? capacityRaw.toInt() : int.tryParse('$capacityRaw') ?? 0;

    // parse state safely
    final state = roomStatusEnumTryParse(json['state'] as String?) ?? RoomStatusEnum.disponible;

    // equipment: if server sends a list, convert; otherwise null
    List<String>? equipment;
    if (json['equipment'] != null) {
      try {
        equipment = List<String>.from(json['equipment']);
      } catch (_) {
        equipment = null;
      }
    }

    // campus can be an object or a simple string (name or id). Handle both.
    final campusRaw = json['campus'];
    CampusEntity campus;
    if (campusRaw is Map<String, dynamic>) {
      campus = CampusEntity.fromJson(campusRaw);
    } else if (campusRaw is String) {
      campus = CampusEntity(
        id: campusRaw,
        name: campusRaw,
        state: CampusStatusEnum.abierto,
        isActive: true,
        createdAt: DateTime.now(),
      );
    } else {
      // Fallback empty campus to avoid nulls
      campus = CampusEntity(
        id: '',
        name: '',
        state: CampusStatusEnum.abierto,
        isActive: true,
        createdAt: DateTime.now(),
      );
    }

    // isActive boolean
    final isActive = json['isActive'] is bool ? json['isActive'] as bool : (json['isActive'] == null ? true : json['isActive'].toString().toLowerCase() == 'true');

    // createdAt: try parse, fallback to now
    DateTime createdAt;
    try {
      createdAt = json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now();
    } catch (_) {
      createdAt = DateTime.now();
    }

    return RoomEntity(
      id: id,
      type: type,
      capacity: capacity,
      state: state,
      equipment: equipment,
      campus: campus,
      isActive: isActive,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'capacity': capacity,
        // Serialize enum as its canonical text value
        'state': state.toText(),
        'equipment': equipment,
        'campus': campus.toJson(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };
}
