import 'package:jenix_event_manager/src/domain/entities/enum/enrollment_status_enum.dart';

class EnrollmentEntity {
  final String id;
  final String? userId;
  final String? username;
  final String? eventId;
  final EnrollmentStatus status;
  final DateTime enrollmentDate;
  final DateTime? cancelledAt;
  final EventInfo? event;

  EnrollmentEntity({
    required this.id,
    this.userId,
    this.username,
    this.eventId,
    required this.status,
    required this.enrollmentDate,
    this.cancelledAt,
    this.event,
  });

  factory EnrollmentEntity.fromJson(Map<String, dynamic> json) {
    return EnrollmentEntity(
      id: json['enrollmentId'] as String,
      userId: json['userId'] as String?,
      username: json['username'] as String?,
      eventId: json['eventId'] as String?,
      status: EnrollmentStatus.fromString(json['status'] as String),
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
          : null,
      event: json['event'] != null
          ? EventInfo.fromJson(json['event'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'eventId': eventId,
      'status': status.value,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'event': event?.toJson(),
    };
  }
}

class EventInfo {
  final String id;
  final String name;
  final DateTime initialDate;
  final DateTime finalDate;
  final String? beginHour;
  final String? endHour;

  EventInfo({
    required this.id,
    required this.name,
    required this.initialDate,
    required this.finalDate,
    this.beginHour,
    this.endHour,
  });

  factory EventInfo.fromJson(Map<String, dynamic> json) {
    return EventInfo(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Sin nombre',
      initialDate: DateTime.parse(json['initialDate'] as String),
      finalDate: DateTime.parse(json['finalDate'] as String),
      beginHour: json['beginHour'] as String?,
      endHour: json['endHour'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'initialDate': initialDate.toIso8601String(),
      'finalDate': finalDate.toIso8601String(),
      'beginHour': beginHour,
      'endHour': endHour,
    };
  }
}
