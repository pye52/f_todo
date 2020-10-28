import 'package:sqflite/sqflite.dart';

class DatabaseInstance {
  static const String _DB_NAME = "todo.db";
  DatabaseInstance._();

  Database _internalDb;

  void init() async {
    _internalDb = await openDatabase(_DB_NAME);
  }

  static void initDb() => _instance.init();
  static final DatabaseInstance _instance = DatabaseInstance._();
}
