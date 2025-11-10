import 'package:jenix_event_manager/src/domain/entities/enum/campus_status_enum.dart';

class CampusEntity {
  final String id;
  final String name;
  final CampusStatusEnum state;
  final bool isActive;
  final DateTime createdAt;

  CampusEntity({
    required this.id,
    required this.name,
    required this.state,
    required this.isActive,
    required this.createdAt,
  });

  factory CampusEntity.fromJson(Map<String, dynamic> json) {
    return CampusEntity(
      id: json['id'],
      name: json['name'],
      // Parse the incoming state string into the enum. If parsing fails,
      // default to `abierto` to keep a sensible default.
      state: campusStatusEnumTryParse(json['state'] as String?) ?? CampusStatusEnum.abierto,
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        // Serialize enum as its canonical text value.
        'state': state.toText(),
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CampusEntity && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'CampusEntity(id: $id, name: $name)';
}
