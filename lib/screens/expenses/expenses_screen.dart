import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/expense_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../models/expense_model.dart';
import '../../models/project_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  ExpenseCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpenses();
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kExpensesRoute,
      child: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildTopBar(context, provider),
              _buildCategoryFilters(provider),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.expenses.isEmpty
                        ? _buildEmpty(context, provider)
                        : _buildContent(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppDimensions.paddingL, AppDimensions.paddingL, AppDimensions.paddingL, 0),
      child: Row(
        children: [
          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            hasShadow: false,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.money_outlined, color: AppColors.primaryPurple, size: 20),
                const SizedBox(width: 8),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(AppFormatters.formatCurrencyCompact(provider.totalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const Text('Total Expenses', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ]),
              ],
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context, provider),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilters(ExpenseProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL, vertical: 8),
      child: Row(
        children: [
          FilterChip(label: const Text('All', style: TextStyle(fontSize: 12)), selected: _selectedCategory == null, onSelected: (_) { setState(() => _selectedCategory = null); provider.setFilters(); }),
          const SizedBox(width: 6),
          ...ExpenseCategory.values.map((cat) => Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FilterChip(
              label: Text(cat.name[0].toUpperCase() + cat.name.substring(1), style: const TextStyle(fontSize: 12)),
              selected: _selectedCategory == cat,
              onSelected: (_) {
                setState(() => _selectedCategory = _selectedCategory == cat ? null : cat);
                provider.setFilters(category: _selectedCategory);
              },
              selectedColor: AppColors.chartColors[cat.index % AppColors.chartColors.length].withOpacity(0.2),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ExpenseProvider provider) {
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
              child: Row(children: ['Category', 'Project', 'Amount', 'Date', 'Vendor', 'Mode', ''].map((h) => Expanded(child: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))).toList()),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: provider.expenses.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final e = provider.expenses[i];
                  final catColor = AppColors.chartColors[e.category.index % AppColors.chartColors.length];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(children: [
                      Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: catColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text(e.categoryLabel, style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w600)))),
                      Expanded(child: Text(e.projectName.isEmpty ? '-' : e.projectName, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                      Expanded(child: Text(AppFormatters.formatCurrency(e.amount), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                      Expanded(child: Text(AppFormatters.formatDate(e.date), style: const TextStyle(fontSize: 12))),
                      Expanded(child: Text(e.vendorName.isEmpty ? '-' : e.vendorName, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                      Expanded(child: Text(e.paymentMode.toUpperCase(), style: const TextStyle(fontSize: 11, color: Colors.grey))),
                      Expanded(child: IconButton(icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error), onPressed: () async {
                        await provider.deleteExpense(e.id);
                        if (context.mounted) {
                          context.read<DashboardProvider>().loadDashboard();
                        }
                      })),
                    ]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ExpenseProvider provider) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.money_outlined, size: 80, color: Colors.grey.shade400),
      const SizedBox(height: 16),
      const Text('No expenses recorded', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 24),
      ElevatedButton.icon(onPressed: () => _showAddDialog(context, provider), icon: const Icon(Icons.add), label: const Text('Add Expense')),
    ]));
  }

  void _showAddDialog(BuildContext context, ExpenseProvider provider) {
    final projects = context.read<ProjectProvider>().allProjects;
    ExpenseCategory category = ExpenseCategory.material;
    ProjectModel? selectedProject;
    final amtCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          title: const Text('Add Expense'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Project Dropdown
                if (projects.isNotEmpty)
                  DropdownButtonFormField<ProjectModel>(
                    decoration: const InputDecoration(labelText: 'Project *'),
                    value: selectedProject,
                    items: projects.map((p) => DropdownMenuItem(
                      value: p,
                      child: Text(p.title),
                    )).toList(),
                    onChanged: (v) {
                      setS(() {
                        selectedProject = v;
                      });
                    },
                  )
                else
                  const Text('No projects available. Please add a project first.', style: TextStyle(color: Colors.red)),
                const SizedBox(height: 12),
                // Category Dropdown
                DropdownButtonFormField<ExpenseCategory>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category *'),
                  items: ExpenseCategory.values.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name[0].toUpperCase() + c.name.substring(1)),
                  )).toList(),
                  onChanged: (v) => setS(() => category = v!),
                ),
                const SizedBox(height: 12),
                // Description
                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                ),
                const SizedBox(height: 12),
                // Amount
                TextField(
                  controller: amtCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount ₹ *'),
                ),
                const SizedBox(height: 12),
                // Date (Changeable picker, defaults to current date)
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
                      labelText: 'Date',
                      suffixIcon: Icon(Icons.calendar_today_outlined, size: 18),
                    ),
                    child: Text(AppFormatters.formatDate(selectedDate)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                if (selectedProject == null) return;
                final amt = double.tryParse(amtCtrl.text) ?? 0;
                if (amt <= 0) return;
                await provider.addExpense(ExpenseModel(
                  id: const Uuid().v4(),
                  projectId: selectedProject!.id,
                  projectName: selectedProject!.title,
                  category: category,
                  amount: amt,
                  date: selectedDate,
                  description: descCtrl.text.trim(),
                  vendorName: '',
                  paymentMode: 'cash',
                  createdAt: DateTime.now(),
                ));
                if (context.mounted) {
                  context.read<DashboardProvider>().loadDashboard();
                }
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
