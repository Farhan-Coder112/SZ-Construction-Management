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

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kProjectsRoute,
      child: Consumer<ProjectProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildTopBar(context, provider),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.projects.isEmpty
                        ? _buildEmptyState()
                        : _buildProjectsTable(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ProjectProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          // Search
          SizedBox(
            width: 300,
            child: TextField(
              controller: _searchController,
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: const Icon(Icons.search_outlined, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Status filter chips
          _buildFilterChip('All', null, provider),
          const SizedBox(width: 6),
          _buildFilterChip('Planning', ProjectStatus.planning, provider),
          const SizedBox(width: 6),
          _buildFilterChip('Active', ProjectStatus.active, provider),
          const SizedBox(width: 6),
          _buildFilterChip('Completed', ProjectStatus.completed, provider),
          const SizedBox(width: 6),
          _buildFilterChip('On Hold', ProjectStatus.onHold, provider),
          const Spacer(),
          // Add button
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppConstants.kAddEditProjectRoute),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Project'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryPurple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, ProjectStatus? status, ProjectProvider provider) {
    final isSelected = provider.statusFilter == status;
    return FilterChip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      selected: isSelected,
      onSelected: (_) => provider.setStatusFilter(isSelected ? null : status),
      selectedColor: AppColors.primaryPurple.withOpacity(0.2),
      checkmarkColor: AppColors.primaryPurple,
    );
  }

  Widget _buildProjectsTable(BuildContext context, ProjectProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: GlassCard(
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardAlt : Colors.grey.shade50,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
              ),
              child: Row(
                children: [
                  SizedBox(width: 40, child: Text('#', style: _headerStyle())),
                  Expanded(flex: 3, child: Text('Project', style: _headerStyle())),
                  Expanded(flex: 2, child: Text('Client', style: _headerStyle())),
                  Expanded(flex: 2, child: Text('Location', style: _headerStyle())),
                  Expanded(flex: 2, child: Text('Contract Value', style: _headerStyle())),
                  Expanded(flex: 2, child: Text('Progress', style: _headerStyle())),
                  SizedBox(width: 90, child: Text('Status', style: _headerStyle())),
                  SizedBox(width: 60, child: Text('Actions', style: _headerStyle())),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: provider.projects.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final project = provider.projects[index];
                  return _buildProjectRow(context, project, index + 1, provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectRow(BuildContext context, ProjectModel project, int index, ProjectProvider provider) {
    final statusColor = _getStatusColor(project.status);
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppConstants.kProjectDetailRoute, arguments: {'id': project.id}),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text('$index', style: Theme.of(context).textTheme.bodySmall),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(project.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  if (project.engineerName.isNotEmpty)
                    Text('Eng: ${project.engineerName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text(project.clientName, style: const TextStyle(fontSize: 13))),
            Expanded(
              flex: 2,
              child: Text(
                project.siteLocation,
                style: const TextStyle(fontSize: 13),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppFormatters.formatCurrencyCompact(project.contractValue),
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Text('Paid: ${AppFormatters.formatCurrencyCompact(project.paidAmount)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11)),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: project.progress / 100,
                      backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text('${project.progress.toStringAsFixed(0)}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            SizedBox(
              width: 90,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  project.statusLabel,
                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  tooltip: 'Edit',
                  onPressed: () => Navigator.pushNamed(
                    context, AppConstants.kAddEditProjectRoute,
                    arguments: {'id': project.id},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle() => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  Color _getStatusColor(ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planning: return AppColors.primaryBlue;
      case ProjectStatus.active: return AppColors.success;
      case ProjectStatus.completed: return AppColors.primaryPurple;
      case ProjectStatus.onHold: return AppColors.warning;
      case ProjectStatus.cancelled: return AppColors.error;
    }
  }

  Future<void> _confirmDelete(BuildContext context, ProjectModel project, ProjectProvider provider) async {
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
    if (confirmed == true) await provider.deleteProject(project.id);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('No projects found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Add your first project to get started', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppConstants.kAddEditProjectRoute),
            icon: const Icon(Icons.add),
            label: const Text('Add Project'),
          ),
        ],
      ),
    );
  }
}
