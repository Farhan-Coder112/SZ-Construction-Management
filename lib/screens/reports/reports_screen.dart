import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../services/reports_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});
  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isGenerating = false;
  String? _generatingReport;
  final ReportsService _reportsService = ReportsService();

  final List<_ReportType> _reports = [
    _ReportType('Financial Report', 'Revenue, expenses & profitability', Icons.account_balance_outlined, AppColors.primaryGradient),
    _ReportType('Labour Report', 'Attendance & payroll summary', Icons.engineering_outlined, AppColors.cardGradient2),
    _ReportType('Project Report', 'Project progress & completion', Icons.folder_outlined, AppColors.cardGradient3),
    _ReportType('Expense Report', 'Detailed expense breakdown', Icons.money_outlined, AppColors.cardGradient4),
    _ReportType('Client Payments', 'Client billing & receivables', Icons.receipt_long_outlined, AppColors.cardGradient5),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kReportsRoute,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date filter
            GlassCard(
              child: Row(
                children: [
                  const Icon(Icons.date_range_outlined, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Text('Report Period:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(width: 16),
                  _datePicker('From Date', _fromDate, true),
                  const SizedBox(width: 12),
                  _datePicker('To Date', _toDate, false),
                  const Spacer(),
                  if (_fromDate != null || _toDate != null)
                    TextButton.icon(
                      onPressed: () => setState(() { _fromDate = null; _toDate = null; }),
                      icon: const Icon(Icons.clear, size: 14),
                      label: const Text('Clear'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Select a Report', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Generate comprehensive reports in PDF or Excel format', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: _reports.map((r) => _buildReportCard(context, r)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(BuildContext context, _ReportType report) {
    final isGenerating = _isGenerating && _generatingReport == report.title;
    return SizedBox(
      width: 320,
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(gradient: report.gradient, borderRadius: BorderRadius.circular(14)),
                  child: Icon(report.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(report.description, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isGenerating)
              const Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator(strokeWidth: 2)))
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _generateReport(report.title, 'pdf'),
                      icon: const Icon(Icons.picture_as_pdf_outlined, size: 16),
                      label: const Text('PDF', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _generateReport(report.title, 'excel'),
                      icon: const Icon(Icons.table_chart_outlined, size: 16),
                      label: const Text('Excel', style: TextStyle(fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _datePicker(String label, DateTime? date, bool isFrom) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (d != null) setState(() { isFrom ? _fromDate = d : _toDate = d; });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 8),
            Text(
              date != null ? '${date.day}/${date.month}/${date.year}' : 'All time',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: date != null ? AppColors.primaryPurple : null),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generateReport(String title, String format) async {
    setState(() { _isGenerating = true; _generatingReport = title; });
    
    try {
      switch (title) {
        case 'Financial Report':
          if (format == 'pdf') {
            await _reportsService.generateFinancialReport(_fromDate, _toDate);
          } else {
            await _reportsService.generateFinancialReportExcel(_fromDate, _toDate);
          }
          break;
        case 'Labour Report':
          await _reportsService.generateLabourReport(_fromDate, _toDate);
          break;
        case 'Project Report':
          await _reportsService.generateProjectReport(_fromDate, _toDate);
          break;
        case 'Expense Report':
          await _reportsService.generateExpenseReport(_fromDate, _toDate);
          break;
        case 'Client Payments':
          await _reportsService.generateClientPaymentsReport(_fromDate, _toDate);
          break;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title ($format.toUpperCase()) generated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate report: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      setState(() { _isGenerating = false; _generatingReport = null; });
    }
  }
}

class _ReportType {
  final String title;
  final String description;
  final IconData icon;
  final Gradient gradient;
  const _ReportType(this.title, this.description, this.icon, this.gradient);
}
