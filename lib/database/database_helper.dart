import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../utils/formatters.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _db;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sz_construction.db');
    return await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS projects (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        client_name TEXT,
        client_phone TEXT,
        client_email TEXT,
        site_location TEXT,
        contract_value REAL DEFAULT 0,
        paid_amount REAL DEFAULT 0,
        start_date TEXT,
        end_date TEXT,
        status TEXT DEFAULT 'planning',
        progress REAL DEFAULT 0,
        description TEXT,
        engineer_name TEXT,
        engineer_id TEXT,
        length REAL DEFAULT 0,
        width REAL DEFAULT 0,
        area_unit TEXT DEFAULT 'sqft',
        total_area REAL DEFAULT 0,
        rate_per_unit REAL DEFAULT 0,
        estimated_cost REAL DEFAULT 0,
        project_manager TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        pending_delete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS workers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        alternate_phone TEXT,
        category TEXT DEFAULT 'helper',
        daily_wage REAL DEFAULT 0,
        status TEXT DEFAULT 'active',
        id_proof_url TEXT,
        id_proof_type TEXT DEFAULT 'Aadhar',
        join_date TEXT,
        address TEXT,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        pending_delete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS labour (
        id TEXT PRIMARY KEY,
        worker_id TEXT NOT NULL,
        worker_name TEXT,
        project_id TEXT,
        project_name TEXT,
        date TEXT NOT NULL,
        hours_worked REAL DEFAULT 8,
        overtime REAL DEFAULT 0,
        shift_type TEXT DEFAULT 'day',
        attendance_status TEXT DEFAULT 'present',
        notes TEXT,
        created_by TEXT,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        pending_delete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        reference_id TEXT,
        reference_name TEXT,
        amount REAL DEFAULT 0,
        paid_amount REAL DEFAULT 0,
        date TEXT,
        due_date TEXT,
        status TEXT DEFAULT 'pending',
        payment_mode TEXT DEFAULT 'cash',
        receipt_url TEXT,
        notes TEXT,
        gst_amount REAL DEFAULT 0,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        pending_delete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id TEXT PRIMARY KEY,
        project_id TEXT,
        project_name TEXT,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT,
        description TEXT,
        vendor_name TEXT,
        bill_image_url TEXT,
        payment_mode TEXT DEFAULT 'cash',
        created_by TEXT,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        pending_delete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory (
        id TEXT PRIMARY KEY,
        material_name TEXT NOT NULL,
        unit TEXT DEFAULT 'Unit',
        quantity REAL DEFAULT 0,
        min_stock REAL DEFAULT 5,
        supplier TEXT,
        supplier_contact TEXT,
        purchase_date TEXT,
        cost_per_unit REAL DEFAULT 0,
        used_quantity REAL DEFAULT 0,
        project_id TEXT,
        notes TEXT,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        pending_delete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_updates (
        id TEXT PRIMARY KEY,
        project_id TEXT,
        project_name TEXT,
        date TEXT NOT NULL,
        description TEXT,
        work_done TEXT,
        workers_present INTEGER DEFAULT 0,
        materials_used TEXT,
        issues TEXT,
        engineer_id TEXT,
        engineer_name TEXT,
        weather TEXT DEFAULT 'sunny',
        progress_percentage REAL DEFAULT 0,
        created_at TEXT,
        synced INTEGER DEFAULT 0,
        pending_delete INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        collection TEXT NOT NULL,
        document_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        data TEXT,
        created_at TEXT,
        attempts INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      try {
        await db.execute('ALTER TABLE projects ADD COLUMN length REAL DEFAULT 0');
        await db.execute('ALTER TABLE projects ADD COLUMN width REAL DEFAULT 0');
        await db.execute('ALTER TABLE projects ADD COLUMN area_unit TEXT DEFAULT "sqft"');
        await db.execute('ALTER TABLE projects ADD COLUMN total_area REAL DEFAULT 0');
        await db.execute('ALTER TABLE projects ADD COLUMN rate_per_unit REAL DEFAULT 0');
        await db.execute('ALTER TABLE projects ADD COLUMN estimated_cost REAL DEFAULT 0');
        await db.execute('ALTER TABLE projects ADD COLUMN project_manager TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
  }

  // ─── CRUD ────────────────────────────────────────────────────────────────────
  Future<String> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
    return data['id'] as String;
  }

  Future<int> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    return await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, String id) async {
    final db = await database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getById(String table, String id) async {
    final db = await database;
    final result = await db.query(table, where: 'id = ? AND pending_delete = 0', whereArgs: [id]);
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<Map<String, dynamic>>> getAll(String table, {
    String? where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy, limit: limit, offset: offset);
  }

  Future<List<Map<String, dynamic>>> getProjects() async {
    return await getAll('projects', where: 'pending_delete = 0', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getWorkers() async {
    return await getAll('workers', where: 'pending_delete = 0', orderBy: 'name ASC');
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    return await getAll('expenses', where: 'pending_delete = 0', orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> rawQuery(String sql, [List<dynamic>? args]) async {
    final db = await database;
    return await db.rawQuery(sql, args);
  }

  // ─── Dashboard stats ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    final db = await database;

    final projectsResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as active,
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
        SUM(contract_value) as contract_value,
        SUM(paid_amount) as paid_amount
      FROM projects WHERE pending_delete = 0
    ''');

    final workersResult = await db.rawQuery('SELECT COUNT(*) as total FROM workers WHERE status = "active" AND pending_delete = 0');
    
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1).toIso8601String();
    final expensesResult = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND pending_delete = 0',
      [monthStart],
    );

    final pendingResult = await db.rawQuery(
      'SELECT SUM(amount - paid_amount) as total FROM payments WHERE status IN ("pending", "partial", "overdue") AND pending_delete = 0',
    );

    final projectStats = projectsResult.first;
    return {
      'totalProjects': projectStats['total'] ?? 0,
      'activeProjects': projectStats['active'] ?? 0,
      'completedProjects': projectStats['completed'] ?? 0,
      'contractValue': (projectStats['contract_value'] as num?)?.toDouble() ?? 0,
      'paidAmount': (projectStats['paid_amount'] as num?)?.toDouble() ?? 0,
      'totalWorkers': workersResult.first['total'] ?? 0,
      'monthlyExpenses': (expensesResult.first['total'] as num?)?.toDouble() ?? 0,
      'pendingPayments': (pendingResult.first['total'] as num?)?.toDouble() ?? 0,
    };
  }

  Future<Map<String, dynamic>> getMonthlyTrends() async {
    final expenses = <double>[];
    final revenue = <double>[];
    final labels = <String>[];

    for (int i = 5; i >= 0; i--) {
      final d = DateTime.now();
      final month = DateTime(d.year, d.month - i, 1);
      final monthEnd = DateTime(month.year, month.month + 1, 1);

      final expResult = await rawQuery(
        'SELECT SUM(amount) as total FROM expenses WHERE date >= ? AND date < ? AND pending_delete = 0',
        [month.toIso8601String(), monthEnd.toIso8601String()],
      );
      final revResult = await rawQuery(
        'SELECT SUM(paid_amount) as total FROM payments WHERE type = "clientPayment" AND date >= ? AND date < ? AND pending_delete = 0',
        [month.toIso8601String(), monthEnd.toIso8601String()],
      );

      expenses.add((expResult.first['total'] as num?)?.toDouble() ?? 0);
      revenue.add((revResult.first['total'] as num?)?.toDouble() ?? 0);
      labels.add(AppFormatters.formatMonth(month));
    }

    return {'expenses': expenses, 'revenue': revenue, 'labels': labels};
  }

  Future<void> addToSyncQueue(String collection, String docId, String operation, String? data) async {
    final db = await database;
    await db.insert('sync_queue', {
      'collection': collection,
      'document_id': docId,
      'operation': operation,
      'data': data,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncQueue() async {
    return await getAll('sync_queue', orderBy: 'created_at ASC', limit: 50);
  }

  Future<void> removeSyncQueueItem(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementSyncAttempt(int id) async {
    final db = await database;
    await db.rawUpdate('UPDATE sync_queue SET attempts = attempts + 1 WHERE id = ?', [id]);
  }
}
