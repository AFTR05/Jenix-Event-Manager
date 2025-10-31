import 'package:jenix_event_manager/src/domain/entities/enum/modality_enum.dart';

import 'room_entity.dart';
import 'user_entity.dart';

class EventEntity {
  final String id;
  final String name;
  final DateTime date;
  final String? beginHour;
  final String? endHour;
  final Room room;
  final String organizationArea;
  final String description;
  final String state;
  final UserEntity responsablePerson; // puedes crear un modelo User si lo necesitas
  final ModalityType modality;
  final int maxAttendees;
  final String urlImage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? deletedAt;

  EventEntity({
    required this.id,
    required this.name,
    required this.date,
    this.beginHour,
    this.endHour,
    required this.room,
    required this.organizationArea,
    required this.description,
    required this.state,
    required this.responsablePerson,
    required this.modality,
    required this.maxAttendees,
    required this.urlImage,
    required this.isActive,
    required this.createdAt,
    this.deletedAt,
  });

  factory EventEntity.fromJson(Map<String, dynamic> json) {
    return EventEntity(
      id: json['id'],
      name: json['name'],
      date: DateTime.parse(json['date']),
      beginHour: json['beginHour'],
      endHour: json['endHour'],
      room: Room.fromJson(json['room']),
      organizationArea: json['organizationArea'],
      description: json['description'],
      state: json['state'],
      responsablePerson: json['responsablePerson'],
      modality: json['modality'],
      maxAttendees: json['maxAttendees'] ?? 0,
      urlImage: json['urlImage'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
      deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'date': date.toIso8601String(),
        'beginHour': beginHour,
        'endHour': endHour,
        'room': room.toJson(),
        'organizationArea': organizationArea,
        'description': description,
        'state': state,
        'responsablePerson': responsablePerson,
        'modality': modality,
        'maxAttendees': maxAttendees,
        'urlImage': urlImage,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };
}
