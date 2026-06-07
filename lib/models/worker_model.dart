import 'package:cloud_firestore/cloud_firestore.dart';

enum WorkerCategory { mason, carpenter, electrician, plumber, painter, welder, helper, supervisor, other }
enum WorkerStatus { active, inactive, blacklisted }

class WorkerModel {
  final String id;
  final String name;
  final String phone;
  final String alternatePhone;
  final WorkerCategory category;
  final double dailyWage;
  final WorkerStatus status;
  final String? idProofUrl;
  final String idProofType;
  final DateTime? joinDate;
  final String address;
  final List<String> projectIds;
  final DateTime createdAt;

  WorkerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.alternatePhone = '',
    this.category = WorkerCategory.helper,
    this.dailyWage = 0,
    this.status = WorkerStatus.active,
    this.idProofUrl,
    this.idProofType = 'Aadhar',
    this.joinDate,
    this.address = '',
    this.projectIds = const [],
    required this.createdAt,
  });

  String get categoryLabel {
    switch (category) {
      case WorkerCategory.mason: return 'Mason';
      case WorkerCategory.carpenter: return 'Carpenter';
      case WorkerCategory.electrician: return 'Electrician';
      case WorkerCategory.plumber: return 'Plumber';
      case WorkerCategory.painter: return 'Painter';
      case WorkerCategory.welder: return 'Welder';
      case WorkerCategory.helper: return 'Helper';
      case WorkerCategory.supervisor: return 'Supervisor';
      case WorkerCategory.other: return 'Other';
    }
  }

  String get statusLabel {
    switch (status) {
      case WorkerStatus.active: return 'Active';
      case WorkerStatus.inactive: return 'Inactive';
      case WorkerStatus.blacklisted: return 'Blacklisted';
    }
  }

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'W';
  }

  factory WorkerModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return WorkerModel(
      id: doc.id,
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      alternatePhone: d['alternatePhone'] ?? '',
      category: _parseCategory(d['category']),
      dailyWage: (d['dailyWage'] as num?)?.toDouble() ?? 0,
      status: _parseStatus(d['status']),
      idProofUrl: d['idProofUrl'],
      idProofType: d['idProofType'] ?? 'Aadhar',
      joinDate: (d['joinDate'] as Timestamp?)?.toDate(),
      address: d['address'] ?? '',
      projectIds: List<String>.from(d['projectIds'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'name': name, 'phone': phone, 'alternatePhone': alternatePhone,
    'category': category.name, 'dailyWage': dailyWage, 'status': status.name,
    'idProofUrl': idProofUrl, 'idProofType': idProofType,
    'joinDate': joinDate != null ? Timestamp.fromDate(joinDate!) : null,
    'address': address, 'projectIds': projectIds,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  factory WorkerModel.fromMap(Map<String, dynamic> map) => WorkerModel(
    id: map['id'] ?? '',
    name: map['name'] ?? '',
    phone: map['phone'] ?? '',
    alternatePhone: map['alternate_phone'] ?? '',
    category: _parseCategory(map['category']),
    dailyWage: (map['daily_wage'] as num?)?.toDouble() ?? 0,
    status: _parseStatus(map['status']),
    idProofUrl: map['id_proof_url'],
    idProofType: map['id_proof_type'] ?? 'Aadhar',
    joinDate: map['join_date'] != null ? DateTime.tryParse(map['join_date']) : null,
    address: map['address'] ?? '',
    projectIds: [],
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'phone': phone, 'alternate_phone': alternatePhone,
    'category': category.name, 'daily_wage': dailyWage, 'status': status.name,
    'id_proof_url': idProofUrl, 'id_proof_type': idProofType,
    'join_date': joinDate?.toIso8601String(), 'address': address,
    'created_at': createdAt.toIso8601String(), 'synced': 0, 'pending_delete': 0,
  };

  WorkerModel copyWith({
    String? name, String? phone, String? alternatePhone,
    WorkerCategory? category, double? dailyWage, WorkerStatus? status,
    String? idProofUrl, String? idProofType, DateTime? joinDate, String? address,
  }) => WorkerModel(
    id: id, createdAt: createdAt, projectIds: projectIds,
    name: name ?? this.name, phone: phone ?? this.phone,
    alternatePhone: alternatePhone ?? this.alternatePhone,
    category: category ?? this.category, dailyWage: dailyWage ?? this.dailyWage,
    status: status ?? this.status, idProofUrl: idProofUrl ?? this.idProofUrl,
    idProofType: idProofType ?? this.idProofType, joinDate: joinDate ?? this.joinDate,
    address: address ?? this.address,
  );

  static WorkerCategory _parseCategory(dynamic val) {
    for (final c in WorkerCategory.values) {
      if (c.name == val?.toString()) return c;
    }
    return WorkerCategory.helper;
  }

  static WorkerStatus _parseStatus(dynamic val) {
    switch (val?.toString()) {
      case 'inactive': return WorkerStatus.inactive;
      case 'blacklisted': return WorkerStatus.blacklisted;
      default: return WorkerStatus.active;
    }
  }
}
