import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/worker_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/worker_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class WorkersScreen extends StatefulWidget {
  const WorkersScreen({super.key});
  @override
  State<WorkersScreen> createState() => _WorkersScreenState();
}

class _WorkersScreenState extends State<WorkersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => context.read<WorkerProvider>().loadWorkers());
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kWorkersRoute,
      child: Consumer<WorkerProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildTopBar(context, provider),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.workers.isEmpty
                        ? _buildEmptyState()
                        : _buildWorkersGrid(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WorkerProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          SizedBox(
            width: 280,
            child: TextField(
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search workers...',
                prefixIcon: const Icon(Icons.search_outlined, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          _filterChip('All', null, provider),
          const SizedBox(width: 6),
          for (final cat in [WorkerCategory.mason, WorkerCategory.carpenter, WorkerCategory.electrician, WorkerCategory.supervisor]) ...[
            _filterChip(cat.name[0].toUpperCase() + cat.name.substring(1), cat, provider),
            const SizedBox(width: 6),
          ],
          const Spacer(),
          Text('${provider.workers.length} workers', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(width: 16),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppConstants.kAddEditWorkerRoute).then((_) => provider.loadWorkers()),
            icon: const Icon(Icons.person_add_outlined, size: 16),
            label: const Text('Add Worker'),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, WorkerCategory? category, WorkerProvider provider) {
    final isSelected = category == null ? provider.workers.length == provider.allWorkers.length : false;
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 11)),
      selected: isSelected,
      onSelected: (_) => provider.setCategoryFilter(category),
      selectedColor: AppColors.primaryPurple.withOpacity(0.2),
    );
  }

  Widget _buildWorkersGrid(BuildContext context, WorkerProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          childAspectRatio: 0.85,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: provider.workers.length,
        itemBuilder: (context, index) {
          final worker = provider.workers[index];
          return _buildWorkerCard(context, worker, provider);
        },
      ),
    );
  }

  Widget _buildWorkerCard(BuildContext context, WorkerModel worker, WorkerProvider provider) {
    final isActive = worker.status == WorkerStatus.active;
    return GlassCard(
      onTap: () => Navigator.pushNamed(context, AppConstants.kWorkerDetailRoute, arguments: {'id': worker.id}),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(worker.initials, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                ),
              ),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.success : AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(worker.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(worker.categoryLabel, style: TextStyle(fontSize: 11, color: AppColors.primaryPurple, fontWeight: FontWeight.w500)),
          ),
          const SizedBox(height: 8),
          Text(AppFormatters.formatPhoneNumber(worker.phone), style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.currency_rupee, size: 13, color: AppColors.success),
              Text('${worker.dailyWage.toInt()}/day', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.success)),
            ],
          ),
          const Spacer(),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () => Navigator.pushNamed(context, AppConstants.kAddEditWorkerRoute, arguments: {'id': worker.id}).then((_) => provider.loadWorkers()),
                child: Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryPurple),
              ),
              InkWell(
                onTap: () => _confirmDelete(context, worker, provider),
                child: Icon(Icons.delete_outline, size: 18, color: AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WorkerModel worker, WorkerProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Worker'),
        content: Text('Delete "${worker.name}"? This action cannot be undone.'),
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
      await provider.deleteWorker(worker.id);
      if (context.mounted) {
        context.read<DashboardProvider>().loadDashboard();
      }
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No workers found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Add your first worker to get started', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppConstants.kAddEditWorkerRoute),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Add Worker'),
          ),
        ],
      ),
    );
  }
}
