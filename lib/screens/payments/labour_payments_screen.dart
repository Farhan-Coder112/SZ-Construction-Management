import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/payment_provider.dart';
import '../../models/payment_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class LabourPaymentsScreen extends StatefulWidget {
  const LabourPaymentsScreen({super.key});
  @override
  State<LabourPaymentsScreen> createState() => _LabourPaymentsScreenState();
}

class _LabourPaymentsScreenState extends State<LabourPaymentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<PaymentProvider>().loadPayments());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kLabourPaymentsRoute,
      child: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          final payments = provider.labourPayments;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingL),
                child: Row(
                  children: [
                    _summaryCard('Total Paid', AppFormatters.formatCurrencyCompact(provider.totalPaid), AppColors.success, Icons.check_circle_outline),
                    const SizedBox(width: 12),
                    _summaryCard('Pending', AppFormatters.formatCurrencyCompact(provider.totalPending), AppColors.warning, Icons.pending_outlined),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showAddDialog(context, provider),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Payment'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : payments.isEmpty
                        ? _buildEmpty()
                        : _buildTable(context, payments, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: color.withOpacity(0.8))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, List<PaymentModel> payments, PaymentProvider provider) {
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
                children: ['Worker/Reference', 'Amount', 'Paid', 'Due', 'Date', 'Mode', 'Status', '']
                    .map((h) => Expanded(child: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))))
                    .toList(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: payments.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final p = payments[i];
                  final statusColor = p.status == PaymentStatus.paid ? AppColors.success
                      : p.status == PaymentStatus.overdue ? AppColors.error : AppColors.warning;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(p.referenceName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                        Expanded(child: Text(AppFormatters.formatCurrencyCompact(p.amount), style: const TextStyle(fontSize: 12))),
                        Expanded(child: Text(AppFormatters.formatCurrencyCompact(p.paidAmount), style: TextStyle(fontSize: 12, color: AppColors.success))),
                        Expanded(child: Text(AppFormatters.formatCurrencyCompact(p.dueAmount), style: TextStyle(fontSize: 12, color: p.dueAmount > 0 ? AppColors.error : Colors.grey))),
                        Expanded(child: Text(AppFormatters.formatDate(p.date), style: const TextStyle(fontSize: 12))),
                        Expanded(child: Text(p.paymentMode.name.toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.grey))),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(p.status.name[0].toUpperCase() + p.status.name.substring(1), style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                          ),
                        ),
                        Expanded(child: IconButton(icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error), onPressed: () => provider.deletePayment(p.id))),
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No labour payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: () => _showAddDialog(context, context.read<PaymentProvider>()), icon: const Icon(Icons.add), label: const Text('Add Payment')),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, PaymentProvider provider) {
    final refCtrl = TextEditingController();
    final amtCtrl = TextEditingController();
    final paidCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    PaymentMode mode = PaymentMode.cash;
    PaymentStatus status = PaymentStatus.paid;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Labour Payment'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: refCtrl, decoration: const InputDecoration(labelText: 'Worker / Reference Name *')),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Amount ₹'))),
                    const SizedBox(width: 12),
                    Expanded(child: TextField(controller: paidCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Paid Amount ₹'))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: DropdownButtonFormField<PaymentMode>(
                      value: mode,
                      decoration: const InputDecoration(labelText: 'Payment Mode'),
                      items: PaymentMode.values.map((m) => DropdownMenuItem(value: m, child: Text(m.name.toUpperCase()))).toList(),
                      onChanged: (v) => setS(() => mode = v!),
                    )),
                    const SizedBox(width: 12),
                    Expanded(child: DropdownButtonFormField<PaymentStatus>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: PaymentStatus.values.map((s) => DropdownMenuItem(value: s, child: Text(s.name[0].toUpperCase() + s.name.substring(1)))).toList(),
                      onChanged: (v) => setS(() => status = v!),
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(controller: notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (refCtrl.text.isEmpty) return;
                final payment = PaymentModel(
                  id: const Uuid().v4(),
                  type: PaymentType.labourPayment,
                  referenceId: const Uuid().v4(),
                  referenceName: refCtrl.text.trim(),
                  amount: double.tryParse(amtCtrl.text) ?? 0,
                  paidAmount: double.tryParse(paidCtrl.text) ?? 0,
                  date: DateTime.now(),
                  status: status,
                  paymentMode: mode,
                  notes: notesCtrl.text,
                  createdAt: DateTime.now(),
                );
                await provider.addPayment(payment);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
