/// Stub for web: backup/export is not supported on web.
import 'package:sqflite/sqflite.dart';

Future<void> exportToJson(Database db, String path) async {
  throw UnsupportedError('导出功能在浏览器版中不可用');
}

Future<void> importFromJson(Database db, String path) async {
  throw UnsupportedError('导入功能在浏览器版中不可用');
}

Future<void> backupDatabase(String path, {required Future<String> Function() getDbPath}) async {
  throw UnsupportedError('备份功能在浏览器版中不可用');
}

Future<void> restoreDatabase(String path, {required Future<String> Function() getDbPath, required Future<Database> Function(String) openDb}) async {
  throw UnsupportedError('恢复功能在浏览器版中不可用');
}
