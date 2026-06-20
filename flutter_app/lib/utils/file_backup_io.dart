import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';

/// Export database contents to a JSON file (mobile only)
Future<void> exportToJson(Database db, String path) async {
  final data = {
    'wines': await db.query('wines'),
    'tastings': await db.query('tastings'),
    'tasting_appearance': await db.query('tasting_appearance'),
    'tasting_aroma': await db.query('tasting_aroma'),
    'tasting_palate': await db.query('tasting_palate'),
    'tasting_overall': await db.query('tasting_overall'),
    'flavors': await db.query('flavors'),
    'tasting_flavors': await db.query('tasting_flavors'),
    'weight_config': await db.query('weight_config'),
    'user_profile': await db.query('user_profile'),
    'storage_locations': await db.query('storage_locations'),
    'cellar': await db.query('cellar'),
    'cellar_transactions': await db.query('cellar_transactions'),
  };
  final file = File(path);
  await file.writeAsString(jsonEncode(data), encoding: utf8);
}

/// Import database contents from a JSON file (mobile only)
Future<void> importFromJson(Database db, String path) async {
  final file = File(path);
  final content = await file.readAsString(encoding: utf8);
  final data = jsonDecode(content) as Map<String, dynamic>;

  await db.transaction((txn) async {
    final tables = [
      'tasting_flavors', 'cellar_transactions', 'cellar',
      'tasting_overall', 'tasting_palate', 'tasting_aroma',
      'tasting_appearance', 'tastings', 'wines',
      'flavors', 'weight_config', 'user_profile', 'storage_locations',
    ];
    for (final table in tables) {
      await txn.delete(table);
    }

    final order = [
      'wines', 'tastings', 'tasting_appearance', 'tasting_aroma',
      'tasting_palate', 'tasting_overall', 'flavors', 'tasting_flavors',
      'weight_config', 'user_profile', 'storage_locations', 'cellar',
      'cellar_transactions',
    ];

    for (final table in order) {
      final rows = data[table] as List<dynamic>?;
      if (rows != null) {
        for (final row in rows) {
          await txn.insert(table, row as Map<String, dynamic>);
        }
      }
    }
  });
}

/// Backup the SQLite database file (mobile only)
Future<void> backupDatabase(String path, {required Future<String> Function() getDbPath}) async {
  final dbPath = await getDbPath();
  final source = File(dbPath);
  final dest = File(path);
  await source.copy(dest.path);
}

/// Restore database from a backup file (mobile only)
Future<void> restoreDatabase(String path, {required Future<String> Function() getDbPath, required Future<Database> Function(String) openDb}) async {
  final dbPath = await getDbPath();
  final source = File(path);
  await source.copy(dbPath);
}
