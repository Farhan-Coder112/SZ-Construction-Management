import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/project_model.dart';

class ProjectProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<ProjectModel> _allProjects = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  ProjectStatus? _statusFilter;

  /// Callback to notify other providers (e.g. DashboardProvider) when data changes
  VoidCallback? onDataChanged;

  List<ProjectModel> get allProjects => _allProjects;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProjectStatus? get statusFilter => _statusFilter;

  List<ProjectModel> get projects {
    var filtered = _allProjects.where((p) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        if (!p.title.toLowerCase().contains(q) &&
            !p.clientName.toLowerCase().contains(q) &&
            !p.siteLocation.toLowerCase().contains(q)) return false;
      }
      if (_statusFilter != null && p.status != _statusFilter) return false;
      return true;
    }).toList();
    return filtered;
  }

  List<ProjectModel> get activeProjects => _allProjects.where((p) => p.status == ProjectStatus.active).toList();
  List<ProjectModel> get completedProjects => _allProjects.where((p) => p.status == ProjectStatus.completed).toList();

  Future<void> loadProjects() async {
    _isLoading = true; _error = null; notifyListeners();
    try {
      final rows = await _db.getAll('projects', where: 'pending_delete = 0', orderBy: 'created_at DESC');
      _allProjects = rows.map((r) => ProjectModel.fromMap(r)).toList();
    } catch (e) { _error = e.toString(); }
    finally { _isLoading = false; notifyListeners(); }
  }

  Future<void> addProject(ProjectModel project) async {
    await _db.insert('projects', project.toMap());
    _allProjects.insert(0, project);
    notifyListeners();
    onDataChanged?.call();
  }

  Future<void> updateProject(ProjectModel project) async {
    await _db.update('projects', project.toMap(), project.id);
    final idx = _allProjects.indexWhere((p) => p.id == project.id);
    if (idx >= 0) { _allProjects[idx] = project; notifyListeners(); }
    onDataChanged?.call();
  }

  Future<void> deleteProject(String id) async {
    await _db.update('projects', {'pending_delete': 1}, id);
    _allProjects.removeWhere((p) => p.id == id);
    notifyListeners();
    onDataChanged?.call();
  }

  ProjectModel? getById(String id) => _allProjects.firstWhere((p) => p.id == id, orElse: () => _allProjects.first);

  void setSearchQuery(String q) { _searchQuery = q; notifyListeners(); }
  void setStatusFilter(ProjectStatus? status) { _statusFilter = status; notifyListeners(); }
  void clearFilters() { _searchQuery = ''; _statusFilter = null; notifyListeners(); }
}
