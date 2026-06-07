import 'package:flutter/material.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/projects/projects_screen.dart';
import 'screens/projects/add_edit_project_screen.dart';
import 'screens/projects/project_detail_screen.dart';
import 'screens/active_projects/active_projects_screen.dart';
import 'screens/workers/workers_screen.dart';
import 'screens/workers/add_edit_worker_screen.dart';
import 'screens/workers/worker_detail_screen.dart';
import 'screens/labour/labour_screen.dart';
import 'screens/payments/labour_payments_screen.dart';
import 'screens/payments/client_payments_screen.dart';
import 'screens/expenses/expenses_screen.dart';
import 'screens/daily_updates/daily_updates_screen.dart';
import 'screens/reports/reports_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'utils/constants.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings, AuthProvider auth) {
    // Auth guard
    if (!auth.isLoggedIn && 
        settings.name != AppConstants.kLoginRoute && 
        settings.name != AppConstants.kRegisterRoute &&
        settings.name != AppConstants.kForgotPasswordRoute) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    }

    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case AppConstants.kLoginRoute:
        return _pageRoute(const LoginScreen(), settings);
      case AppConstants.kRegisterRoute:
        return _pageRoute(const RegisterScreen(), settings);
      case AppConstants.kDashboardRoute:
        return _pageRoute(const DashboardScreen(), settings);
      case AppConstants.kProjectsRoute:
        return _pageRoute(const ProjectsScreen(), settings);
      case AppConstants.kProjectDetailRoute:
        return _pageRoute(ProjectDetailScreen(projectId: args?['id'] ?? ''), settings);
      case AppConstants.kAddEditProjectRoute:
        return _pageRoute(AddEditProjectScreen(projectId: args?['id']), settings);
      case AppConstants.kActiveProjectsRoute:
        return _pageRoute(const ActiveProjectsScreen(), settings);
      case AppConstants.kWorkersRoute:
        return _pageRoute(const WorkersScreen(), settings);
      case AppConstants.kWorkerDetailRoute:
        return _pageRoute(WorkerDetailScreen(workerId: args?['id'] ?? ''), settings);
      case AppConstants.kAddEditWorkerRoute:
        return _pageRoute(AddEditWorkerScreen(workerId: args?['id']), settings);
      case AppConstants.kLabourRoute:
        return _pageRoute(const LabourScreen(), settings);
      case AppConstants.kLabourPaymentsRoute:
        return _pageRoute(const LabourPaymentsScreen(), settings);
      case AppConstants.kClientPaymentsRoute:
        return _pageRoute(const ClientPaymentsScreen(), settings);
      case AppConstants.kExpensesRoute:
        return _pageRoute(const ExpensesScreen(), settings);
      case AppConstants.kDailyUpdatesRoute:
        return _pageRoute(const DailyUpdatesScreen(), settings);
      case AppConstants.kReportsRoute:
        return _pageRoute(const ReportsScreen(), settings);
      case AppConstants.kSettingsRoute:
        return _pageRoute(const SettingsScreen(), settings);
      case AppConstants.kForgotPasswordRoute:
        return _pageRoute(const ForgotPasswordScreen(), settings);
      default:
        return MaterialPageRoute(builder: (_) => const DashboardScreen());
    }
  }

  static PageRouteBuilder _pageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
