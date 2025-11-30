import 'dart:convert';

import 'package:jenix_event_manager/src/domain/entities/enum/organization_area_enum.dart';
import 'package:jenix_event_manager/src/domain/entities/enum/role_enum.dart';

class UserEntity {
  final String id;
  final String email;
  final String name;
  final String phone;
  final RoleEnum role;
  final String documentNumber;
  final OrganizationAreaEnum? organizationArea;
  final String? accessToken;
  final String? refreshToken;

  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.documentNumber,
    required this.organizationArea,
    this.accessToken,
    this.refreshToken,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    RoleEnum? role,
    OrganizationAreaEnum? organizationArea,
    String? documentNumber,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      organizationArea: organizationArea ?? this.organizationArea,
      documentNumber: documentNumber ?? this.documentNumber,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      id: (map['id'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      name: (map['name'] ?? '') as String,
      phone: (map['phone'] ?? '') as String,
      role: RoleEnumExtension.fromString((map['role'] ?? 'user') as String),
      documentNumber: (map['documentNumber'] ?? '') as String,
      accessToken: map['accessToken'] as String?,
      refreshToken: map['refreshToken'] as String?,
      organizationArea: OrganizationAreaEnum.fromString(
              (map['organizationArea'] ?? '') as String,
            )
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'documentNumber': documentNumber,
      'role': role.value,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory UserEntity.fromJson(String source) =>
      UserEntity.fromMap(Map<String, dynamic>.from(json.decode(source)));

  String toJson() => json.encode(toMap());

  @override
  String toString() {
    return 'UserEntity(id: $id, email: $email, name: $name, phone: $phone, documentNumber: $documentNumber, role: $role, accessToken: $accessToken, refreshToken: $refreshToken)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserEntity &&
        other.id == id &&
        other.email == email &&
        other.name == name &&
        other.phone == phone &&
        other.documentNumber == documentNumber &&
        other.role == role &&
        other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => Object.hash(
    id,
    email,
    name,
    phone,
    documentNumber,
    role,
    accessToken,
    refreshToken,
  );
}

// ...existing code...
