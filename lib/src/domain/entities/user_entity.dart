import 'dart:convert';

class UserEntity {
  final String email;
  final String name;
  final String phone;
  final String role;
  final String? accessToken;
  final String? refreshToken;

  const UserEntity({
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    this.accessToken,
    this.refreshToken,
  });

  UserEntity copyWith({
    String? email,
    String? name,
    String? phone,
    String? role,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserEntity(
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      email: (map['email'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      role: (map['role'] ?? '') as String,
      accessToken: map['accessToken'] as String?,
      refreshToken: map['refreshToken'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'role': role,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(Map<String, dynamic>.from(json.decode(source)));

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UserEntity(email: $email, name: $name, phone: $phone, role: $role, accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.email == email &&
        other.name == name &&
        other.phone == phone &&
        other.role == role &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(email, name, phone, role, accessToken, refreshToken);
}

// ...existing code...