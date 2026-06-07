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
import '../../utils/validators.dart';
import '../../utils/formatters.dart';

class AddEditWorkerScreen extends StatefulWidget {
  final String? workerId;
  const AddEditWorkerScreen({super.key, this.workerId});
  @override
  State<AddEditWorkerScreen> createState() => _AddEditWorkerScreenState();
}

class _AddEditWorkerScreenState extends State<AddEditWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _altPhoneCtrl = TextEditingController();
  final _wageCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  WorkerCategory _category = WorkerCategory.helper;
  WorkerStatus _status = WorkerStatus.active;
  String _idProofType = 'Aadhar';
  DateTime? _joinDate;
  bool _isSaving = false;
  bool get _isEditing => widget.workerId != null;

  final List<String> _idProofTypes = ['Aadhar', 'PAN', 'Voter ID', 'Passport', 'Driving License'];

  @override
  void initState() {
    super.initState();
    if (_isEditing) WidgetsBinding.instance.addPostFrameCallback((_) => _loadWorker());
  }

  void _loadWorker() {
    final w = context.read<WorkerProvider>().getById(widget.workerId!);
    if (w != null) {
      _nameCtrl.text = w.name; _phoneCtrl.text = w.phone;
      _altPhoneCtrl.text = w.alternatePhone; _wageCtrl.text = w.dailyWage.toString();
      _addressCtrl.text = w.address;
      setState(() { _category = w.category; _status = w.status; _idProofType = w.idProofType; _joinDate = w.joinDate; });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _altPhoneCtrl.dispose();
    _wageCtrl.dispose(); _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final provider = context.read<WorkerProvider>();

    final worker = WorkerModel(
      id: _isEditing ? widget.workerId! : const Uuid().v4(),
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      alternatePhone: _altPhoneCtrl.text.trim(),
      category: _category,
      dailyWage: double.tryParse(_wageCtrl.text) ?? 0,
      status: _status,
      idProofType: _idProofType,
      joinDate: _joinDate,
      address: _addressCtrl.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      _isEditing ? await provider.updateWorker(worker) : await provider.addWorker(worker);
      if (mounted) {
        context.read<DashboardProvider>().loadDashboard();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Worker ${_isEditing ? 'updated' : 'added'}!'), backgroundColor: AppColors.success),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kWorkersRoute,
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
                  Text(_isEditing ? 'Edit Worker' : 'Add New Worker', style: Theme.of(context).textTheme.headlineMedium),
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
                          const Text('Personal Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          TextFormField(controller: _nameCtrl, validator: (v) => AppValidators.validateRequired(v, 'Name'), decoration: const InputDecoration(labelText: 'Full Name *')),
                          const SizedBox(height: 12),
                          TextFormField(controller: _phoneCtrl, validator: AppValidators.validatePhone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number *')),
                          const SizedBox(height: 12),
                          TextFormField(controller: _altPhoneCtrl, validator: AppValidators.validatePhoneOptional, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Alternate Phone')),
                          const SizedBox(height: 12),
                          TextFormField(controller: _addressCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Address', alignLabelWithHint: true)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Employment Details', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<WorkerCategory>(
                            value: _category,
                            decoration: const InputDecoration(labelText: 'Category'),
                            items: WorkerCategory.values.map((c) => DropdownMenuItem(
                              value: c, child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                            )).toList(),
                            onChanged: (v) => setState(() => _category = v!),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(controller: _wageCtrl, validator: AppValidators.validateAmount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Daily Wage (₹) *', prefixIcon: Icon(Icons.currency_rupee, size: 18))),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<WorkerStatus>(
                            value: _status,
                            decoration: const InputDecoration(labelText: 'Status'),
                            items: WorkerStatus.values.map((s) => DropdownMenuItem(
                              value: s, child: Text(s.name[0].toUpperCase() + s.name.substring(1)),
                            )).toList(),
                            onChanged: (v) => setState(() => _status = v!),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _idProofType,
                            decoration: const InputDecoration(labelText: 'ID Proof Type'),
                            items: _idProofTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setState(() => _idProofType = v!),
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: () async {
                              final d = await showDatePicker(context: context, initialDate: _joinDate ?? DateTime.now(), firstDate: DateTime(2010), lastDate: DateTime.now());
                              if (d != null) setState(() => _joinDate = d);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Join Date', suffixIcon: Icon(Icons.calendar_today_outlined, size: 18)),
                              child: Text(_joinDate != null ? AppFormatters.formatDate(_joinDate!) : 'Select date', style: TextStyle(color: _joinDate == null ? Colors.grey.shade400 : null)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : Text(_isEditing ? 'Update Worker' : 'Save Worker'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
