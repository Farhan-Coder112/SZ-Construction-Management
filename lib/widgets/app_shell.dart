import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../themes/app_colors.dart';
import '../themes/app_dimensions.dart';
import '../utils/constants.dart';
import 'app_sidebar.dart';

/// Shared layout shell for all authenticated screens
class AppShell extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const AppShell({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WindowListener {
  bool _sidebarCollapsed = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  void _navigate(String route) {
    if (widget.currentRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Custom title bar (DragToMoveArea)
          _buildTitleBar(isDark),
          // Main content area
          Expanded(
            child: Row(
              children: [
                AppSidebar(
                  currentRoute: widget.currentRoute,
                  onNavigate: _navigate,
                  isCollapsed: _sidebarCollapsed,
                  onToggle: () => setState(() => _sidebarCollapsed = !_sidebarCollapsed),
                ),
                Expanded(
                  child: Column(
                    children: [
                      _buildHeader(isDark),
                      Expanded(
                        child: widget.child,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBar(bool isDark) {
    return GestureDetector(
      onPanStart: (_) => windowManager.startDragging(),
      child: Container(
        height: 36,
        color: isDark ? const Color(0xFF0A0A14) : AppColors.primaryPurple,
        child: Row(
          children: [
            const SizedBox(width: 12),
            const Icon(Icons.construction, color: Colors.white, size: 14),
            const SizedBox(width: 8),
            const Text(
              'SZ Construction Management',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            _TitleBarButton(
              icon: Icons.remove,
              onPressed: () => windowManager.minimize(),
              tooltip: 'Minimize',
            ),
            _TitleBarButton(
              icon: Icons.crop_square,
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.restore();
                } else {
                  await windowManager.maximize();
                }
              },
              tooltip: 'Maximize',
            ),
            _TitleBarButton(
              icon: Icons.close,
              onPressed: () => windowManager.close(),
              tooltip: 'Close',
              isClose: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      height: AppDimensions.headerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.glassBorder : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          // Page title / breadcrumb
          Expanded(
            child: Text(
              _getPageTitle(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Search
          SizedBox(
            width: 260,
            height: 38,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search_outlined, size: 18),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ),
          const SizedBox(width: 16),
          // Theme toggle
          Consumer<ThemeProvider>(
            builder: (context, theme, _) => IconButton(
              icon: Icon(
                theme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                size: 22,
              ),
              tooltip: theme.isDark ? 'Light mode' : 'Dark mode',
              onPressed: theme.toggleTheme,
            ),
          ),
          // Notifications
          Stack(
            alignment: Alignment.topRight,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, size: 22),
                tooltip: 'Notifications',
                onPressed: () {},
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppColors.darkCard : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Profile
          Consumer<AuthProvider>(
            builder: (context, auth, _) => PopupMenuButton(
              offset: const Offset(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              itemBuilder: (_) => <PopupMenuEntry<dynamic>>[
                PopupMenuItem(
                  child: ListTile(
                    leading: const Icon(Icons.person_outline),
                    title: Text(auth.currentUser?.name ?? 'User'),
                    subtitle: Text(auth.currentUser?.email ?? ''),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  onTap: () => Navigator.pushNamed(context, AppConstants.kSettingsRoute),
                  child: const ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Settings'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                PopupMenuItem(
                  onTap: () async {
                    await auth.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, AppConstants.kLoginRoute);
                    }
                  },
                  child: ListTile(
                    leading: Icon(Icons.logout, color: AppColors.error),
                    title: Text('Sign Out', style: TextStyle(color: AppColors.error)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _getUserInitial(auth.currentUser?.name),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUserInitial(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return 'U';
    return trimmed[0].toUpperCase();
  }

  String _getPageTitle() {
    switch (widget.currentRoute) {
      case AppConstants.kDashboardRoute: return 'Dashboard';
      case AppConstants.kProjectsRoute: return 'Projects';
      case AppConstants.kActiveProjectsRoute: return 'Active Projects';
      case AppConstants.kWorkersRoute: return 'Workers';
      case AppConstants.kLabourRoute: return 'Labour Management';
      case AppConstants.kLabourPaymentsRoute: return 'Labour Payments';
      case AppConstants.kClientPaymentsRoute: return 'Client Payments';
      case AppConstants.kExpensesRoute: return 'Daily Expenses';
      case AppConstants.kDailyUpdatesRoute: return 'Daily Updates';
      case AppConstants.kInventoryRoute: return 'Inventory';
      case AppConstants.kReportsRoute: return 'Reports';
      case AppConstants.kSettingsRoute: return 'Settings';
      default: return 'SZ Construction';
    }
  }
}

class _TitleBarButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final bool isClose;

  const _TitleBarButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.isClose = false,
  });

  @override
  State<_TitleBarButton> createState() => _TitleBarButtonState();
}

class _TitleBarButtonState extends State<_TitleBarButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 46,
            height: 36,
            color: _hovered
                ? (widget.isClose ? AppColors.error : Colors.white.withOpacity(0.15))
                : Colors.transparent,
            child: Icon(widget.icon, color: Colors.white, size: 14),
          ),
        ),
      ),
    );
  }
}
