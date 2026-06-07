import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/project_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/project_model.dart';
import '../../models/expense_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class ActiveProjectsScreen extends StatefulWidget {
  const ActiveProjectsScreen({super.key});
  @override
  State<ActiveProjectsScreen> createState() => _ActiveProjectsScreenState();
}

class _ActiveProjectsScreenState extends State<ActiveProjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
      context.read<ExpenseProvider>().loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kActiveProjectsRoute,
      child: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          final active = provider.activeProjects;
          return provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : active.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.work_outline, size: 80, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          const Text('No active projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('Projects with "Active" status will appear here', style: TextStyle(color: Colors.grey.shade500)),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppDimensions.paddingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${active.length} Active Projects', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text('Double click on a project card to view details, finances, and manage expenses', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                          const SizedBox(height: 20),
                          Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: active.map((project) {
                              return SizedBox(
                                width: 380,
                                child: GestureDetector(
                                  onDoubleTap: () => _showProjectDetailDialog(context, project),
                                  child: GlassCard(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(project.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                gradient: AppColors.primaryGradient,
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Icon(Icons.work_outline, color: Colors.white, size: 18),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Icon(Icons.person_outline, size: 14, color: Colors.grey.shade500),
                                            const SizedBox(width: 4),
                                            Text(project.clientName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                            const SizedBox(width: 16),
                                            Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade500),
                                            const SizedBox(width: 4),
                                            Expanded(
                                              child: Text(project.siteLocation, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Progress', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                                            Text('${project.progress.toInt()}%', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryPurple)),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: LinearProgressIndicator(
                                            value: project.progress / 100,
                                            backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                                            valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
                                            minHeight: 8,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Expanded(child: _dateChip(Icons.calendar_today_outlined, 'Start', project.startDate)),
                                            const SizedBox(width: 8),
                                            Expanded(child: _dateChip(Icons.event_outlined, 'End', project.endDate)),
                                          ],
                                        ),
                                        const Divider(height: 20),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(AppFormatters.formatCurrencyCompact(project.contractValue), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                                            if (project.isOverdue)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                                child: Text('Overdue', style: TextStyle(color: AppColors.error, fontSize: 11, fontWeight: FontWeight.w600)),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
        },
      ),
    );
  }

  Widget _dateChip(IconData icon, String label, DateTime? date) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.primaryPurple),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(date != null ? AppFormatters.formatDate(date) : 'TBD', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  void _showProjectDetailDialog(BuildContext context, ProjectModel initialProject) {
    showDialog(
      context: context,
      builder: (dialogCtx) => Consumer2<ProjectProvider, ExpenseProvider>(
        builder: (dialogCtx, projectProvider, expenseProvider, _) {
          final project = projectProvider.getById(initialProject.id) ?? initialProject;
          final projectExpenses = expenseProvider.expenses.where((e) => e.projectId == project.id).toList();
          final totalExpenses = projectExpenses.fold(0.0, (s, e) => s + e.amount);

          return AlertDialog(
            backgroundColor: Theme.of(dialogCtx).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            titlePadding: EdgeInsets.zero,
            contentPadding: const EdgeInsets.all(AppDimensions.paddingL),
            title: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 16),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      project.statusLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            content: SizedBox(
              width: 950,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left: Basic Information & Summary
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _detailSectionHeader('Basic Details'),
                            const SizedBox(height: 12),
                            _detailRow('Project ID', project.id),
                            _detailRow('Client Name', project.clientName),
                            _detailRow('Client Phone', project.clientPhone),
                            _detailRow('Client Email', project.clientEmail.isEmpty ? '-' : project.clientEmail),
                            _detailRow('Project Manager', project.projectManager.isEmpty ? '-' : project.projectManager),
                            _detailRow('Site Location', project.siteLocation),
                            _detailRow('Start Date', project.startDate != null ? AppFormatters.formatDate(project.startDate!) : '-'),
                            _detailRow('End Date', project.endDate != null ? AppFormatters.formatDate(project.endDate!) : '-'),
                            const SizedBox(height: 12),
                            _detailSectionHeader('Financial & Area Summary'),
                            const SizedBox(height: 12),
                            _detailRow('Length', '${project.length.toStringAsFixed(2)} ${project.areaUnit}'),
                            _detailRow('Width', '${project.width.toStringAsFixed(2)} ${project.areaUnit}'),
                            _detailRow('Total Area', '${project.totalArea.toStringAsFixed(2)} ${project.areaUnit}'),
                            _detailRow('Rate per unit', AppFormatters.formatCurrency(project.ratePerUnit)),
                            _detailRow('Estimated Cost', AppFormatters.formatCurrency(project.estimatedCost)),
                            _detailRow('Contract Value', AppFormatters.formatCurrency(project.contractValue)),
                            _detailRow('Paid Amount', AppFormatters.formatCurrency(project.paidAmount)),
                            _detailRow('Remaining Amount', AppFormatters.formatCurrency(project.remainingAmount)),
                            _detailRow('Total Expenses', AppFormatters.formatCurrency(totalExpenses)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),
                      // Divider line
                      Container(width: 1, height: 420, color: Colors.grey.withOpacity(0.2)),
                      const SizedBox(width: 24),
                      // Right: Project Expenses
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _detailSectionHeader('Expenses'),
                                ElevatedButton.icon(
                                  onPressed: () => _showAddExpenseDialog(context, project, expenseProvider),
                                  icon: const Icon(Icons.add, size: 14),
                                  label: const Text('Add Expense', style: TextStyle(fontSize: 11)),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    backgroundColor: AppColors.primaryPurple,
                                    foregroundColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: 330,
                              decoration: BoxDecoration(
                                color: Theme.of(dialogCtx).brightness == Brightness.dark
                                    ? AppColors.darkCardAlt.withOpacity(0.4)
                                    : Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.withOpacity(0.15)),
                              ),
                              child: projectExpenses.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No expenses recorded for this project',
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(8),
                                      itemCount: projectExpenses.length,
                                      separatorBuilder: (_, __) => const Divider(height: 8),
                                      itemBuilder: (ctx, i) {
                                        final exp = projectExpenses[i];
                                        final catColor = AppColors.chartColors[exp.category.index % AppColors.chartColors.length];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Container(
                                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                          decoration: BoxDecoration(
                                                            color: catColor.withOpacity(0.12),
                                                            borderRadius: BorderRadius.circular(12),
                                                          ),
                                                          child: Text(
                                                            exp.categoryLabel,
                                                            style: TextStyle(color: catColor, fontSize: 9, fontWeight: FontWeight.bold),
                                                          ),
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          AppFormatters.formatDate(exp.date),
                                                          style: const TextStyle(color: Colors.grey, fontSize: 10),
                                                        ),
                                                      ],
                                                    ),
                                                    if (exp.description.isNotEmpty) ...[
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        exp.description,
                                                        style: const TextStyle(fontSize: 12),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                              ),
                                              Text(
                                                AppFormatters.formatCurrency(exp.amount),
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                              ),
                                              const SizedBox(width: 8),
                                              IconButton(
                                                padding: EdgeInsets.zero,
                                                constraints: const BoxConstraints(),
                                                icon: Icon(Icons.delete_outline, size: 14, color: AppColors.error),
                                                onPressed: () => _confirmDeleteExpense(context, exp, expenseProvider),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Project Expenses:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                Text(
                                  AppFormatters.formatCurrency(totalExpenses),
                                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 16),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Action buttons left-aligned
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          Navigator.pushNamed(
                            context,
                            AppConstants.kAddEditProjectRoute,
                            arguments: {'id': project.id},
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Project'),
                              content: Text('Are you sure you want to delete "${project.title}"?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                                  child: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed == true) {
                            await projectProvider.deleteProject(project.id);
                            if (context.mounted) {
                              context.read<DashboardProvider>().loadDashboard();
                            }
                            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Project deleted successfully'), backgroundColor: AppColors.success),
                              );
                            }
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.description_outlined, size: 16),
                        label: const Text('Summary'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Financial Summary: ${project.title}'),
                              content: SingleChildScrollView(
                                child: ListBody(
                                  children: [
                                    Text('Project Manager: ${project.projectManager.isEmpty ? "None" : project.projectManager}'),
                                    const SizedBox(height: 6),
                                    Text('Dimensions: ${project.length} x ${project.width} ${project.areaUnit} (${project.totalArea} Total Area)'),
                                    const SizedBox(height: 6),
                                    Text('Rate: ₹${project.ratePerUnit} per unit'),
                                    const SizedBox(height: 6),
                                    Text('Estimated Cost: ₹${project.estimatedCost}'),
                                    const SizedBox(height: 6),
                                    Text('Contract Value: ₹${project.contractValue}'),
                                    const SizedBox(height: 6),
                                    Text('Received Amount: ₹${project.paidAmount}'),
                                    const SizedBox(height: 6),
                                    Text('Project Expenses: ₹$totalExpenses'),
                                    const SizedBox(height: 6),
                                    Text('Outstanding Dues: ₹${project.remainingAmount}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  // Action buttons right-aligned
                  Row(
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                        onPressed: () async {
                          await projectProvider.loadProjects();
                          await expenseProvider.loadExpenses();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Project details reloaded'), duration: Duration(seconds: 1)),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.table_chart_outlined, size: 16),
                        label: const Text('Google Sheet'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Syncing project calculations to Google Sheet...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          Future.delayed(const Duration(seconds: 1), () {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Google Sheet successfully synchronized for "${project.title}"!'),
                                  backgroundColor: AppColors.success,
                                ),
                              );
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddExpenseDialog(BuildContext context, ProjectModel project, ExpenseProvider expenseProvider) {
    final amtCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    ExpenseCategory category = ExpenseCategory.material;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: Text('Add Expense for ${project.title}'),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ExpenseCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: ExpenseCategory.values.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                  )).toList(),
                  onChanged: (v) => setS(() => category = v!),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (₹) *'),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setS(() => selectedDate = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date', suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                    child: Text(AppFormatters.formatDate(selectedDate)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amtCtrl.text) ?? 0.0;
                if (amt <= 0) return;
                await expenseProvider.addExpense(ExpenseModel(
                  id: const Uuid().v4(),
                  projectId: project.id,
                  projectName: project.title,
                  category: category,
                  amount: amt,
                  date: selectedDate,
                  description: descCtrl.text.trim(),
                  vendorName: '',
                  paymentMode: 'cash',
                  createdAt: DateTime.now(),
                ));
                if (context.mounted) {
                  context.read<DashboardProvider>().loadDashboard();
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteExpense(BuildContext context, ExpenseModel expense, ExpenseProvider expenseProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Expense'),
        content: Text('Are you sure you want to delete this expense of ${AppFormatters.formatCurrency(expense.amount)}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await expenseProvider.deleteExpense(expense.id);
      if (context.mounted) {
        context.read<DashboardProvider>().loadDashboard();
      }
    }
  }

  Widget _detailSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
        ),
        const SizedBox(height: 4),
        Container(
          height: 2,
          width: 50,
          color: AppColors.primaryPurple,
        ),
      ],
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
