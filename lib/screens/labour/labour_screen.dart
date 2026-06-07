import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/labour_provider.dart';
import '../../providers/worker_provider.dart';
import '../../providers/project_provider.dart';
import '../../models/labour_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class LabourScreen extends StatefulWidget {
  const LabourScreen({super.key});
  @override
  State<LabourScreen> createState() => _LabourScreenState();
}

class _LabourScreenState extends State<LabourScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LabourProvider>().loadEntries();
      context.read<WorkerProvider>().loadWorkers();
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kLabourRoute,
      child: Consumer<LabourProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildHeader(context, provider),
              _buildStats(provider),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.todayEntries.isEmpty
                        ? _buildEmpty()
                        : _buildTable(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, LabourProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => provider.setSelectedDate(provider.selectedDate.subtract(const Duration(days: 1))),
          ),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(AppFormatters.formatDate(provider.selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: provider.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) provider.setSelectedDate(d);
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: provider.selectedDate.isBefore(DateTime.now())
                ? () => provider.setSelectedDate(provider.selectedDate.add(const Duration(days: 1)))
                : null,
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddEntryDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Attendance'),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(LabourProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: Row(
        children: [
          _statBox('Present', provider.presentCount, AppColors.success),
          const SizedBox(width: 12),
          _statBox('Absent', provider.absentCount, AppColors.error),
          const SizedBox(width: 12),
          _statBox('Half Day', provider.halfDayCount, AppColors.warning),
        ],
      ),
    );
  }

  Widget _statBox(String label, int count, Color color) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontSize: 12, color: color.withOpacity(0.8))),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, LabourProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
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
                children: ['Worker', 'Project', 'Shift', 'Hours', 'OT', 'Status', 'Actions']
                    .map((h) => Expanded(child: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))))
                    .toList(),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: provider.todayEntries.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = provider.todayEntries[i];
                  final statusColor = e.attendanceStatus == AttendanceStatus.present
                      ? AppColors.success
                      : e.attendanceStatus == AttendanceStatus.absent
                          ? AppColors.error
                          : AppColors.warning;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(child: Text(e.workerName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                        Expanded(child: Text(e.projectName, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis)),
                        Expanded(child: Text(e.shiftType.name[0].toUpperCase() + e.shiftType.name.substring(1), style: const TextStyle(fontSize: 12))),
                        Expanded(child: Text('${e.hoursWorked}h', style: const TextStyle(fontSize: 12))),
                        Expanded(child: Text('${e.overtime}h', style: TextStyle(fontSize: 12, color: e.overtime > 0 ? AppColors.warning : Colors.grey))),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                            child: Text(e.attendanceStatus.name, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                          ),
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              IconButton(icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error), onPressed: () => provider.deleteEntry(e.id)),
                            ],
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.engineering_outlined, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('No attendance for ${AppFormatters.formatDate(context.read<LabourProvider>().selectedDate)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Add attendance entries for today', style: TextStyle(color: Colors.grey.shade500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(onPressed: () => _showAddEntryDialog(context), icon: const Icon(Icons.add), label: const Text('Add Attendance')),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final workers = context.read<WorkerProvider>().activeWorkers;
    final projects = context.read<ProjectProvider>().activeProjects;
    final provider = context.read<LabourProvider>();

    String? selectedWorkerId;
    String? selectedProjectId;
    AttendanceStatus status = AttendanceStatus.present;
    ShiftType shift = ShiftType.day;
    double hours = 8;
    double overtime = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Attendance Entry'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Worker *'),
                  items: workers.map((w) => DropdownMenuItem(value: w.id, child: Text(w.name))).toList(),
                  onChanged: (v) => setS(() => selectedWorkerId = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Project *'),
                  items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.title))).toList(),
                  onChanged: (v) => setS(() => selectedProjectId = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<AttendanceStatus>(
                        value: status,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: AttendanceStatus.values.map((s) => DropdownMenuItem(
                          value: s, child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                        )).toList(),
                        onChanged: (v) => setS(() => status = v!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<ShiftType>(
                        value: shift,
                        decoration: const InputDecoration(labelText: 'Shift'),
                        items: ShiftType.values.map((s) => DropdownMenuItem(
                          value: s, child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                        )).toList(),
                        onChanged: (v) => setS(() => shift = v!),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        initialValue: '8',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Hours'),
                        onChanged: (v) => hours = double.tryParse(v) ?? 8,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        initialValue: '0',
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Overtime (hrs)'),
                        onChanged: (v) => overtime = double.tryParse(v) ?? 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedWorkerId == null || selectedProjectId == null) return;
                final worker = context.read<WorkerProvider>().getById(selectedWorkerId!);
                final project = context.read<ProjectProvider>().getById(selectedProjectId!);
                final entry = LabourModel(
                  id: const Uuid().v4(),
                  workerId: selectedWorkerId!,
                  workerName: worker?.name ?? '',
                  projectId: selectedProjectId!,
                  projectName: project?.title ?? '',
                  date: provider.selectedDate,
                  hoursWorked: hours,
                  overtime: overtime,
                  shiftType: shift,
                  attendanceStatus: status,
                  createdAt: DateTime.now(),
                );
                await provider.addEntry(entry);
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
