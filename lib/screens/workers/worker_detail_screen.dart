import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../models/worker_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class WorkerDetailScreen extends StatelessWidget {
  final String workerId;
  const WorkerDetailScreen({super.key, required this.workerId});

  @override
  Widget build(BuildContext context) {
    final worker = context.read<WorkerProvider>().getById(workerId);
    if (worker == null) {
      return AppShell(currentRoute: AppConstants.kWorkersRoute, child: const Center(child: Text('Worker not found')));
    }

    return AppShell(
      currentRoute: AppConstants.kWorkersRoute,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 8),
                Text('Worker Details', style: Theme.of(context).textTheme.headlineMedium),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppConstants.kAddEditWorkerRoute, arguments: {'id': workerId}),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile card
                GlassCard(
                  width: 260,
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Center(
                          child: Text(worker.initials, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(worker.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(worker.categoryLabel, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: (worker.status == WorkerStatus.active ? AppColors.success : AppColors.error).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          worker.statusLabel,
                          style: TextStyle(
                            color: worker.status == WorkerStatus.active ? AppColors.success : AppColors.error,
                            fontSize: 12, fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Divider(height: 24),
                      _statItem('Daily Wage', AppFormatters.formatCurrency(worker.dailyWage), Icons.currency_rupee),
                      const SizedBox(height: 8),
                      _statItem('Phone', AppFormatters.formatPhoneNumber(worker.phone), Icons.phone_outlined),
                      if (worker.alternatePhone.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _statItem('Alt Phone', worker.alternatePhone, Icons.phone_outlined),
                      ],
                      if (worker.joinDate != null) ...[
                        const SizedBox(height: 8),
                        _statItem('Joined', AppFormatters.formatDate(worker.joinDate!), Icons.calendar_today_outlined),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Details
                Expanded(
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Contact & ID Details', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            const Divider(height: 20),
                            _row('ID Proof Type', worker.idProofType),
                            _row('Address', worker.address.isEmpty ? '-' : worker.address),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Monthly Earnings Estimate', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            const Divider(height: 20),
                            _row('Daily Rate', AppFormatters.formatCurrency(worker.dailyWage)),
                            _row('Monthly (26 days)', AppFormatters.formatCurrency(worker.dailyWage * 26)),
                            _row('Yearly Estimate', AppFormatters.formatCurrency(worker.dailyWage * 312)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryPurple),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
