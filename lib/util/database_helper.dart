import 'dart:async';
 
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:uyuyorum_haberin_olsun/model/message.dart';
 
class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
 
  factory DatabaseHelper() => _instance;

  final String tableMessage = 'messageTable';
  final String columnId = 'id';
  final String columnContactName = 'contactName';
  final String columnMessage = 'message';
 
  static Database _db;
 
  DatabaseHelper.internal();
 
  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
 
    return _db;
  }
 
  initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'messages.db');
 
    await deleteDatabase(path); // just for testing
 
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }
 
  void _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE $tableMessage($columnId INTEGER PRIMARY KEY, $columnContactName TEXT, $columnMessage TEXT)');
  }
 
  Future<int> saveMessage(Message message) async {
    var dbClient = await db;
    var result = await dbClient.insert(tableMessage, message.toMap());
//    var result = await dbClient.rawInsert(
//        'INSERT INTO $tableNote ($columnTitle, $columnDescription) VALUES (\'${note.title}\', \'${note.description}\')');
 
    return result;
  }
 
  Future<List> getAllMessages() async {
    var dbClient = await db;
    var result = await dbClient.query(tableMessage, columns: [columnId, columnContactName, columnMessage]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableNote');
 
    return result.toList();
  }
 
  Future<int> getCount() async {
    var dbClient = await db;
    return Sqflite.firstIntValue(await dbClient.rawQuery('SELECT COUNT(*) FROM $tableMessage'));
  }
 
  Future<Message> getMessage(int id) async {
    var dbClient = await db;
    List<Map> result = await dbClient.query(tableMessage,
        columns: [columnId, columnContactName, columnMessage],
        where: '$columnId = ?',
        whereArgs: [id]);
//    var result = await dbClient.rawQuery('SELECT * FROM $tableMessage WHERE $columnId = $id');
 
    if (result.length > 0) {
      return new Message.fromMap(result.first);
    }
 
    return null;
  }
 
  Future<int> deleteMessage(int id) async {
    var dbClient = await db;
    return await dbClient.delete(tableMessage, where: '$columnId = ?', whereArgs: [id]);
//    return await dbClient.rawDelete('DELETE FROM $tableMessage WHERE $columnId = $id');
  }
 
  Future<int> updateMessage(Message message) async {
    var dbClient = await db;
    return await dbClient.update(tableMessage, message.toMap(), where: "$columnId = ?", whereArgs: [message.id]);
//    return await dbClient.rawUpdate(
//        'UPDATE $tableMessage SET $columnContactName = \'${message.contactName}\', $columnMessage= \'${note.message}\' WHERE $columnId = ${message.id}');
  }

 
  Future close() async {
    var dbClient = await db;
    return dbClient.close();
  }
}