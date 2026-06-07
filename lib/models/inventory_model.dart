class InventoryModel {
  final String id;
  final String materialName;
  final String unit;
  final double quantity;
  final double minStock;
  final String supplier;
  final String supplierContact;
  final DateTime? purchaseDate;
  final double costPerUnit;
  final double usedQuantity;
  final String projectId;
  final String notes;
  final DateTime createdAt;

  InventoryModel({
    required this.id,
    required this.materialName,
    this.unit = 'Unit',
    this.quantity = 0,
    this.minStock = 5,
    this.supplier = '',
    this.supplierContact = '',
    this.purchaseDate,
    this.costPerUnit = 0,
    this.usedQuantity = 0,
    this.projectId = '',
    this.notes = '',
    required this.createdAt,
  });

  double get availableQuantity => (quantity - usedQuantity).clamp(0, double.infinity);
  double get totalCost => quantity * costPerUnit;
  bool get isLowStock => availableQuantity <= minStock;
  bool get isOutOfStock => availableQuantity <= 0;

  String get stockStatus {
    if (isOutOfStock) return 'Out of Stock';
    if (isLowStock) return 'Low Stock';
    return 'In Stock';
  }

  factory InventoryModel.fromMap(Map<String, dynamic> map) => InventoryModel(
    id: map['id'] ?? '',
    materialName: map['material_name'] ?? '',
    unit: map['unit'] ?? 'Unit',
    quantity: (map['quantity'] as num?)?.toDouble() ?? 0,
    minStock: (map['min_stock'] as num?)?.toDouble() ?? 5,
    supplier: map['supplier'] ?? '',
    supplierContact: map['supplier_contact'] ?? '',
    purchaseDate: map['purchase_date'] != null ? DateTime.tryParse(map['purchase_date']) : null,
    costPerUnit: (map['cost_per_unit'] as num?)?.toDouble() ?? 0,
    usedQuantity: (map['used_quantity'] as num?)?.toDouble() ?? 0,
    projectId: map['project_id'] ?? '',
    notes: map['notes'] ?? '',
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'material_name': materialName, 'unit': unit,
    'quantity': quantity, 'min_stock': minStock, 'supplier': supplier,
    'supplier_contact': supplierContact,
    'purchase_date': purchaseDate?.toIso8601String(),
    'cost_per_unit': costPerUnit, 'used_quantity': usedQuantity,
    'project_id': projectId, 'notes': notes,
    'created_at': createdAt.toIso8601String(), 'synced': 0, 'pending_delete': 0,
  };

  InventoryModel copyWith({
    String? materialName, String? unit, double? quantity, double? minStock,
    String? supplier, String? supplierContact, double? costPerUnit,
    double? usedQuantity, String? notes,
  }) => InventoryModel(
    id: id, projectId: projectId, purchaseDate: purchaseDate, createdAt: createdAt,
    materialName: materialName ?? this.materialName, unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity, minStock: minStock ?? this.minStock,
    supplier: supplier ?? this.supplier, supplierContact: supplierContact ?? this.supplierContact,
    costPerUnit: costPerUnit ?? this.costPerUnit, usedQuantity: usedQuantity ?? this.usedQuantity,
    notes: notes ?? this.notes,
  );
}
