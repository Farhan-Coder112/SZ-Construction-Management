enum WeatherType { sunny, cloudy, rainy, stormy }

class DailyUpdateModel {
  final String id;
  final String projectId;
  final String projectName;
  final DateTime date;
  final String description;
  final String workDone;
  final int workersPresent;
  final String materialsUsed;
  final String issues;
  final List<String> images;
  final String engineerId;
  final String engineerName;
  final WeatherType weather;
  final double progressPercentage;
  final DateTime createdAt;

  DailyUpdateModel({
    required this.id,
    required this.projectId,
    this.projectName = '',
    required this.date,
    this.description = '',
    this.workDone = '',
    this.workersPresent = 0,
    this.materialsUsed = '',
    this.issues = '',
    this.images = const [],
    this.engineerId = '',
    this.engineerName = '',
    this.weather = WeatherType.sunny,
    this.progressPercentage = 0,
    required this.createdAt,
  });

  String get weatherLabel {
    switch (weather) {
      case WeatherType.sunny: return 'Sunny';
      case WeatherType.cloudy: return 'Cloudy';
      case WeatherType.rainy: return 'Rainy';
      case WeatherType.stormy: return 'Stormy';
    }
  }

  String get weatherEmoji {
    switch (weather) {
      case WeatherType.sunny: return '☀️';
      case WeatherType.cloudy: return '⛅';
      case WeatherType.rainy: return '🌧️';
      case WeatherType.stormy: return '⛈️';
    }
  }

  factory DailyUpdateModel.fromMap(Map<String, dynamic> map) => DailyUpdateModel(
    id: map['id'] ?? '',
    projectId: map['project_id'] ?? '',
    projectName: map['project_name'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    description: map['description'] ?? '',
    workDone: map['work_done'] ?? '',
    workersPresent: (map['workers_present'] as num?)?.toInt() ?? 0,
    materialsUsed: map['materials_used'] ?? '',
    issues: map['issues'] ?? '',
    images: [],
    engineerId: map['engineer_id'] ?? '',
    engineerName: map['engineer_name'] ?? '',
    weather: _parseWeather(map['weather']),
    progressPercentage: (map['progress_percentage'] as num?)?.toDouble() ?? 0,
    createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'project_id': projectId, 'project_name': projectName,
    'date': date.toIso8601String(), 'description': description,
    'work_done': workDone, 'workers_present': workersPresent,
    'materials_used': materialsUsed, 'issues': issues,
    'engineer_id': engineerId, 'engineer_name': engineerName,
    'weather': weather.name, 'progress_percentage': progressPercentage,
    'created_at': createdAt.toIso8601String(), 'synced': 0, 'pending_delete': 0,
  };

  static WeatherType _parseWeather(dynamic v) {
    switch (v?.toString()) {
      case 'cloudy': return WeatherType.cloudy;
      case 'rainy': return WeatherType.rainy;
      case 'stormy': return WeatherType.stormy;
      default: return WeatherType.sunny;
    }
  }
}
