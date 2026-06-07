import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  static UpdateService get instance => _instance;
  
  UpdateService._internal();

  final String _updateUrl = 'https://api.github.com/repos/szgroup/sz-construction-management/releases/latest';
  
  String? _latestVersion;
  String? _downloadUrl;
  String? _releaseNotes;
  bool _hasUpdate = false;

  String? get latestVersion => _latestVersion;
  String? get downloadUrl => _downloadUrl;
  String? get releaseNotes => _releaseNotes;
  bool get hasUpdate => _hasUpdate;

  Future<bool> checkForUpdates() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      final response = await http.get(
        Uri.parse(_updateUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _latestVersion = data['tag_name']?.toString().replaceAll('v', '');
        _downloadUrl = data['assets']?.isNotEmpty == true 
            ? data['assets'][0]['browser_download_url']
            : null;
        _releaseNotes = data['body']?.toString();
        
        _hasUpdate = _compareVersions(currentVersion, _latestVersion ?? currentVersion) < 0;
        
        // Save last check time
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_update_check', DateTime.now().toIso8601String());
        
        return _hasUpdate;
      }
    } catch (e) {
      print('Error checking for updates: $e');
    }
    return false;
  }

  int _compareVersions(String v1, String v2) {
    final v1Parts = v1.split('.').map(int.parse).toList();
    final v2Parts = v2.split('.').map(int.parse).toList();
    
    for (int i = 0; i < 3; i++) {
      final part1 = v1Parts.length > i ? v1Parts[i] : 0;
      final part2 = v2Parts.length > i ? v2Parts[i] : 0;
      
      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }
    return 0;
  }

  Future<bool> downloadUpdate(String url, Function(double) onProgress) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final appDir = await getApplicationDocumentsDirectory();
        final filePath = path.join(appDir.path, 'update_setup.exe');
        final file = File(filePath);
        
        await file.writeAsBytes(response.bodyBytes);
        return true;
      }
    } catch (e) {
      print('Error downloading update: $e');
    }
    return false;
  }

  Future<bool> installUpdate(String filePath) async {
    try {
      final result = await Process.run(filePath, []);
      return result.exitCode == 0;
    } catch (e) {
      print('Error installing update: $e');
    }
    return false;
  }

  Future<DateTime?> getLastUpdateCheck() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCheck = prefs.getString('last_update_check');
    return lastCheck != null ? DateTime.parse(lastCheck) : null;
  }

  Future<bool> shouldCheckForUpdates() async {
    final lastCheck = await getLastUpdateCheck();
    if (lastCheck == null) return true;
    
    // Check for updates every 24 hours
    return DateTime.now().difference(lastCheck) > const Duration(hours: 24);
  }
}
