import 'package:cloud_firestore/cloud_firestore.dart';

enum ProjectStatus { planning, active, completed, onHold, cancelled }

class ProjectModel {
  final String id;
  final String title;
  final String clientName;
  final String clientPhone;
  final String clientEmail;
  final String siteLocation;
  final double contractValue;
  final double paidAmount;
  final DateTime? startDate;
  final DateTime? endDate;
  final ProjectStatus status;
  final double progress;
  final String description;
  final String engineerName;
  final String engineerId;
  final List<String> documents;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  // New Fields
  final double length;
  final double width;
  final String areaUnit;
  final double totalArea;
  final double ratePerUnit;
  final double estimatedCost;
  final String projectManager;

  ProjectModel({
    required this.id,
    required this.title,
    this.clientName = '',
    this.clientPhone = '',
    this.clientEmail = '',
    this.siteLocation = '',
    this.contractValue = 0,
    this.paidAmount = 0,
    this.startDate,
    this.endDate,
    this.status = ProjectStatus.planning,
    this.progress = 0,
    this.description = '',
    this.engineerName = '',
    this.engineerId = '',
    this.documents = const [],
    this.images = const [],
    required this.createdAt,
    required this.updatedAt,
    this.length = 0,
    this.width = 0,
    this.areaUnit = 'sqft',
    this.totalArea = 0,
    this.ratePerUnit = 0,
    this.estimatedCost = 0,
    this.projectManager = '',
  });

  double get remainingAmount => contractValue - paidAmount;
  double get paidPercent => contractValue > 0 ? (paidAmount / contractValue * 100).clamp(0, 100) : 0;
  bool get isOverdue => endDate != null && endDate!.isBefore(DateTime.now()) && status != ProjectStatus.completed;
  int get durationDays => startDate != null && endDate != null ? endDate!.difference(startDate!).inDays : 0;

  String get statusLabel {
    switch (status) {
      case ProjectStatus.planning: return 'Planning';
      case ProjectStatus.active: return 'Active';
      case ProjectStatus.completed: return 'Completed';
      case ProjectStatus.onHold: return 'On Hold';
      case ProjectStatus.cancelled: return 'Cancelled';
    }
  }

  factory ProjectModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ProjectModel(
      id: doc.id,
      title: d['title'] ?? '',
      clientName: d['clientName'] ?? '',
      clientPhone: d['clientPhone'] ?? '',
      clientEmail: d['clientEmail'] ?? '',
      siteLocation: d['siteLocation'] ?? '',
      contractValue: (d['contractValue'] as num?)?.toDouble() ?? 0,
      paidAmount: (d['paidAmount'] as num?)?.toDouble() ?? 0,
      startDate: (d['startDate'] as Timestamp?)?.toDate(),
      endDate: (d['endDate'] as Timestamp?)?.toDate(),
      status: _parseStatus(d['status']),
      progress: (d['progress'] as num?)?.toDouble() ?? 0,
      description: d['description'] ?? '',
      engineerName: d['engineerName'] ?? '',
      engineerId: d['engineerId'] ?? '',
      documents: List<String>.from(d['documents'] ?? []),
      images: List<String>.from(d['images'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      length: (d['length'] as num?)?.toDouble() ?? 0,
      width: (d['width'] as num?)?.toDouble() ?? 0,
      areaUnit: d['areaUnit'] ?? 'sqft',
      totalArea: (d['totalArea'] as num?)?.toDouble() ?? 0,
      ratePerUnit: (d['ratePerUnit'] as num?)?.toDouble() ?? 0,
      estimatedCost: (d['estimatedCost'] as num?)?.toDouble() ?? 0,
      projectManager: d['projectManager'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() => {
    'title': title, 'clientName': clientName, 'clientPhone': clientPhone,
    'clientEmail': clientEmail, 'siteLocation': siteLocation,
    'contractValue': contractValue, 'paidAmount': paidAmount,
    'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
    'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'status': status.name, 'progress': progress, 'description': description,
    'engineerName': engineerName, 'engineerId': engineerId,
    'documents': documents, 'images': images,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
    'length': length, 'width': width, 'areaUnit': areaUnit,
    'totalArea': totalArea, 'ratePerUnit': ratePerUnit,
    'estimatedCost': estimatedCost, 'projectManager': projectManager,
  };

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
    id: map['id'] ?? '',
    title: map['title'] ?? '',
    clientName: map['client_name'] ?? '',
    clientPhone: map['client_phone'] ?? '',
    clientEmail: map['client_email'] ?? '',
    siteLocation: map['site_location'] ?? '',
    contractValue: (map['contract_value'] as num?)?.toDouble() ?? 0,
    paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0,
    startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date']) : null,
    endDate: map['end_date'] != null ? DateTime.tryParse(map['end_date']) : null,
    status: _parseStatus(map['status']),
    progress: (map['progress'] as num?)?.toDouble() ?? 0,
    description: map['description'] ?? '',
    engineerName: map['engineer_name'] ?? '',
    engineerId: map['engineer_id'] ?? '',
    documents: [],
    images: [],
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updated_at'] ?? '') ?? DateTime.now(),
    length: (map['length'] as num?)?.toDouble() ?? 0,
    width: (map['width'] as num?)?.toDouble() ?? 0,
    areaUnit: map['area_unit'] ?? 'sqft',
    totalArea: (map['total_area'] as num?)?.toDouble() ?? 0,
    ratePerUnit: (map['rate_per_unit'] as num?)?.toDouble() ?? 0,
    estimatedCost: (map['estimated_cost'] as num?)?.toDouble() ?? 0,
    projectManager: map['project_manager'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'title': title, 'client_name': clientName,
    'client_phone': clientPhone, 'client_email': clientEmail,
    'site_location': siteLocation, 'contract_value': contractValue,
    'paid_amount': paidAmount,
    'start_date': startDate?.toIso8601String(),
    'end_date': endDate?.toIso8601String(),
    'status': status.name, 'progress': progress, 'description': description,
    'engineer_name': engineerName, 'engineer_id': engineerId,
    'length': length, 'width': width, 'area_unit': areaUnit,
    'total_area': totalArea, 'rate_per_unit': ratePerUnit,
    'estimated_cost': estimatedCost, 'project_manager': projectManager,
    'created_at': createdAt.toIso8601String(),
    'updated_at': DateTime.now().toIso8601String(),
    'synced': 0, 'pending_delete': 0,
  };

  ProjectModel copyWith({
    String? title, String? clientName, String? clientPhone, String? clientEmail,
    String? siteLocation, double? contractValue, double? paidAmount,
    DateTime? startDate, DateTime? endDate, ProjectStatus? status,
    double? progress, String? description, String? engineerName, String? engineerId,
    double? length, double? width, String? areaUnit, double? totalArea,
    double? ratePerUnit, double? estimatedCost, String? projectManager,
  }) => ProjectModel(
    id: id, createdAt: createdAt, updatedAt: DateTime.now(),
    documents: documents, images: images,
    title: title ?? this.title,
    clientName: clientName ?? this.clientName,
    clientPhone: clientPhone ?? this.clientPhone,
    clientEmail: clientEmail ?? this.clientEmail,
    siteLocation: siteLocation ?? this.siteLocation,
    contractValue: contractValue ?? this.contractValue,
    paidAmount: paidAmount ?? this.paidAmount,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    description: description ?? this.description,
    engineerName: engineerName ?? this.engineerName,
    engineerId: engineerId ?? this.engineerId,
    length: length ?? this.length,
    width: width ?? this.width,
    areaUnit: areaUnit ?? this.areaUnit,
    totalArea: totalArea ?? this.totalArea,
    ratePerUnit: ratePerUnit ?? this.ratePerUnit,
    estimatedCost: estimatedCost ?? this.estimatedCost,
    projectManager: projectManager ?? this.projectManager,
  );

  static ProjectStatus _parseStatus(dynamic val) {
    switch (val?.toString()) {
      case 'active': return ProjectStatus.active;
      case 'completed': return ProjectStatus.completed;
      case 'onHold': return ProjectStatus.onHold;
      case 'cancelled': return ProjectStatus.cancelled;
      default: return ProjectStatus.planning;
    }
  }
}
