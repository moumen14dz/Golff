import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class DBHelper {
  static const String DATABASE_NAME = 'golf.db';

  static const String BILL_TABLE_NAME = 'bills';
  static const String BILL_ID_COL = 'id';
  static const String BILL_CONTENT_COL = 'content';
  static const String BILL_IMAGES_COL = 'images';
  static const String BILL_VIDEOS_COL = 'videos';

  static Future<Database> golfDatabase() async {
    final dbPath = await getDatabasesPath();
    final db = await openDatabase(
      path.join(dbPath, DATABASE_NAME),
      onCreate: (db, version) {
        return db.execute(
            'CREATE TABLE $BILL_TABLE_NAME ($BILL_ID_COL integer primary key autoincrement, $BILL_CONTENT_COL TEXT, $BILL_IMAGES_COL TEXT, $BILL_VIDEOS_COL TEXT)');
      },
      version: 1,
    );
    return db;
  }

  static Future<void> insertDBData(
      String table, Map<String, dynamic> data) async {
    final sqlDB = await DBHelper.golfDatabase();
    await sqlDB.insert(
      table,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('saved in sqflite successfully');
  }

  static Future<List<Map<String, dynamic>>> getDBData(String table) async {
    final sqlDB = await DBHelper.golfDatabase();
    final data = sqlDB.query(table);
    print('data retrieved from sqflite successfully');
    return data;
  }

  static Future<void> deleteRow(String tableName, int id) async {
    final sqlDB = await DBHelper.golfDatabase();
    await sqlDB.rawQuery('DELETE FROM $tableName WHERE id = $id');
    print('data with id = $id deleted from sqflite successfully');
  }
}
