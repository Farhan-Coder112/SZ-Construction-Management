import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/project_provider.dart';
import '../../models/daily_update_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../database/database_helper.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class DailyUpdatesScreen extends StatefulWidget {
  const DailyUpdatesScreen({super.key});
  @override
  State<DailyUpdatesScreen> createState() => _DailyUpdatesScreenState();
}

class _DailyUpdatesScreenState extends State<DailyUpdatesScreen> {
  List<DailyUpdateModel> _updates = [];
  bool _isLoading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjectProvider>().loadProjects();
      _loadUpdates();
    });
  }

  Future<void> _loadUpdates() async {
    setState(() => _isLoading = true);
    try {
      final dateStr = _selectedDate.toIso8601String().substring(0, 10);
      final rows = await DatabaseHelper.instance.getAll(
        'daily_updates',
        where: "date LIKE '$dateStr%' AND pending_delete = 0",
        orderBy: 'created_at DESC',
      );
      setState(() => _updates = rows.map((r) => DailyUpdateModel.fromMap(r)).toList());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kDailyUpdatesRoute,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _updates.isEmpty
                    ? _buildEmpty()
                    : _buildUpdateCards(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () { setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1))); _loadUpdates(); },
          ),
          TextButton.icon(
            icon: const Icon(Icons.calendar_today_outlined, size: 16),
            label: Text(AppFormatters.formatDate(_selectedDate), style: const TextStyle(fontWeight: FontWeight.w600)),
            onPressed: () async {
              final d = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now());
              if (d != null) { setState(() => _selectedDate = d); _loadUpdates(); }
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _selectedDate.isBefore(DateTime.now())
                ? () { setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1))); _loadUpdates(); }
                : null,
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 420, childAspectRatio: 1.3, crossAxisSpacing: 12, mainAxisSpacing: 12,
        ),
        itemCount: _updates.length,
        itemBuilder: (context, i) {
          final u = _updates[i];
          return GlassCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(u.projectName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                    Text(u.weatherEmoji, style: const TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.person_outline, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(u.engineerName.isEmpty ? 'Engineer' : u.engineerName, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(width: 12),
                  Icon(Icons.people_outline, size: 13, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text('${u.workersPresent} workers', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ]),
                const SizedBox(height: 8),
                if (u.description.isNotEmpty)
                  Text(u.description, style: const TextStyle(fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Progress', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('${u.progressPercentage.toInt()}%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryPurple)),
                    ]),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: SizedBox(
                        width: 120,
                        child: LinearProgressIndicator(
                          value: u.progressPercentage / 100,
                          backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
                          minHeight: 8,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.note_add_outlined, size: 80, color: Colors.grey.shade400),
      const SizedBox(height: 16),
      Text('No updates for ${AppFormatters.formatDate(_selectedDate)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 24),
      ElevatedButton.icon(onPressed: _showAddDialog, icon: const Icon(Icons.add), label: const Text('Add Update')),
    ]));
  }

  void _showAddDialog() {
    final projects = context.read<ProjectProvider>().activeProjects;
    String? projectId;
    String projectName = '';
    final descCtrl = TextEditingController();
    final workCtrl = TextEditingController();
    final matCtrl = TextEditingController();
    final issueCtrl = TextEditingController();
    WeatherType weather = WeatherType.sunny;
    double progress = 0;
    int workersCount = 0;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Daily Update'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (projects.isNotEmpty) DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Project *'),
                  items: projects.map((p) => DropdownMenuItem(value: p.id, child: Text(p.title))).toList(),
                  onChanged: (v) { projectId = v; projectName = projects.firstWhere((p) => p.id == v).title; },
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: DropdownButtonFormField<WeatherType>(
                    value: weather,
                    decoration: const InputDecoration(labelText: 'Weather'),
                    items: WeatherType.values.map((w) => DropdownMenuItem(value: w, child: Text('${_weatherEmoji(w)} ${w.name[0].toUpperCase() + w.name.substring(1)}'))).toList(),
                    onChanged: (v) => setS(() => weather = v!),
                  )),
                  const SizedBox(width: 12),
                  Expanded(child: TextFormField(
                    initialValue: '0',
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Workers Present'),
                    onChanged: (v) => workersCount = int.tryParse(v) ?? 0,
                  )),
                ]),
                const SizedBox(height: 12),
                TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description *', alignLabelWithHint: true)),
                const SizedBox(height: 12),
                TextField(controller: workCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'Work Done', alignLabelWithHint: true)),
                const SizedBox(height: 12),
                TextField(controller: matCtrl, decoration: const InputDecoration(labelText: 'Materials Used')),
                const SizedBox(height: 12),
                TextField(controller: issueCtrl, decoration: const InputDecoration(labelText: 'Issues / Observations')),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Progress: ${progress.toInt()}%'),
                  Expanded(child: Slider(
                    value: progress, min: 0, max: 100, divisions: 20,
                    activeColor: AppColors.primaryPurple,
                    onChanged: (v) => setS(() => progress = v),
                  )),
                ]),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (descCtrl.text.isEmpty) return;
                final update = DailyUpdateModel(
                  id: const Uuid().v4(),
                  projectId: projectId ?? '',
                  projectName: projectName,
                  date: _selectedDate,
                  description: descCtrl.text.trim(),
                  workDone: workCtrl.text.trim(),
                  workersPresent: workersCount,
                  materialsUsed: matCtrl.text.trim(),
                  issues: issueCtrl.text.trim(),
                  weather: weather,
                  progressPercentage: progress,
                  createdAt: DateTime.now(),
                );
                await DatabaseHelper.instance.insert('daily_updates', update.toMap());
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  _loadUpdates();
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  String _weatherEmoji(WeatherType w) {
    switch (w) {
      case WeatherType.sunny: return '☀️';
      case WeatherType.cloudy: return '⛅';
      case WeatherType.rainy: return '🌧️';
      case WeatherType.stormy: return '⛈️';
    }
  }
}
