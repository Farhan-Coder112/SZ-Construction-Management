import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { admin, manager, employee }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String? avatarUrl;
  final DateTime createdAt;
  final bool isActive;
  final String? companyId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.avatarUrl,
    required this.createdAt,
    required this.isActive,
    this.companyId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: _parseRole(data['role']),
      phone: data['phone'] ?? '',
      avatarUrl: data['avatarUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      companyId: data['companyId'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name,
    'email': email,
    'role': role.name,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'createdAt': Timestamp.fromDate(createdAt),
    'isActive': isActive,
    'companyId': companyId,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    role: _parseRole(json['role']),
    phone: json['phone'] ?? '',
    avatarUrl: json['avatarUrl'],
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    isActive: json['isActive'] ?? true,
    companyId: json['companyId'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'role': role.name,
    'phone': phone, 'avatarUrl': avatarUrl,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive, 'companyId': companyId,
  };

  UserModel copyWith({
    String? name, String? phone, String? avatarUrl,
    UserRole? role, bool? isActive,
  }) => UserModel(
    id: id, email: email, createdAt: createdAt, companyId: companyId,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    role: role ?? this.role,
    isActive: isActive ?? this.isActive,
  );

  static UserRole _parseRole(dynamic val) {
    switch (val?.toString()) {
      case 'admin': return UserRole.admin;
      case 'manager': return UserRole.manager;
      default: return UserRole.employee;
    }
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  String get roleLabel {
    switch (role) {
      case UserRole.admin: return 'Administrator';
      case UserRole.manager: return 'Manager';
      case UserRole.employee: return 'Employee';
    }
  }
}
