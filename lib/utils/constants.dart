class AppConstants {
  // App info
  static const String appName = 'SZ Construction Management';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
  static const String companyName = 'SZ Group';

  // Route names
  static const String kLoginRoute = '/login';
  static const String kRegisterRoute = '/register';
  static const String kDashboardRoute = '/dashboard';
  static const String kProjectsRoute = '/projects';
  static const String kProjectDetailRoute = '/projects/detail';
  static const String kAddEditProjectRoute = '/projects/add-edit';
  static const String kActiveProjectsRoute = '/projects/active';
  static const String kWorkersRoute = '/workers';
  static const String kWorkerDetailRoute = '/workers/detail';
  static const String kAddEditWorkerRoute = '/workers/add-edit';
  static const String kLabourRoute = '/labour';
  static const String kLabourPaymentsRoute = '/payments/labour';
  static const String kClientPaymentsRoute = '/payments/client';
  static const String kExpensesRoute = '/expenses';
  static const String kDailyUpdatesRoute = '/daily-updates';
  static const String kInventoryRoute = '/inventory';
  static const String kReportsRoute = '/reports';
  static const String kSettingsRoute = '/settings';
  static const String kForgotPasswordRoute = '/forgot-password';

  // SharedPreferences keys
  static const String kPrefThemeMode = 'pref_theme_mode';
  static const String kPrefRememberEmail = 'pref_remember_email';
  static const String kPrefLastEmail = 'pref_last_email';
  static const String kPrefSidebarCollapsed = 'pref_sidebar_collapsed';

  // Firebase Remote Config keys
  static const String kRCLatestVersion = 'latest_version';
  static const String kRCForceUpdate = 'force_update';
  static const String kRCDownloadUrl = 'download_url';
  static const String kRCReleaseNotes = 'release_notes';

  // Firestore collections
  static const String kColUsers = 'users';
  static const String kColProjects = 'projects';
  static const String kColWorkers = 'workers';
  static const String kColLabour = 'labour';
  static const String kColPayments = 'payments';
  static const String kColExpenses = 'expenses';
  static const String kColInventory = 'inventory';
  static const String kColDailyUpdates = 'daily_updates';

  // GST rate
  static const double kGstRate = 0.18;
}
