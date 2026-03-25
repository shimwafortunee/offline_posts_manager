// database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'post.dart';

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
    CREATE TABLE posts (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      content TEXT,
      createdAt TEXT,
      isFavorite INTEGER
    )
    ''');

    // 🔥 DEFAULT POSTS
    await db.insert('posts', {
      'title': 'Welcome 🚀',
      'content': 'This app works offline using SQLite',
      'createdAt': DateTime.now().toString(),
      'isFavorite': 1,
    });

    await db.insert('posts', {
      'title': 'Assignment Ready',
      'content': 'CRUD operations are fully working',
      'createdAt': DateTime.now().toString(),
      'isFavorite': 0,
    });
  }

  Future<List<Post>> getPosts() async {
    final db = await instance.database;
    final result = await db.query('posts');

    // 🔥 Auto-fix if empty
    if (result.isEmpty) {
      await db.insert('posts', {
        'title': 'Auto Fix Post',
        'content': 'Database was empty, so this was added',
        'createdAt': DateTime.now().toString(),
        'isFavorite': 0,
      });

      final newResult = await db.query('posts');
      return newResult.map((e) => Post.fromMap(e)).toList();
    }

    return result.map((e) => Post.fromMap(e)).toList();
  }

  Future<int> insertPost(Post post) async {
    final db = await instance.database;
    return await db.insert('posts', post.toMap());
  }

  Future<int> updatePost(Post post) async {
    final db = await instance.database;
    return await db.update(
      'posts',
      post.toMap(),
      where: 'id = ?',
      whereArgs: [post.id],
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