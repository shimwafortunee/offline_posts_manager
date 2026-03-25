// main.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> posts = [];
  List<Map<String, dynamic>> filteredPosts = [];
  TextEditingController searchController = TextEditingController();

  bool showFavoritesOnly = false;

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  void fetchPosts() async {
    final data = await DatabaseHelper.instance.getPosts();

    setState(() {
      posts = data;

      if (showFavoritesOnly) {
        filteredPosts =
            data.where((post) => post['isFavorite'] == 1).toList();
      } else {
        filteredPosts = data;
      }
    });
  }

  void searchPosts(String query) {
    List<Map<String, dynamic>> baseList = showFavoritesOnly
        ? posts.where((post) => post['isFavorite'] == 1).toList()
        : posts;

    final results = baseList.where((post) {
      return post['title']
          .toLowerCase()
          .contains(query.toLowerCase());
    }).toList();

    setState(() {
      filteredPosts = results;
    });
  }

  void deletePost(int id) async {
    await DatabaseHelper.instance.deletePost(id);
    fetchPosts();
  }

  void toggleFavorite(Map<String, dynamic> post) async {
    int newValue = post['isFavorite'] == 1 ? 0 : 1;

    await DatabaseHelper.instance.updatePost(post['id'], {
      'title': post['title'],
      'content': post['content'],
      'isFavorite': newValue,
    });

    fetchPosts();
  }

  void showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete Post"),
        content: Text("Are you sure you want to delete this post?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              deletePost(id);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void openForm([Map<String, dynamic>? post]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostForm(post: post),
      ),
    );
    fetchPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          showFavoritesOnly ? "Favorite Posts ⭐" : "All Posts",
        ),
        actions: [
          IconButton(
            icon: Icon(
              showFavoritesOnly ? Icons.star : Icons.star_border,
            ),
            onPressed: () {
              setState(() {
                showFavoritesOnly = !showFavoritesOnly;
              });
              fetchPosts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search...",
                border: OutlineInputBorder(),
              ),
              onChanged: searchPosts,
            ),
          ),
          Expanded(
            child: filteredPosts.isEmpty
                ? Center(child: Text("No Posts Found"))
                : ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (_, index) {
                      final post = filteredPosts[index];

                      return Card(
                        child: ListTile(
                          title: Text(post['title']),
                          subtitle: Text(post['content']),

                          // Favorite icon
                          leading: IconButton(
                            icon: Icon(
                              post['isFavorite'] == 1
                                  ? Icons.star
                                  : Icons.star_border,
                              color: Colors.orange,
                            ),
                            onPressed: () => toggleFavorite(post),
                          ),

                          onTap: () => openForm(post),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => openForm(post),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () =>
                                    showDeleteDialog(post['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => openForm(),
      ),
    );
  }
}

class PostForm extends StatefulWidget {
  final Map<String, dynamic>? post;

  PostForm({this.post});

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      titleController.text = widget.post!['title'];
      contentController.text = widget.post!['content'];
    }
  }

  void savePost() async {
    final data = {
      'title': titleController.text,
      'content': contentController.text,
      'isFavorite': widget.post?['isFavorite'] ?? 0,
    };

    if (widget.post == null) {
      await DatabaseHelper.instance.insertPost(data);
    } else {
      await DatabaseHelper.instance
          .updatePost(widget.post!['id'], data);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.post == null ? "Add Post" : "Edit Post"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Title"),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: "Content"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text("Save"),
              onPressed: savePost,
            ),
          ],
        ),
      ),
    );
  }
}