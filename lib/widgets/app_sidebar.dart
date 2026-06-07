import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../utils/constants.dart';

class AppSidebar extends StatefulWidget {
  final String currentRoute;
  final void Function(String route) onNavigate;
  final bool isCollapsed;
  final VoidCallback onToggle;

  const AppSidebar({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
    required this.isCollapsed,
    required this.onToggle,
  });

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _widthAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _widthAnim = Tween<double>(
      begin: AppDimensions.sidebarWidth,
      end: AppDimensions.sidebarCollapsedWidth,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic));
    if (widget.isCollapsed) _controller.forward();
  }

  @override
  void didUpdateWidget(AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      widget.isCollapsed ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _widthAnim,
      builder: (context, _) {
        final width = _widthAnim.value;
        final collapsed = width <= AppDimensions.sidebarCollapsedWidth + 10;
        return Container(
          width: width,
          color: isDark ? AppColors.darkCard : const Color(0xFF1E1E3A),
          child: Column(
            children: [
              // Logo area
              _buildLogo(width, collapsed),
              // Nav items
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      ..._navItems.map((item) => _buildNavItem(item, collapsed, width)),
                    ],
                  ),
                ),
              ),
              // Bottom: toggle + version
              _buildBottom(collapsed),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogo(double width, bool collapsed) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.glassBorder)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (!collapsed) ...[
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('SZ Construction', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Inter')),
                  Text('Management', style: TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Inter')),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavItem(_NavItem item, bool collapsed, double width) {
    final isActive = widget.currentRoute == item.route ||
        (item.children?.any((c) => c.route == widget.currentRoute) ?? false);
    final isParentWithChildren = item.children != null && item.children!.isNotEmpty;

    if (isParentWithChildren && !collapsed) {
      return _NavGroup(
        key: ValueKey(item.route),
        item: item,
        currentRoute: widget.currentRoute,
        onNavigate: widget.onNavigate,
      );
    }

    return _NavTile(
      key: ValueKey(item.route),
      item: item,
      isActive: isActive,
      collapsed: collapsed,
      onTap: () => widget.onNavigate(item.route),
    );
  }

  Widget _buildBottom(bool collapsed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: AppColors.glassBorder))),
      child: Column(
        children: [
          if (!collapsed)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'v${AppConstants.appVersion}',
                style: const TextStyle(color: Colors.white38, fontSize: 10, fontFamily: 'Inter'),
              ),
            ),
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: AppColors.glassFill, borderRadius: BorderRadius.circular(8)),
              child: Icon(
                collapsed ? Icons.chevron_right : Icons.chevron_left,
                color: Colors.white54,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_NavItem> get _navItems => [
    _NavItem('Dashboard', Icons.dashboard_outlined, AppConstants.kDashboardRoute),
    _NavItem('Projects', Icons.folder_outlined, AppConstants.kProjectsRoute, children: [
      _NavItem('All Projects', Icons.list_outlined, AppConstants.kProjectsRoute),
      _NavItem('Active', Icons.work_outline, AppConstants.kActiveProjectsRoute),
    ]),
    _NavItem('Workers', Icons.people_outline, AppConstants.kWorkersRoute, children: [
      _NavItem('All Workers', Icons.groups_outlined, AppConstants.kWorkersRoute),
      _NavItem('Add Worker', Icons.person_add_outlined, AppConstants.kAddEditWorkerRoute),
    ]),
    _NavItem('Labour', Icons.engineering_outlined, AppConstants.kLabourRoute),
    _NavItem('Payments', Icons.payment_outlined, AppConstants.kLabourPaymentsRoute, children: [
      _NavItem('Labour Payments', Icons.account_balance_wallet_outlined, AppConstants.kLabourPaymentsRoute),
      _NavItem('Client Payments', Icons.receipt_long_outlined, AppConstants.kClientPaymentsRoute),
    ]),
    _NavItem('Expenses', Icons.money_outlined, AppConstants.kExpensesRoute),
    _NavItem('Daily Updates', Icons.note_add_outlined, AppConstants.kDailyUpdatesRoute),
    _NavItem('Reports', Icons.bar_chart_outlined, AppConstants.kReportsRoute),
    _NavItem('Settings', Icons.settings_outlined, AppConstants.kSettingsRoute),
  ];
}

class _NavItem {
  final String label;
  final IconData icon;
  final String route;
  final List<_NavItem>? children;
  const _NavItem(this.label, this.icon, this.route, {this.children});
}

class _NavTile extends StatefulWidget {
  final _NavItem item;
  final bool isActive;
  final bool collapsed;
  final VoidCallback onTap;
  const _NavTile({super.key, required this.item, required this.isActive, required this.collapsed, required this.onTap});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          padding: EdgeInsets.symmetric(
            horizontal: widget.collapsed ? 0 : 12,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.primaryPurple.withOpacity(0.2)
                : _hovered
                    ? Colors.white.withOpacity(0.06)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: widget.isActive
                ? Border.all(color: AppColors.primaryPurple.withOpacity(0.4))
                : null,
          ),
          child: Tooltip(
            message: widget.collapsed ? widget.item.label : '',
            child: Row(
              mainAxisAlignment: widget.collapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(
                  widget.item.icon,
                  size: 20,
                  color: widget.isActive ? AppColors.primaryPurple : Colors.white60,
                ),
                if (!widget.collapsed) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.item.label,
                      style: TextStyle(
                        color: widget.isActive ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavGroup extends StatefulWidget {
  final _NavItem item;
  final String currentRoute;
  final void Function(String) onNavigate;
  const _NavGroup({super.key, required this.item, required this.currentRoute, required this.onNavigate});

  @override
  State<_NavGroup> createState() => _NavGroupState();
}

class _NavGroupState extends State<_NavGroup> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _expanded = widget.item.children?.any((c) => c.route == widget.currentRoute) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isGroupActive = widget.item.children?.any((c) => c.route == widget.currentRoute) ?? false;
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isGroupActive ? AppColors.primaryPurple.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(widget.item.icon, size: 20, color: isGroupActive ? AppColors.primaryPurple : Colors.white60),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.item.label,
                    style: TextStyle(
                      color: isGroupActive ? Colors.white : Colors.white70,
                      fontSize: 13,
                      fontWeight: isGroupActive ? FontWeight.w600 : FontWeight.w400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
                Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.white38, size: 16),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              children: widget.item.children!.map((child) => _NavTile(
                key: ValueKey(child.route),
                item: child,
                isActive: widget.currentRoute == child.route,
                collapsed: false,
                onTap: () => widget.onNavigate(child.route),
              )).toList(),
            ),
          ),
      ],
    );
  }
}
