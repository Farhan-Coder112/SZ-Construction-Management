import 'package:cloud_firestore/cloud_firestore.dart';

enum PaymentType { labourPayment, clientPayment, advance, refund }
enum PaymentStatus { paid, pending, partial, overdue }
enum PaymentMode { cash, bank, cheque, upi, neft }

class PaymentModel {
  final String id;
  final PaymentType type;
  final String referenceId;
  final String referenceName;
  final double amount;
  final double paidAmount;
  final DateTime date;
  final DateTime? dueDate;
  final PaymentStatus status;
  final PaymentMode paymentMode;
  final String? receiptUrl;
  final String notes;
  final double gstAmount;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.type,
    required this.referenceId,
    required this.referenceName,
    required this.amount,
    this.paidAmount = 0,
    required this.date,
    this.dueDate,
    this.status = PaymentStatus.pending,
    this.paymentMode = PaymentMode.cash,
    this.receiptUrl,
    this.notes = '',
    this.gstAmount = 0,
    required this.createdAt,
  });

  double get dueAmount => (amount - paidAmount).clamp(0, double.infinity);
  double get totalWithGst => amount + gstAmount;

  factory PaymentModel.fromMap(Map<String, dynamic> map) => PaymentModel(
    id: map['id'] ?? '',
    type: _parseType(map['type']),
    referenceId: map['reference_id'] ?? '',
    referenceName: map['reference_name'] ?? '',
    amount: (map['amount'] as num?)?.toDouble() ?? 0,
    paidAmount: (map['paid_amount'] as num?)?.toDouble() ?? 0,
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date']) : null,
    status: _parseStatus(map['status']),
    paymentMode: _parseMode(map['payment_mode']),
    receiptUrl: map['receipt_url'],
    notes: map['notes'] ?? '',
    gstAmount: (map['gst_amount'] as num?)?.toDouble() ?? 0,
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type.name, 'reference_id': referenceId,
    'reference_name': referenceName, 'amount': amount, 'paid_amount': paidAmount,
    'date': date.toIso8601String(), 'due_date': dueDate?.toIso8601String(),
    'status': status.name, 'payment_mode': paymentMode.name,
    'receipt_url': receiptUrl, 'notes': notes, 'gst_amount': gstAmount,
    'created_at': createdAt.toIso8601String(), 'synced': 0, 'pending_delete': 0,
  };

  PaymentModel copyWith({
    double? amount, double? paidAmount, PaymentStatus? status,
    String? notes, DateTime? dueDate, PaymentMode? paymentMode,
  }) => PaymentModel(
    id: id, type: type, referenceId: referenceId, referenceName: referenceName,
    date: date, createdAt: createdAt, receiptUrl: receiptUrl, gstAmount: gstAmount,
    amount: amount ?? this.amount, paidAmount: paidAmount ?? this.paidAmount,
    status: status ?? this.status, notes: notes ?? this.notes,
    dueDate: dueDate ?? this.dueDate, paymentMode: paymentMode ?? this.paymentMode,
  );

  static PaymentType _parseType(dynamic v) {
    switch (v?.toString()) {
      case 'clientPayment': return PaymentType.clientPayment;
      case 'advance': return PaymentType.advance;
      case 'refund': return PaymentType.refund;
      default: return PaymentType.labourPayment;
    }
  }
  static PaymentStatus _parseStatus(dynamic v) {
    switch (v?.toString()) {
      case 'paid': return PaymentStatus.paid;
      case 'partial': return PaymentStatus.partial;
      case 'overdue': return PaymentStatus.overdue;
      default: return PaymentStatus.pending;
    }
  }
  static PaymentMode _parseMode(dynamic v) {
    switch (v?.toString()) {
      case 'bank': return PaymentMode.bank;
      case 'cheque': return PaymentMode.cheque;
      case 'upi': return PaymentMode.upi;
      case 'neft': return PaymentMode.neft;
      default: return PaymentMode.cash;
    }
  }
}
