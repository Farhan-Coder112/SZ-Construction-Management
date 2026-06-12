import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/export_service.dart';
import '../../services/update_service.dart';
import '../../widgets/app_shell.dart';
import '../../widgets/glass_card.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_dimensions.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      currentRoute: AppConstants.kSettingsRoute,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildAppSettingsCard(context),
                      const SizedBox(height: 16),
                      _buildAboutCard(context),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      _buildProfileCard(context),
                      const SizedBox(height: 16),
                      _buildDataCard(context),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingsCard(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, theme, _) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'App Settings', Icons.tune_outlined),
            const SizedBox(height: 16),
            _settingRow(
              context,
              'Dark Mode',
              'Switch between dark and light theme',
              Switch(
                value: theme.isDark,
                onChanged: (_) => theme.toggleTheme(),
                activeColor: AppColors.primaryPurple,
              ),
            ),
            const Divider(height: 24),
            _settingRow(
              context,
              'Auto-collapse Sidebar',
              'Collapse sidebar when navigating',
              Switch(value: false, onChanged: (_) {}, activeColor: AppColors.primaryPurple),
            ),
            const Divider(height: 24),
            _settingRow(
              context,
              'Language',
              'App display language',
              DropdownButton<String>(
                value: 'English',
                underline: const SizedBox.shrink(),
                items: const [DropdownMenuItem(value: 'English', child: Text('English'))],
                onChanged: (_) {},
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'About & Updates', Icons.info_outline),
          const SizedBox(height: 16),
          _infoRow('App Name', AppConstants.appName),
          _infoRow('Version', AppConstants.appVersion),
          _infoRow('Build', 'Release ${AppConstants.buildNumber}'),
          _infoRow('Platform', 'Windows Desktop'),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final updateService = UpdateService.instance;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Checking for updates...'), duration: Duration(seconds: 2)),
                );
                
                final hasUpdate = await updateService.checkForUpdates();
                
                if (context.mounted) {
                  if (hasUpdate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Update available: v${updateService.latestVersion}'),
                        backgroundColor: AppColors.primaryPurple,
                        duration: const Duration(seconds: 4),
                      ),
                    );
                    // Navigate to dashboard to show update notification
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppConstants.kDashboardRoute,
                      (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('You are on the latest version!'), backgroundColor: Colors.green),
                    );
                  }
                }
              },
              icon: const Icon(Icons.system_update_outlined, size: 18),
              label: const Text('Check for Updates'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '© 2024 SZ Construction. All rights reserved.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) => GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(context, 'User Profile', Icons.person_outline),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
                  child: Center(child: Text(auth.currentUser?.initials ?? 'U', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(auth.currentUser?.name ?? 'User', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      Text(auth.currentUser?.email ?? '', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                        child: Text(auth.currentUser?.roleLabel ?? 'Employee', style: TextStyle(fontSize: 11, color: AppColors.primaryPurple, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await auth.signOut();
                  if (context.mounted) Navigator.pushReplacementNamed(context, AppConstants.kLoginRoute);
                },
                icon: Icon(Icons.logout, size: 16, color: AppColors.error),
                label: Text('Sign Out', style: TextStyle(color: AppColors.error)),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.error.withOpacity(0.1), elevation: 0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataCard(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(context, 'Data & Backup', Icons.backup_outlined),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final exportService = ExportService();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting data to CSV...'), duration: Duration(seconds: 2)),
                );
                final filePath = await exportService.exportToCSV('projects');
                if (filePath != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to: $filePath'), backgroundColor: Colors.green),
                  );
                }
              },
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export Projects (CSV)'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final exportService = ExportService();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting data to CSV...'), duration: Duration(seconds: 2)),
                );
                final filePath = await exportService.exportToCSV('workers');
                if (filePath != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to: $filePath'), backgroundColor: Colors.green),
                  );
                }
              },
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export Workers (CSV)'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final exportService = ExportService();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Exporting data to CSV...'), duration: Duration(seconds: 2)),
                );
                final filePath = await exportService.exportToCSV('expenses');
                if (filePath != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Exported to: $filePath'), backgroundColor: Colors.green),
                  );
                }
              },
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export Expenses (CSV)'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please select a backup file to restore from.')),
                );
              },
              icon: const Icon(Icons.upload_outlined, size: 18),
              label: const Text('Restore from Backup'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Syncing with Firebase...'), backgroundColor: AppColors.primaryPurple),
                );
              },
              icon: const Icon(Icons.sync_outlined, size: 18),
              label: const Text('Force Sync to Firebase'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Firebase Status: Connected',
            style: TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text('Last synced: Just now', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primaryPurple),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _settingRow(BuildContext context, String title, String subtitle, Widget trailing) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
        ),
        trailing,
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}
