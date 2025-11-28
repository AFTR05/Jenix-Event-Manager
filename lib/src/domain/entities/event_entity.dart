import 'package:jenix_event_manager/src/domain/entities/enum/modality_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/room_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';

class EventEntity {
  final String id;
  final String name;
  final DateTime initialDate;
  final DateTime finalDate;
  final String? beginHour;
  final String? endHour;
  final RoomEntity room;
  final String organizationArea;
  final String description;
  final String state;
  final UserEntity? responsablePerson; // <- puede ser nulo
  final ModalityType modality;
  final int maxAttendees;
  final String? urlImage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? deletedAt;

  EventEntity({
    required this.id,
    required this.name,
    this.beginHour,
    this.endHour,
    required this.initialDate,
    required this.finalDate,
    required this.room,
    required this.organizationArea,
    required this.description,
    required this.state,
    this.responsablePerson, // <- opcional
    required this.modality,
    required this.maxAttendees,
    required this.urlImage,
    required this.isActive,
    required this.createdAt,
    this.deletedAt,
  });

  factory EventEntity.fromJson(Map<String, dynamic> json) {
    return EventEntity(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      beginHour: json['beginHour'],
      endHour: json['endHour'],
      initialDate: DateTime.parse(json['initialDate']),
      finalDate: DateTime.parse(json['finalDate']),
      room: RoomEntity.fromJson(json['room']),
      organizationArea: json['organizationArea'] ?? '',
      description: json['description'] ?? '',
      state: json['state'] ?? '',
      responsablePerson: json['responsablePerson'] != null
          ? UserEntity.fromJson(json['responsablePerson'])
          : null, // <- si es nulo, asigna null
      modality: json['modality'] is String
          ? ModalityType.values.firstWhere(
              (m) => m.name == json['modality'],
              orElse: () => ModalityType.presential,
            )
          : ModalityType.values[json['modality'] ?? 0],
      maxAttendees: json['maxAttendees'] ?? 0,
      urlImage: json['urlImage'] ?? '',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
        : DateTime.now(),
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'beginHour': beginHour,
        'endHour': endHour,
        'initialDate': initialDate.toIso8601String(),
        'finalDate': finalDate.toIso8601String(),
        'room': room.toJson(),
        'organizationArea': organizationArea,
        'description': description,
        'state': state,
        'responsablePerson': responsablePerson?.toJson(), // <- puede ser null
        'modality': modality.name,
        'maxAttendees': maxAttendees,
        'urlImage': urlImage,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };
}
