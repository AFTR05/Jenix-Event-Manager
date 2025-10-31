import 'campus_entity.dart';

class Room {
  final String id;
  final String type;
  final int capacity;
  final String state;
  final List<String>? equipment;
  final Campus campus;
  final bool isActive;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.type,
    required this.capacity,
    required this.state,
    this.equipment,
    required this.campus,
    required this.isActive,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      type: json['type'],
      capacity: json['capacity'],
      state: json['state'],
      equipment: json['equipment'] != null
          ? List<String>.from(json['equipment'])
          : [],
      campus: Campus.fromJson(json['campus']),
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'capacity': capacity,
        'state': state,
        'equipment': equipment,
        'campus': campus.toJson(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };
}
