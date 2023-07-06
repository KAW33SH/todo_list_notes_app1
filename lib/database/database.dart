import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute(
        'CREATE TABLE notesDb(id INTEGER PRIMARY KEY, title TEXT, description TEXT)');
  }

  static Future<sql.Database> database() async {
    return sql.openDatabase(
      'notesDb.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        // debug statement
        print('..Creating tables');
        await createTables(database);
      },
    );
  }

  static Future<int> createNote(String title, String? description) async {
    final sql.Database db = await SQLHelper.database();

    final data = {
      'title': title,
      'description': description,
    };
    final id = await db.insert('notesDb', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    print('..Inserted $id');
    return id;
  }

  static Future<List<Map<String, dynamic>>> getNotes() async {
    final sql.Database db = await SQLHelper.database();
    final notes = await db.query('notesDb');
    print('..Got ${notes.length} notes');
    return notes;
  }

  // getMyNotesById widgets.id
  static Future<List<Map<String, dynamic>>> getNotesById(int id) async {
    final sql.Database db = await SQLHelper.database();
    final notes = await db.query('notesDb', where: 'id = ?', whereArgs: [id]);
    print('..Got ${notes.length} notes');
    return notes;
  }

  static Future<int> editNote(int id, String title, String? description) async {
    final sql.Database db = await SQLHelper.database();
    final data = {
      'title': title,
      'description': description,
    };
    final count =
        await db.update('notesDb', data, where: 'id = ?', whereArgs: [id]);
    print('..Updated $count note');
    return count;
  }

  static Future<int> deleteNote(int id) async {
    final sql.Database db = await SQLHelper.database();
    final count = await db.delete('notesDb', where: 'id = ?', whereArgs: [id]);
    print('..Deleted $count note');
    return count;
  }

  // search
  static Future<List<Map<String, dynamic>>> searchNotes(String query) async {
    final sql.Database db = await SQLHelper.database();
    final notes = await db.query('notesDb',
        where: 'title LIKE ? OR description LIKE ?',
        whereArgs: ['%$query%', '%$query%']);
    print('..Got ${notes.length} rows');
    return notes;
  }
}
