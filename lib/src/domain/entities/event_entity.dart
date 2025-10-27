// lib/src/domain/entities/event_entity.dart

import 'package:jenix_event_manager/src/domain/entities/modality_entity.dart';
import 'package:jenix_event_manager/src/domain/entities/user_entity.dart';

class EventEntity {
  final String id;
  final String name;
  final String organizationArea;
  final String description;
  final DateTime beginHour;
  final DateTime finishHour;
  final String status;
  final DateTime date;
  final String campus;
  final UserEntity responsible;
  final int maxAttendees;
  final List<UserEntity> participants;
  final ModalityType modality;
  final String? imageUrl; // Agregado para UI
  final bool isFavorite;

  EventEntity({
    required this.id,
    required this.name,
    required this.organizationArea,
    required this.description,
    required this.beginHour,
    required this.finishHour,
    required this.status,
    required this.date,
    required this.campus,
    required this.responsible,
    required this.maxAttendees,
    required this.participants,
    required this.modality,
    this.imageUrl,
    this.isFavorite = false,
  });
}
