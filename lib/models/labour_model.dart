import 'package:cloud_firestore/cloud_firestore.dart';

enum ShiftType { day, night, full }
enum AttendanceStatus { present, absent, halfDay, holiday }

class LabourModel {
  final String id;
  final String workerId;
  final String workerName;
  final String projectId;
  final String projectName;
  final DateTime date;
  final double hoursWorked;
  final double overtime;
  final ShiftType shiftType;
  final AttendanceStatus attendanceStatus;
  final String notes;
  final String createdBy;
  final DateTime createdAt;

  LabourModel({
    required this.id,
    required this.workerId,
    required this.workerName,
    required this.projectId,
    required this.projectName,
    required this.date,
    this.hoursWorked = 8,
    this.overtime = 0,
    this.shiftType = ShiftType.day,
    this.attendanceStatus = AttendanceStatus.present,
    this.notes = '',
    this.createdBy = '',
    required this.createdAt,
  });

  double get totalHours => attendanceStatus == AttendanceStatus.halfDay
      ? hoursWorked / 2
      : attendanceStatus == AttendanceStatus.absent
          ? 0
          : hoursWorked + overtime;

  double totalPay(double dailyWage) {
    switch (attendanceStatus) {
      case AttendanceStatus.absent: return 0;
      case AttendanceStatus.halfDay: return dailyWage / 2;
      case AttendanceStatus.holiday: return dailyWage * 1.5;
      case AttendanceStatus.present:
        final overtimePay = overtime * (dailyWage / 8) * 1.5;
        return dailyWage + overtimePay;
    }
  }

  factory LabourModel.fromMap(Map<String, dynamic> map) => LabourModel(
    id: map['id'] ?? '',
    workerId: map['worker_id'] ?? '',
    workerName: map['worker_name'] ?? '',
    projectId: map['project_id'] ?? '',
    projectName: map['project_name'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    hoursWorked: (map['hours_worked'] as num?)?.toDouble() ?? 8,
    overtime: (map['overtime'] as num?)?.toDouble() ?? 0,
    shiftType: _parseShift(map['shift_type']),
    attendanceStatus: _parseAttendance(map['attendance_status']),
    notes: map['notes'] ?? '',
    createdBy: map['created_by'] ?? '',
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'worker_id': workerId, 'worker_name': workerName,
    'project_id': projectId, 'project_name': projectName,
    'date': date.toIso8601String(), 'hours_worked': hoursWorked,
    'overtime': overtime, 'shift_type': shiftType.name,
    'attendance_status': attendanceStatus.name, 'notes': notes,
    'created_by': createdBy, 'created_at': createdAt.toIso8601String(),
    'synced': 0, 'pending_delete': 0,
  };

  LabourModel copyWith({
    double? hoursWorked, double? overtime, ShiftType? shiftType,
    AttendanceStatus? attendanceStatus, String? notes,
  }) => LabourModel(
    id: id, workerId: workerId, workerName: workerName,
    projectId: projectId, projectName: projectName, date: date,
    createdBy: createdBy, createdAt: createdAt,
    hoursWorked: hoursWorked ?? this.hoursWorked,
    overtime: overtime ?? this.overtime,
    shiftType: shiftType ?? this.shiftType,
    attendanceStatus: attendanceStatus ?? this.attendanceStatus,
    notes: notes ?? this.notes,
  );

  static ShiftType _parseShift(dynamic val) {
    switch (val?.toString()) {
      case 'night': return ShiftType.night;
      case 'full': return ShiftType.full;
      default: return ShiftType.day;
    }
  }

  static AttendanceStatus _parseAttendance(dynamic val) {
    switch (val?.toString()) {
      case 'absent': return AttendanceStatus.absent;
      case 'halfDay': return AttendanceStatus.halfDay;
      case 'holiday': return AttendanceStatus.holiday;
      default: return AttendanceStatus.present;
    }
  }
}
