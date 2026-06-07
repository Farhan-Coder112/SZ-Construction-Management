import 'package:cloud_firestore/cloud_firestore.dart';

enum ExpenseCategory { material, transport, labour, equipment, site, miscellaneous }

class ExpenseModel {
  final String id;
  final String projectId;
  final String projectName;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String description;
  final String vendorName;
  final String? billImageUrl;
  final String paymentMode;
  final String createdBy;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.projectId,
    this.projectName = '',
    required this.category,
    required this.amount,
    required this.date,
    this.description = '',
    this.vendorName = '',
    this.billImageUrl,
    this.paymentMode = 'cash',
    this.createdBy = '',
    required this.createdAt,
  });

  String get categoryLabel {
    switch (category) {
      case ExpenseCategory.material: return 'Material';
      case ExpenseCategory.transport: return 'Transport';
      case ExpenseCategory.labour: return 'Labour';
      case ExpenseCategory.equipment: return 'Equipment';
      case ExpenseCategory.site: return 'Site';
      case ExpenseCategory.miscellaneous: return 'Miscellaneous';
    }
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
    id: map['id'] ?? '',
    projectId: map['project_id'] ?? '',
    projectName: map['project_name'] ?? '',
    category: _parseCategory(map['category']),
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    description: map['description'] ?? '',
    vendorName: map['vendor_name'] ?? '',
    billImageUrl: map['bill_image_url'],
    paymentMode: map['payment_mode'] ?? 'cash',
    createdBy: map['created_by'] ?? '',
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'project_id': projectId, 'project_name': projectName,
    'category': category.name, 'amount': amount, 'date': date.toIso8601String(),
    'description': description, 'vendor_name': vendorName,
    'bill_image_url': billImageUrl, 'payment_mode': paymentMode,
    'created_by': createdBy, 'created_at': createdAt.toIso8601String(),
    'synced': 0, 'pending_delete': 0,
  };

  ExpenseModel copyWith({
    ExpenseCategory? category, double? amount, DateTime? date,
    String? description, String? vendorName, String? paymentMode,
  }) => ExpenseModel(
    id: id, projectId: projectId, projectName: projectName,
    createdBy: createdBy, createdAt: createdAt, billImageUrl: billImageUrl,
    category: category ?? this.category, amount: amount ?? this.amount,
    date: date ?? this.date, description: description ?? this.description,
    vendorName: vendorName ?? this.vendorName, paymentMode: paymentMode ?? this.paymentMode,
  );

  static ExpenseCategory _parseCategory(dynamic v) {
    for (final c in ExpenseCategory.values) {
      if (c.name == v?.toString()) return c;
    }
    return ExpenseCategory.miscellaneous;
  }
}
