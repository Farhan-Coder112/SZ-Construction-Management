import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../models/project_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class ProjectDetailScreen extends StatefulWidget {
  final String projectId;
  const ProjectDetailScreen({super.key, required this.projectId});
  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final project = context.read<ProjectProvider>().getById(widget.projectId);
    if (project == null) {
      return AppShell(
        currentRoute: AppConstants.kProjectsRoute,
        child: const Center(child: Text('Project not found')),
      );
    }

    final statusColor = _statusColor(project.status);

    return AppShell(
      currentRoute: AppConstants.kProjectsRoute,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                const SizedBox(width: 8),
                Expanded(child: Text(project.title, style: Theme.of(context).textTheme.headlineMedium)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(project.statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, AppConstants.kAddEditProjectRoute, arguments: {'id': project.id}),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Project Overview', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        const Divider(height: 20),
                        _infoRow('Client', project.clientName),
                        _infoRow('Phone', project.clientPhone),
                        _infoRow('Email', project.clientEmail),
                        _infoRow('Site Location', project.siteLocation),
                        _infoRow('Site Engineer', project.engineerName),
                        _infoRow('Start Date', project.startDate != null ? AppFormatters.formatDate(project.startDate!) : 'Not set'),
                        _infoRow('End Date', project.endDate != null ? AppFormatters.formatDate(project.endDate!) : 'Not set'),
                        if (project.isOverdue)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.errorLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_outlined, color: AppColors.error, size: 16),
                                const SizedBox(width: 6),
                                Text('Project is overdue', style: TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Financial Summary', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            const Divider(height: 20),
                            _financialRow('Contract Value', AppFormatters.formatCurrency(project.contractValue)),
                            _financialRow('Amount Paid', AppFormatters.formatCurrency(project.paidAmount), color: AppColors.success),
                            _financialRow('Remaining', AppFormatters.formatCurrency(project.remainingAmount), color: AppColors.warning),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: project.paidPercent / 100,
                                backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                                valueColor: AlwaysStoppedAnimation(AppColors.success),
                                minHeight: 10,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text('${project.paidPercent.toStringAsFixed(1)}% paid', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Progress', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 100,
                                  height: 100,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        value: project.progress / 100,
                                        strokeWidth: 8,
                                        backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                                        valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
                                      ),
                                      Text('${project.progress.toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (project.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Description', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    const Divider(height: 20),
                    Text(project.description, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _financialRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Color _statusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.active: return AppColors.success;
      case ProjectStatus.completed: return AppColors.primaryPurple;
      case ProjectStatus.onHold: return AppColors.warning;
      case ProjectStatus.cancelled: return AppColors.error;
      default: return AppColors.primaryBlue;
    }
  }
}
