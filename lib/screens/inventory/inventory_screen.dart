import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/project_provider.dart';
import '../../models/inventory_model.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadInventory();
      context.read<ProjectProvider>().loadProjects();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kInventoryRoute,
      child: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              _buildTopBar(context, provider),
              if (provider.lowStockItems.isNotEmpty)
                _buildLowStockBanner(provider),
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : provider.items.isEmpty
                        ? _buildEmpty(context, provider)
                        : _buildTable(context, provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, InventoryProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingL),
      child: Row(
        children: [
          _chip(Icons.inventory_2_outlined, 'Total Items', '${provider.items.length}', AppColors.primaryPurple),
          const SizedBox(width: 12),
          _chip(Icons.warning_amber_outlined, 'Low Stock', '${provider.lowStockItems.length}', AppColors.warning),
          const SizedBox(width: 12),
          _chip(Icons.currency_rupee, 'Total Value', AppFormatters.formatCurrencyCompact(provider.totalInventoryValue), AppColors.success),
          const SizedBox(width: 12),
          SizedBox(
            width: 240,
            child: TextField(
              onChanged: provider.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search inventory...',
                prefixIcon: const Icon(Icons.search_outlined, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusM)),
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context, provider),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add Item'),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.8))),
        ]),
      ]),
    );
  }

  Widget _buildLowStockBanner(InventoryProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingL),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_outlined, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Text('${provider.lowStockItems.length} items are below minimum stock level: ${provider.lowStockItems.take(3).map((i) => i.materialName).join(', ')}${provider.lowStockItems.length > 3 ? '...' : ''}',
              style: TextStyle(fontSize: 13, color: AppColors.warning, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTable(BuildContext context, InventoryProvider provider) {
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
              child: Row(children: ['Material', 'Unit', 'Qty', 'Available', 'Min Stock', 'Cost/Unit', 'Total Value', 'Status', ''].map((h) => Expanded(child: Text(h, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))).toList()),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.separated(
                itemCount: provider.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final item = provider.items[i];
                  final statusColor = item.isOutOfStock ? AppColors.error : item.isLowStock ? AppColors.warning : AppColors.success;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(children: [
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(item.materialName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        if (item.supplier.isNotEmpty) Text(item.supplier, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ])),
                      Expanded(child: Text(item.unit, style: const TextStyle(fontSize: 12, color: Colors.grey))),
                      Expanded(child: Text('${item.quantity}', style: const TextStyle(fontSize: 12))),
                      Expanded(child: Text('${item.availableQuantity}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: item.isLowStock ? AppColors.warning : null))),
                      Expanded(child: Text('${item.minStock}', style: const TextStyle(fontSize: 12, color: Colors.grey))),
                      Expanded(child: Text(AppFormatters.formatCurrencyCompact(item.costPerUnit), style: const TextStyle(fontSize: 12))),
                      Expanded(child: Text(AppFormatters.formatCurrencyCompact(item.totalCost), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
                      Expanded(child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)), child: Text(item.stockStatus, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)))),
                      Expanded(child: IconButton(icon: Icon(Icons.delete_outline, size: 16, color: AppColors.error), onPressed: () => provider.deleteItem(item.id))),
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

  Widget _buildEmpty(BuildContext context, InventoryProvider provider) {
    return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey.shade400),
      const SizedBox(height: 16),
      const Text('No inventory items', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
      const SizedBox(height: 24),
      ElevatedButton.icon(onPressed: () => _showAddDialog(context, provider), icon: const Icon(Icons.add), label: const Text('Add Item')),
    ]));
  }

  void _showAddDialog(BuildContext context, InventoryProvider provider) {
    final nameCtrl = TextEditingController();
    final unitCtrl = TextEditingController(text: 'Bags');
    final qtyCtrl = TextEditingController();
    final minCtrl = TextEditingController(text: '5');
    final supplierCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Inventory Item'),
        content: SizedBox(
          width: 480,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Material Name *')),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: unitCtrl, decoration: const InputDecoration(labelText: 'Unit (Bags, KG, Liters...)'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity *'))),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: TextField(controller: minCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Min Stock Level'))),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: costCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cost Per Unit ₹'))),
            ]),
            const SizedBox(height: 12),
            TextField(controller: supplierCtrl, decoration: const InputDecoration(labelText: 'Supplier Name')),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isEmpty) return;
              await provider.addItem(InventoryModel(
                id: const Uuid().v4(),
                materialName: nameCtrl.text.trim(),
                unit: unitCtrl.text.trim(),
                quantity: double.tryParse(qtyCtrl.text) ?? 0,
                minStock: double.tryParse(minCtrl.text) ?? 5,
                supplier: supplierCtrl.text.trim(),
                costPerUnit: double.tryParse(costCtrl.text) ?? 0,
                createdAt: DateTime.now(),
              ));
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
