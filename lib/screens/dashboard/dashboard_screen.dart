import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/project_provider.dart';
import '../../providers/worker_provider.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/update_notification.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';
import '../../utils/formatters.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final dp = context.read<DashboardProvider>();
      final pp = context.read<ProjectProvider>();
      final wp = context.read<WorkerProvider>();
      dp.loadDashboard();
      pp.loadProjects();
      wp.loadWorkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kDashboardRoute,
      child: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UpdateNotification(),
                  const SizedBox(height: 16),
                  // Welcome row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good ${_greeting()}!', style: Theme.of(context).textTheme.headlineMedium),
                          const SizedBox(height: 4),
                          Text('Here\'s what\'s happening with your projects today.',
                              style: Theme.of(context).textTheme.bodyMedium),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: provider.refresh,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Refresh'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                          foregroundColor: AppColors.primaryPurple,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Stat cards
                  _buildStatCards(provider),
                  const SizedBox(height: 24),
                  // Charts row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildLineChart(provider)),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: _buildRecentActivity(provider)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Bottom row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildProjectsOverview()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildQuickActions()),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCards(DashboardProvider provider) {
    final cards = [
      (
        title: 'Total Projects',
        value: '${provider.totalProjects}',
        icon: Icons.folder_outlined,
        gradient: AppColors.cardGradient1,
        subtitle: '${provider.activeProjects} active',
      ),
      (
        title: 'Active Projects',
        value: '${provider.activeProjects}',
        icon: Icons.work_outline,
        gradient: AppColors.cardGradient2,
        subtitle: 'Currently running',
      ),
      (
        title: 'Completed',
        value: '${provider.completedProjects}',
        icon: Icons.check_circle_outline,
        gradient: AppColors.cardGradient3,
        subtitle: 'This year',
      ),
      (
        title: 'Total Workers',
        value: '${provider.totalWorkers}',
        icon: Icons.people_outline,
        gradient: AppColors.cardGradient4,
        subtitle: 'Active staff',
      ),
      (
        title: 'Contract Value',
        value: AppFormatters.formatCurrencyCompact(provider.contractValue),
        icon: Icons.currency_rupee,
        gradient: AppColors.cardGradient5,
        subtitle: 'Total portfolio',
      ),
      (
        title: 'Monthly Expenses',
        value: AppFormatters.formatCurrencyCompact(provider.monthlyExpensesTotal),
        icon: Icons.money_outlined,
        gradient: AppColors.cardGradient6,
        subtitle: 'This month',
      ),
      (
        title: 'Pending Payments',
        value: AppFormatters.formatCurrencyCompact(provider.pendingPayments),
        icon: Icons.payment_outlined,
        gradient: AppColors.cardGradient1,
        subtitle: 'Outstanding dues',
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: cards.asMap().entries.map((entry) {
        final i = entry.key;
        final card = entry.value;
        return SizedBox(
          width: 190,
          height: AppDimensions.statCardHeight,
          child: StatCard(
            title: card.title,
            value: card.value,
            subtitle: card.subtitle,
            icon: card.icon,
            gradient: card.gradient,
            animationDelay: Duration(milliseconds: i * 80),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLineChart(DashboardProvider provider) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('6-Month Financial Trend', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              Row(
                children: [
                  _legendDot(AppColors.primaryPurple, 'Expenses'),
                  const SizedBox(width: 12),
                  _legendDot(AppColors.primaryBlue, 'Revenue'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 220,
            child: provider.monthlyExpenses.isEmpty
                ? const Center(child: Text('No data available'))
                : LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawHorizontalLine: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: AppColors.glassBorder,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < provider.monthLabels.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    provider.monthLabels[idx],
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        _lineData(provider.monthlyExpenses, AppColors.primaryPurple),
                        _lineData(provider.monthlyRevenue, AppColors.primaryBlue),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  LineChartBarData _lineData(List<double> values, Color color) {
    return LineChartBarData(
      spots: values.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
      isCurved: true,
      color: color,
      barWidth: 2.5,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.08),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentActivity(DashboardProvider provider) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          if (provider.recentActivities.isEmpty)
            const Text('No recent activity', style: TextStyle(color: Colors.grey))
          else
            ...provider.recentActivities.take(8).map((activity) {
              final isExpense = activity['type'] == 'expense';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (isExpense ? AppColors.warning : AppColors.success).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isExpense ? Icons.money_outlined : Icons.payment_outlined,
                        size: 18,
                        color: isExpense ? AppColors.warning : AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(activity['title'] as String? ?? '', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(activity['subtitle'] as String? ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(
                      AppFormatters.formatCurrencyCompact((activity['amount'] as num?)?.toDouble() ?? 0),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isExpense ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildProjectsOverview() {
    return Consumer<ProjectProvider>(
      builder: (context, provider, _) {
        final active = provider.activeProjects;
        return GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Projects', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, AppConstants.kActiveProjectsRoute),
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (active.isEmpty)
                const Text('No active projects', style: TextStyle(color: Colors.grey))
              else
                ...active.take(4).map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(child: Text(p.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
                          Text('${p.progress.toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: p.progress / 100,
                          backgroundColor: AppColors.primaryPurple.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation(AppColors.primaryPurple),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      (icon: Icons.add_box_outlined, label: 'New Project', route: AppConstants.kAddEditProjectRoute, color: AppColors.primaryPurple),
      (icon: Icons.person_add_outlined, label: 'Add Worker', route: AppConstants.kAddEditWorkerRoute, color: AppColors.primaryBlue),
      (icon: Icons.engineering_outlined, label: 'Labour Entry', route: AppConstants.kLabourRoute, color: AppColors.success),
      (icon: Icons.money_outlined, label: 'Add Expense', route: AppConstants.kExpensesRoute, color: AppColors.warning),
      (icon: Icons.bar_chart_outlined, label: 'Reports', route: AppConstants.kReportsRoute, color: AppColors.info),
      (icon: Icons.settings_outlined, label: 'Settings', route: AppConstants.kSettingsRoute, color: Colors.grey),
    ];

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Quick Actions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: actions.map((a) => _quickActionButton(a.icon, a.label, a.route, a.color)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _quickActionButton(IconData icon, String label, String route, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await Navigator.pushNamed(context, route);
          if (mounted) {
            context.read<DashboardProvider>().loadDashboard();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }
}
