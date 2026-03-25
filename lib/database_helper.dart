// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('posts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE posts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        content TEXT,
        isFavorite INTEGER
      )
    ''');

    // Default posts
    await db.insert('posts', {
      'title': 'Welcome',
      'content': 'Start managing your posts offline.',
      'isFavorite': 0
    });

    await db.insert('posts', {
      'title': 'Study Tip',
      'content': 'Review your notes daily.',
      'isFavorite': 1
    });

    await db.insert('posts', {
      'title': 'Reminder',
      'content': 'Submit your assignment on time.',
      'isFavorite': 0
    });
  }

  Future<List<Map<String, dynamic>>> getPosts() async {
    final db = await instance.database;
    return await db.query('posts', orderBy: 'id DESC');
  }

  Future<int> insertPost(Map<String, dynamic> post) async {
    final db = await instance.database;
    return await db.insert('posts', post);
  }

  Future<int> updatePost(int id, Map<String, dynamic> post) async {
    final db = await instance.database;
    return await db.update(
      'posts',
      post,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deletePost(int id) async {
    final db = await instance.database;
    return await db.delete(
      'posts',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}