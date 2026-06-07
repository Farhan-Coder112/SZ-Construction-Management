import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../database/database_helper.dart';

class ExportService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<String?> exportProjectsToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Projects'];
      
      // Add headers
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Project Name');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Client Name');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Status');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Contract Value');
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Paid Amount');
      sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Start Date');
      sheet.cell(CellIndex.indexByString('G1')).value = TextCellValue('End Date');
      sheet.cell(CellIndex.indexByString('H1')).value = TextCellValue('Progress');
      sheet.cell(CellIndex.indexByString('I1')).value = TextCellValue('Location');

      // Fetch projects
      final projects = await _fetchProjects();
      
      // Add data
      for (var i = 0; i < projects.length; i++) {
        final p = projects[i];
        final row = i + 2;
        sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(p['project_name']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(p['client_name']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(p['status']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue('${p['contract_value'] ?? 0}');
        sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue('${p['paid_amount'] ?? 0}');
        sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(_formatDate(p['start_date']));
        sheet.cell(CellIndex.indexByString('G$row')).value = TextCellValue(_formatDate(p['end_date']));
        sheet.cell(CellIndex.indexByString('H$row')).value = TextCellValue('${p['progress'] ?? 0}%');
        sheet.cell(CellIndex.indexByString('I$row')).value = TextCellValue(p['site_location']?.toString() ?? '');
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, 'projects_export_${DateTime.now().millisecondsSinceEpoch}.xlsx');
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      
      return filePath;
    } catch (e) {
      print('Error exporting projects: $e');
      return null;
    }
  }

  Future<String?> exportWorkersToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Workers'];
      
      // Add headers
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Name');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Phone');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Category');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Daily Wage');
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Status');
      sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('ID Proof Type');

      // Fetch workers
      final workers = await _fetchWorkers();
      
      // Add data
      for (var i = 0; i < workers.length; i++) {
        final w = workers[i];
        final row = i + 2;
        sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(w['name']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(w['phone']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(w['category']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue('${w['daily_wage'] ?? 0}');
        sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(w['status']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(w['id_proof_type']?.toString() ?? '');
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, 'workers_export_${DateTime.now().millisecondsSinceEpoch}.xlsx');
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      
      return filePath;
    } catch (e) {
      print('Error exporting workers: $e');
      return null;
    }
  }

  Future<String?> exportExpensesToExcel() async {
    try {
      final excel = Excel.createExcel();
      final sheet = excel['Expenses'];
      
      // Add headers
      sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Date');
      sheet.cell(CellIndex.indexByString('B1')).value = TextCellValue('Category');
      sheet.cell(CellIndex.indexByString('C1')).value = TextCellValue('Description');
      sheet.cell(CellIndex.indexByString('D1')).value = TextCellValue('Amount');
      sheet.cell(CellIndex.indexByString('E1')).value = TextCellValue('Project');
      sheet.cell(CellIndex.indexByString('F1')).value = TextCellValue('Vendor');

      // Fetch expenses
      final expenses = await _fetchExpenses();
      
      // Add data
      for (var i = 0; i < expenses.length; i++) {
        final e = expenses[i];
        final row = i + 2;
        sheet.cell(CellIndex.indexByString('A$row')).value = TextCellValue(_formatDate(e['date']));
        sheet.cell(CellIndex.indexByString('B$row')).value = TextCellValue(e['category']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('C$row')).value = TextCellValue(e['description']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('D$row')).value = TextCellValue('${e['amount'] ?? 0}');
        sheet.cell(CellIndex.indexByString('E$row')).value = TextCellValue(e['project_name']?.toString() ?? '');
        sheet.cell(CellIndex.indexByString('F$row')).value = TextCellValue(e['vendor_name']?.toString() ?? '');
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, 'expenses_export_${DateTime.now().millisecondsSinceEpoch}.xlsx');
      final file = File(filePath);
      await file.writeAsBytes(excel.encode()!);
      
      return filePath;
    } catch (e) {
      print('Error exporting expenses: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProjects() async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      return await _db.getProjects();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchWorkers() async {
    try {
      final snapshot = await _firestore.collection('workers').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      return await _db.getWorkers();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchExpenses() async {
    try {
      final snapshot = await _firestore.collection('expenses').get();
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      return await _db.getExpenses();
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) return '${date.day}/${date.month}/${date.year}';
    if (date is Timestamp) return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    return date.toString();
  }

  Future<String?> exportToCSV(String tableName) async {
    try {
      final data = await _db.getAll(tableName);
      if (data.isEmpty) return null;

      final csv = StringBuffer();
      
      // Add headers
      final headers = data.first.keys.toList();
      csv.writeln(headers.join(','));
      
      // Add data rows
      for (final row in data) {
        final values = headers.map((key) {
          final value = row[key];
          if (value == null) return '';
          if (value is String) return '"${value.replaceAll('"', '""')}"';
          return value.toString();
        }).toList();
        csv.writeln(values.join(','));
      }

      // Save file
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, '${tableName}_export_${DateTime.now().millisecondsSinceEpoch}.csv');
      final file = File(filePath);
      await file.writeAsString(csv.toString());
      
      return filePath;
    } catch (e) {
      print('Error exporting to CSV: $e');
      return null;
    }
  }
}
