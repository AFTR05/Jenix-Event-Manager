enum EnrollmentStatus {
  enrolled('ENROLLED'),
  waitlisted('WAITLISTED'),
  rejected('REJECTED'),
  cancelled('CANCELLED'),
  attended('ATTENDED'),
  noShow('NO_SHOW');

  final String value;
  const EnrollmentStatus(this.value);

  static EnrollmentStatus fromString(String value) {
    return EnrollmentStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => EnrollmentStatus.enrolled,
    );
  }
}