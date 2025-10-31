class Campus {
  final String id;
  final String name;
  final String state;
  final bool isActive;
  final DateTime createdAt;

  Campus({
    required this.id,
    required this.name,
    required this.state,
    required this.isActive,
    required this.createdAt,
  });

  factory Campus.fromJson(Map<String, dynamic> json) {
    return Campus(
      id: json['id'],
      name: json['name'],
      state: json['state'],
      isActive: json['isActive'] ?? true,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };
}
