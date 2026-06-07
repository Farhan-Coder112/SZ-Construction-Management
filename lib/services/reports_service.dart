import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:excel/excel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../database/database_helper.dart';

class ReportsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<void> generateFinancialReport(DateTime? fromDate, DateTime? toDate) async {
    final pdf = pw.Document();
    
    // Fetch data
    final expenses = await _fetchExpenses(fromDate, toDate);
    final payments = await _fetchPayments(fromDate, toDate);
    
    // Calculate totals
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + (e['amount'] as num? ?? 0));
    final totalRevenue = payments.fold<double>(0, (sum, p) => sum + (p['amount'] as num? ?? 0));
    final profit = totalRevenue - totalExpenses;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Financial Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Period: ${_formatDateRange(fromDate, toDate)}'),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Total Revenue:')),
                  pw.Text(_formatCurrency(totalRevenue), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Total Expenses:')),
                  pw.Text(_formatCurrency(totalExpenses), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Divider(),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Net Profit:')),
                  pw.Text(_formatCurrency(profit), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: profit >= 0 ? PdfColors.green : PdfColors.red)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Header(level: 1, child: pw.Text('Expenses')),
              _buildExpenseTable(expenses),
              pw.SizedBox(height: 20),
              pw.Header(level: 1, child: pw.Text('Payments')),
              _buildPaymentTable(payments),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> generateLabourReport(DateTime? fromDate, DateTime? toDate) async {
    final pdf = pw.Document();
    
    final labourData = await _fetchLabourData(fromDate, toDate);
    final totalHours = labourData.fold<double>(0, (sum, l) => sum + (l['hours_worked'] as num? ?? 0));
    final totalOvertime = labourData.fold<double>(0, (sum, l) => sum + (l['overtime'] as num? ?? 0));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Labour Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Period: ${_formatDateRange(fromDate, toDate)}'),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Total Hours Worked:')),
                  pw.Text('${totalHours.toStringAsFixed(1)} hrs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Total Overtime:')),
                  pw.Text('${totalOvertime.toStringAsFixed(1)} hrs', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Header(level: 1, child: pw.Text('Labour Details')),
              _buildLabourTable(labourData),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> generateProjectReport(DateTime? fromDate, DateTime? toDate) async {
    final pdf = pw.Document();
    
    final projects = await _fetchProjects();
    final activeProjects = projects.where((p) => p['status'] == 'active').length;
    final completedProjects = projects.where((p) => p['status'] == 'completed').length;

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Project Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Total Projects:')),
                  pw.Text('${projects.length}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Active Projects:')),
                  pw.Text('$activeProjects', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Completed Projects:')),
                  pw.Text('$completedProjects', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Header(level: 1, child: pw.Text('Project Details')),
              _buildProjectTable(projects),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> generateExpenseReport(DateTime? fromDate, DateTime? toDate) async {
    final pdf = pw.Document();
    
    final expenses = await _fetchExpenses(fromDate, toDate);
    final totalExpenses = expenses.fold<double>(0, (sum, e) => sum + (e['amount'] as num? ?? 0));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Expense Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Period: ${_formatDateRange(fromDate, toDate)}'),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Total Expenses:')),
                  pw.Text(_formatCurrency(totalExpenses), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Header(level: 1, child: pw.Text('Expense Details')),
              _buildExpenseTable(expenses),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> generateClientPaymentsReport(DateTime? fromDate, DateTime? toDate) async {
    final pdf = pw.Document();
    
    final payments = await _fetchPayments(fromDate, toDate);
    final totalPayments = payments.fold<double>(0, (sum, p) => sum + (p['amount'] as num? ?? 0));
    final pendingPayments = payments.where((p) => p['status'] == 'pending').fold<double>(0, (sum, p) => sum + (p['amount'] as num? ?? 0));

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Client Payments Report', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Period: ${_formatDateRange(fromDate, toDate)}'),
              pw.SizedBox(height: 20),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Total Payments:')),
                  pw.Text(_formatCurrency(totalPayments), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Text('Pending Payments:')),
                  pw.Text(_formatCurrency(pendingPayments), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.orange)),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Header(level: 1, child: pw.Text('Payment Details')),
              _buildPaymentTable(payments),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> generateFinancialReportExcel(DateTime? fromDate, DateTime? toDate) async {
    final excel = Excel.createExcel();
    final sheet = excel['Financial Report'];
    
    final expenses = await _fetchExpenses(fromDate, toDate);
    final payments = await _fetchPayments(fromDate, toDate);
    
    sheet.cell(CellIndex.indexByString('A1')).value = TextCellValue('Financial Report');
    sheet.cell(CellIndex.indexByString('A2')).value = TextCellValue('Period: ${_formatDateRange(fromDate, toDate)}');
    
    sheet.cell(CellIndex.indexByString('A4')).value = TextCellValue('Category');
    sheet.cell(CellIndex.indexByString('B4')).value = TextCellValue('Amount');
    
    sheet.cell(CellIndex.indexByString('A5')).value = TextCellValue('Total Revenue');
    sheet.cell(CellIndex.indexByString('B5')).value = TextCellValue(_formatCurrency(payments.fold<double>(0, (sum, p) => sum + (p['amount'] as num? ?? 0))));
    
    sheet.cell(CellIndex.indexByString('A6')).value = TextCellValue('Total Expenses');
    sheet.cell(CellIndex.indexByString('B6')).value = TextCellValue(_formatCurrency(expenses.fold<double>(0, (sum, e) => sum + (e['amount'] as num? ?? 0))));
    
    sheet.cell(CellIndex.indexByString('A8')).value = TextCellValue('Expense Details');
    sheet.cell(CellIndex.indexByString('A9')).value = TextCellValue('Date');
    sheet.cell(CellIndex.indexByString('B9')).value = TextCellValue('Description');
    sheet.cell(CellIndex.indexByString('C9')).value = TextCellValue('Amount');
    
    for (var i = 0; i < expenses.length; i++) {
      final exp = expenses[i];
      sheet.cell(CellIndex.indexByString('A${i + 10}')).value = TextCellValue(_formatDate(exp['date']));
      sheet.cell(CellIndex.indexByString('B${i + 10}')).value = TextCellValue(exp['description']?.toString() ?? '');
      sheet.cell(CellIndex.indexByString('C${i + 10}')).value = TextCellValue(_formatCurrency(exp['amount'] as num? ?? 0));
    }
    
    final bytes = excel.encode();
    // Save file logic would go here
  }

  Future<List<Map<String, dynamic>>> _fetchExpenses(DateTime? fromDate, DateTime? toDate) async {
    try {
      Query query = _firestore.collection('expenses');
      if (fromDate != null) query = query.where('date', isGreaterThanOrEqualTo: fromDate);
      if (toDate != null) query = query.where('date', isLessThanOrEqualTo: toDate);
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // Fallback to local database
      final data = await _db.getAll('expenses');
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchPayments(DateTime? fromDate, DateTime? toDate) async {
    try {
      Query query = _firestore.collection('payments');
      if (fromDate != null) query = query.where('date', isGreaterThanOrEqualTo: fromDate);
      if (toDate != null) query = query.where('date', isLessThanOrEqualTo: toDate);
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // Fallback to local database
      final data = await _db.getAll('payments');
      return data.map((p) => Map<String, dynamic>.from(p)).toList();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchLabourData(DateTime? fromDate, DateTime? toDate) async {
    try {
      Query query = _firestore.collection('labour');
      if (fromDate != null) query = query.where('date', isGreaterThanOrEqualTo: fromDate);
      if (toDate != null) query = query.where('date', isLessThanOrEqualTo: toDate);
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // Fallback to local database
      final data = await _db.getAll('labour');
      return data.map((l) => Map<String, dynamic>.from(l)).toList();
    }
  }

  Future<List<Map<String, dynamic>>> _fetchProjects() async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      // Fallback to local database
      final data = await _db.getAll('projects');
      return data.map((p) => Map<String, dynamic>.from(p)).toList();
    }
  }

  pw.Table _buildExpenseTable(List<Map<String, dynamic>> expenses) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(2),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Description', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        ...expenses.map((exp) => pw.TableRow(
          children: [
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_formatDate(exp['date']))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(exp['description']?.toString() ?? '')),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(exp['amount'] as num? ?? 0))),
          ],
        )),
      ],
    );
  }

  pw.Table _buildPaymentTable(List<Map<String, dynamic>> payments) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(2),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Client', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Amount', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        ...payments.map((pay) => pw.TableRow(
          children: [
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_formatDate(pay['date']))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(pay['client_name']?.toString() ?? '')),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(pay['amount'] as num? ?? 0))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(pay['status']?.toString() ?? '')),
          ],
        )),
      ],
    );
  }

  pw.Table _buildLabourTable(List<Map<String, dynamic>> labour) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Worker', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Hours', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Overtime', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        ...labour.map((l) => pw.TableRow(
          children: [
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_formatDate(l['date']))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(l['worker_name']?.toString() ?? '')),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${l['hours_worked'] ?? 0}')),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('${l['overtime'] ?? 0}')),
          ],
        )),
      ],
    );
  }

  pw.Table _buildProjectTable(List<Map<String, dynamic>> projects) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(2),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        pw.TableRow(
          children: [
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Project', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Client', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Value', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold))),
          ],
        ),
        ...projects.map((p) => pw.TableRow(
          children: [
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(p['project_name']?.toString() ?? '')),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(p['client_name']?.toString() ?? '')),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(_formatCurrency(p['contract_value'] as num? ?? 0))),
            pw.Padding(padding: pw.EdgeInsets.all(8), child: pw.Text(p['status']?.toString() ?? '')),
          ],
        )),
      ],
    );
  }

  String _formatDateRange(DateTime? from, DateTime? to) {
    if (from == null && to == null) return 'All time';
    if (from == null) return 'Until ${_formatDate(to)}';
    if (to == null) return 'From ${_formatDate(from)}';
    return '${_formatDate(from)} - ${_formatDate(to)}';
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) return '${date.day}/${date.month}/${date.year}';
    if (date is Timestamp) return '${date.toDate().day}/${date.toDate().month}/${date.toDate().year}';
    return date.toString();
  }

  String _formatCurrency(num amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }
}
