import 'package:jenix_event_manager/src/domain/entities/enum/enrollment_status_enum.dart';

class EnrollmentEntity {
  final String id;
  final String? userId;
  final String? eventId;
  final EnrollmentStatus status;
  final DateTime enrollmentDate;
  final DateTime? cancelledAt;

  EnrollmentEntity({
    required this.id,
    this.userId,
    this.eventId,
    required this.status,
    required this.enrollmentDate,
    this.cancelledAt,
  });

  factory EnrollmentEntity.fromJson(Map<String, dynamic> json) {
    return EnrollmentEntity(
      id: json['enrollmentId'] as String,
      userId: json['userId'] as String?,
      eventId: json['eventId'] as String?,
      status: EnrollmentStatus.fromString(json['status'] as String),
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.parse(json['cancelledAt'] as String)
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
    };
  }
}
