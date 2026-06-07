import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/project_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/formatters.dart';

class AddEditProjectScreen extends StatefulWidget {
  final String? projectId;
  const AddEditProjectScreen({super.key, this.projectId});

  @override
  State<AddEditProjectScreen> createState() => _AddEditProjectScreenState();
}

class _AddEditProjectScreenState extends State<AddEditProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _projectIdCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _clientNameCtrl = TextEditingController();
  final _clientPhoneCtrl = TextEditingController();
  final _clientEmailCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _projectManagerCtrl = TextEditingController();

  final _lengthCtrl = TextEditingController();
  final _widthCtrl = TextEditingController();
  final _totalAreaCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _estimatedCostCtrl = TextEditingController();
  final _contractValueCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();

  String _areaUnit = 'sqft';
  DateTime? _startDate;
  DateTime? _endDate;
  ProjectStatus _status = ProjectStatus.planning;
  double _progress = 0;
  bool _isSaving = false;
  bool get _isEditing => widget.projectId != null;

  final List<String> _areaUnitsList = ['sqft', 'sqm', 'sqyd', 'sqinch', 'acre', 'hectare'];

  @override
  void initState() {
    super.initState();
    _lengthCtrl.addListener(_calculateAreaAndCost);
    _widthCtrl.addListener(_calculateAreaAndCost);
    _rateCtrl.addListener(_calculateAreaAndCost);

    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadProject());
    } else {
      _projectIdCtrl.text = 'SZ-PRJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      _startDate = DateTime.now();
      _endDate = DateTime.now();
    }
  }

  void _calculateAreaAndCost() {
    final len = double.tryParse(_lengthCtrl.text) ?? 0.0;
    final wid = double.tryParse(_widthCtrl.text) ?? 0.0;
    final rate = double.tryParse(_rateCtrl.text) ?? 0.0;
    final area = len * wid;
    final cost = area * rate;
    
    // Using scheduleMicrotask or checking if controllers have focus to avoid setState during build
    _totalAreaCtrl.text = area > 0 ? area.toStringAsFixed(2) : '0.00';
    _estimatedCostCtrl.text = cost > 0 ? cost.toStringAsFixed(2) : '0.00';
  }

  void _loadProject() {
    final project = context.read<ProjectProvider>().getById(widget.projectId!);
    if (project != null) {
      _projectIdCtrl.text = project.id;
      _titleCtrl.text = project.title;
      _clientNameCtrl.text = project.clientName;
      _clientPhoneCtrl.text = project.clientPhone;
      _clientEmailCtrl.text = project.clientEmail;
      _locationCtrl.text = project.siteLocation;
      _projectManagerCtrl.text = project.projectManager;

      _lengthCtrl.text = project.length.toString();
      _widthCtrl.text = project.width.toString();
      _areaUnit = _areaUnitsList.contains(project.areaUnit) ? project.areaUnit : 'sqft';
      _rateCtrl.text = project.ratePerUnit.toString();
      _contractValueCtrl.text = project.contractValue.toString();
      _descriptionCtrl.text = project.description;

      _startDate = project.startDate;
      _endDate = project.endDate;
      _status = project.status;
      _progress = project.progress;

      _calculateAreaAndCost();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _projectIdCtrl.dispose();
    _titleCtrl.dispose();
    _clientNameCtrl.dispose();
    _clientPhoneCtrl.dispose();
    _clientEmailCtrl.dispose();
    _locationCtrl.dispose();
    _projectManagerCtrl.dispose();
    _lengthCtrl.dispose();
    _widthCtrl.dispose();
    _totalAreaCtrl.dispose();
    _rateCtrl.dispose();
    _estimatedCostCtrl.dispose();
    _contractValueCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<ProjectProvider>();

    final len = double.tryParse(_lengthCtrl.text) ?? 0.0;
    final wid = double.tryParse(_widthCtrl.text) ?? 0.0;
    final area = len * wid;
    final rate = double.tryParse(_rateCtrl.text) ?? 0.0;
    final estCost = area * rate;

    final project = ProjectModel(
      id: _projectIdCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      clientName: _clientNameCtrl.text.trim(),
      clientPhone: _clientPhoneCtrl.text.trim(),
      clientEmail: _clientEmailCtrl.text.trim(),
      siteLocation: _locationCtrl.text.trim(),
      projectManager: _projectManagerCtrl.text.trim(),
      contractValue: double.tryParse(_contractValueCtrl.text) ?? 0,
      paidAmount: _isEditing ? (provider.getById(widget.projectId!)?.paidAmount ?? 0) : 0,
      startDate: _startDate,
      endDate: _endDate,
      status: _status,
      progress: _progress,
      description: _descriptionCtrl.text.trim(),
      length: len,
      width: wid,
      areaUnit: _areaUnit,
      totalArea: area,
      ratePerUnit: rate,
      estimatedCost: estCost,
      createdAt: _isEditing ? (provider.getById(widget.projectId!)?.createdAt ?? DateTime.now()) : DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (_isEditing) {
        await provider.updateProject(project);
      } else {
        await provider.addProject(project);
      }
      if (mounted) {
        context.read<DashboardProvider>().loadDashboard();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Project ${_isEditing ? 'updated' : 'added'} successfully'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save project: $e'), backgroundColor: AppColors.error),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        isStart ? _startDate = picked : _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kProjectsRoute,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                  const SizedBox(width: 8),
                  Text(
                    _isEditing ? 'Edit Project' : 'Add New Project',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildBasicInfoCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildFinancialCard()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildStatusCard()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDescriptionCard()),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : Text(_isEditing ? 'Update Project' : 'Save Project'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Basic Information'),
          const SizedBox(height: 16),
          // Project ID (Disabled, Auto-generated)
          TextFormField(
            controller: _projectIdCtrl,
            enabled: false,
            decoration: const InputDecoration(
              labelText: 'Project ID (Auto Generated)',
              disabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
          const SizedBox(height: 12),
          _field('Project Name *', _titleCtrl, validator: (v) => AppValidators.validateRequired(v, 'Project name')),
          const SizedBox(height: 12),
          _field('Client Name *', _clientNameCtrl, validator: (v) => AppValidators.validateRequired(v, 'Client name')),
          const SizedBox(height: 12),
          _field('Client Phone *', _clientPhoneCtrl, validator: AppValidators.validatePhone, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _field('Client Email', _clientEmailCtrl, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _field('Site Address', _locationCtrl),
          const SizedBox(height: 12),
          _field('Project Manager', _projectManagerCtrl),
        ],
      ),
    );
  }

  Widget _buildFinancialCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Financial Details'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _field('Length *', _lengthCtrl, validator: AppValidators.validatePositiveAmount, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(child: _field('Width *', _widthCtrl, validator: AppValidators.validatePositiveAmount, keyboardType: TextInputType.number)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _areaUnit,
                  decoration: const InputDecoration(labelText: 'Area Unit *'),
                  items: _areaUnitsList.map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(unit),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _areaUnit = val;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _totalAreaCtrl,
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'Total Area (Auto)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field('Rate per unit', _rateCtrl, keyboardType: TextInputType.number)),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _estimatedCostCtrl,
                  enabled: false,
                  decoration: const InputDecoration(labelText: 'Estimated Cost (Auto)'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field('Contract Value (₹)', _contractValueCtrl, keyboardType: TextInputType.number),
          const SizedBox(height: 16),
          _sectionTitle('Timeline'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _datePicker('Start Date', _startDate, () => _pickDate(true))),
              const SizedBox(width: 12),
              Expanded(child: _datePicker('End Date', _endDate, () => _pickDate(false))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Status & Progress'),
          const SizedBox(height: 16),
          DropdownButtonFormField<ProjectStatus>(
            value: _status,
            decoration: const InputDecoration(labelText: 'Project Status'),
            items: ProjectStatus.values.map((s) => DropdownMenuItem(
              value: s,
              child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
            )).toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(height: 20),
          Text('Progress: ${_progress.toInt()}%', style: Theme.of(context).textTheme.labelLarge),
          Slider(
            value: _progress,
            min: 0,
            max: 100,
            divisions: 20,
            activeColor: AppColors.primaryPurple,
            onChanged: (v) => setState(() => _progress = v),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Description & Notes'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionCtrl,
            maxLines: 6,
            decoration: const InputDecoration(
              hintText: 'Enter project description, scope of work...',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: ctrl,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }

  Widget _datePicker(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          date != null ? AppFormatters.formatDate(date) : 'Select date',
          style: TextStyle(color: date == null ? Colors.grey.shade400 : null),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );
  }
}
