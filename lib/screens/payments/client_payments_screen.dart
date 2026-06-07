import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/payment_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/payment_model.dart';
import '../../models/project_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class ClientPaymentsScreen extends StatefulWidget {
  const ClientPaymentsScreen({super.key});
  @override
  State<ClientPaymentsScreen> createState() => _ClientPaymentsScreenState();
}

class _ClientPaymentsScreenState extends State<ClientPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentProvider>().loadPayments();
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kClientPaymentsRoute,
      child: Consumer2<PaymentProvider, ProjectProvider>(
        builder: (context, paymentProvider, projectProvider, _) {
          final payments = paymentProvider.clientPayments;
          final totalBilled = payments.fold(0.0, (s, p) => s + p.amount); // total transactions
          final totalReceived = payments.fold(0.0, (s, p) => s + p.paidAmount);
          final totalDue = projectProvider.allProjects.fold(0.0, (s, p) => s + p.remainingAmount);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    _chip('Total Received', AppFormatters.formatCurrencyCompact(totalReceived), AppColors.success),
                    const SizedBox(width: 12),
                    _chip('Outstanding Dues', AppFormatters.formatCurrencyCompact(totalDue), AppColors.error),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDialog(context, paymentProvider, projectProvider),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Client Payment'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: paymentProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : payments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade400),
                                const SizedBox(height: 16),
                                const Text('No client payments yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )
                        : _buildTable(context, payments, paymentProvider, projectProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<PaymentModel> payments, PaymentProvider paymentProvider, ProjectProvider projectProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardAlt : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: Text('Project Name', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(child: Text('Payment Amount', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(child: Text('Payment Date', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  Expanded(child: Text('Payment Mode', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                  SizedBox(width: 50),
                ].toList(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: payments.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = payments[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            p.referenceName,
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AppFormatters.formatCurrency(p.paidAmount),
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            AppFormatters.formatDate(p.date),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              p.paymentMode.name.toUpperCase(),
                              style: TextStyle(color: AppColors.primaryBlue, fontSize: 11, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: IconButton(
                            icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error),
                            onPressed: () => _confirmDeletePayment(context, p, paymentProvider, projectProvider),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeletePayment(BuildContext context, PaymentModel payment, PaymentProvider paymentProvider, ProjectProvider projectProvider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Payment'),
        content: Text('Are you sure you want to delete this payment of ${AppFormatters.formatCurrency(payment.paidAmount)}? This will restore the remaining project balance.'),
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
      // Find the associated project and subtract from paidAmount
      final project = projectProvider.allProjects.firstWhere(
        (proj) => proj.id == payment.referenceId,
        orElse: () => ProjectModel(id: '', title: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      );
      if (project.id.isNotEmpty) {
        final updatedProject = project.copyWith(
          paidAmount: (project.paidAmount - payment.paidAmount).clamp(0, double.infinity),
        );
        await projectProvider.updateProject(updatedProject);
      }
      await paymentProvider.deletePayment(payment.id);
      if (context.mounted) {
        context.read<DashboardProvider>().loadDashboard();
      }
    }
  }

  void _showAddDialog(BuildContext context, PaymentProvider paymentProvider, ProjectProvider projectProvider) {
    final projects = projectProvider.allProjects;
    ProjectModel? selectedProject;
    
    final totalAmtCtrl = TextEditingController(text: '0.00');
    final remainingAmtCtrl = TextEditingController(text: '0.00');
    final paymentAmtCtrl = TextEditingController();
    
    DateTime selectedDate = DateTime.now();
    PaymentMode mode = PaymentMode.bank;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          void updateRemaining() {
            if (selectedProject == null) return;
            final paymentAmt = double.tryParse(paymentAmtCtrl.text) ?? 0;
            final remaining = selectedProject!.remainingAmount - paymentAmt;
            remainingAmtCtrl.text = remaining.toStringAsFixed(2);
          }

          return AlertDialog(
            title: const Text('Add Client Payment'),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Project Name Dropdown
                  DropdownButtonFormField<ProjectModel>(
                    decoration: const InputDecoration(labelText: 'Project Name *'),
                    value: selectedProject,
                    items: projects.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.title),
                    )).toList(),
                    onChanged: (proj) {
                      setS(() {
                        selectedProject = proj;
                        if (selectedProject != null) {
                          totalAmtCtrl.text = selectedProject!.contractValue.toStringAsFixed(2);
                          updateRemaining();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Total Amount (Auto filled, Read only)
                  TextFormField(
                    controller: totalAmtCtrl,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Total Amount (Contract Value)'),
                  ),
                  const SizedBox(height: 12),
                  // Remaining Amount (Auto calculated, Read only)
                  TextFormField(
                    controller: remainingAmtCtrl,
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Remaining Amount'),
                  ),
                  const SizedBox(height: 12),
                  // Payment Amount
                  TextFormField(
                    controller: paymentAmtCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Payment Amount (₹) *'),
                    onChanged: (v) {
                      setS(() {
                        updateRemaining();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Date Picker (Default to current date, Changeable)
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setS(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Payment Date',
                        suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                      ),
                      child: Text(AppFormatters.formatDate(selectedDate)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Payment Mode Dropdown
                  DropdownButtonFormField<PaymentMode>(
                    value: mode,
                    decoration: const InputDecoration(labelText: 'Payment Mode'),
                    items: PaymentMode.values.map((m) => DropdownMenuItem(
                      value: m,
                      child: Text(m.name.toUpperCase()),
                    )).toList(),
                    onChanged: (v) => setS(() => mode = v!),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (selectedProject == null) return;
                  final payAmt = double.tryParse(paymentAmtCtrl.text) ?? 0;
                  if (payAmt <= 0) return;

                  // Save the Payment Transaction
                  await paymentProvider.addPayment(PaymentModel(
                    id: const Uuid().v4(),
                    type: PaymentType.clientPayment,
                    referenceId: selectedProject!.id,
                    referenceName: selectedProject!.title,
                    amount: payAmt,
                    paidAmount: payAmt,
                    date: selectedDate,
                    status: PaymentStatus.paid,
                    paymentMode: mode,
                    createdAt: DateTime.now(),
                  ));

                  // Update the Project's Paid Amount
                  final updatedProj = selectedProject!.copyWith(
                    paidAmount: selectedProject!.paidAmount + payAmt,
                  );
                  await projectProvider.updateProject(updatedProj);
                  if (context.mounted) {
                    context.read<DashboardProvider>().loadDashboard();
                  }

                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}
