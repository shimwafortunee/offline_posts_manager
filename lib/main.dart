// main.dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'post.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostListScreen(),
    );
  }
}

class PostListScreen extends StatefulWidget {
  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  List<Post> posts = [];
  List<Post> filteredPosts = [];

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  void loadPosts() async {
    posts = await DatabaseHelper.instance.getPosts();
    filteredPosts = posts;
    setState(() {});
  }

  void search(String query) {
    filteredPosts = posts
        .where((p) =>
            p.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
    setState(() {});
  }

  void deletePost(int id) async {
    await DatabaseHelper.instance.deletePost(id);
    loadPosts();
  }

  void toggleFavorite(Post post) async {
    post.isFavorite = post.isFavorite == 1 ? 0 : 1;
    await DatabaseHelper.instance.updatePost(post);
    loadPosts();
  }

  void goToAdd() async {
    final result = await Navigator.push(
        context, MaterialPageRoute(builder: (_) => AddEditScreen()));

    if (result == true) loadPosts();
  }

  void goToEdit(Post post) async {
    final result = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => AddEditScreen(post: post)));

    if (result == true) loadPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Offline Posts Manager"),
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              filteredPosts =
                  posts.where((p) => p.isFavorite == 1).toList();
              setState(() {});
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onChanged: search,
              decoration: InputDecoration(
                labelText: "Search",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: filteredPosts.isEmpty
                ? Center(child: Text("No Posts Found"))
                : ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (_, i) {
                      final post = filteredPosts[i];
                      return Card(
                        child: ListTile(
                          title: Text(post.title),
                          subtitle: Text(post.content),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  post.isFavorite == 1
                                      ? Icons.star
                                      : Icons.star_border,
                                ),
                                onPressed: () =>
                                    toggleFavorite(post),
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => goToEdit(post),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () =>
                                    deletePost(post.id!),
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
        onPressed: goToAdd,
        child: Icon(Icons.add),
      ),
    );
  }
}

// ADD / EDIT SCREEN

class AddEditScreen extends StatefulWidget {
  final Post? post;

  AddEditScreen({this.post});

  @override
  _AddEditScreenState createState() => _AddEditScreenState();
}

class _AddEditScreenState extends State<AddEditScreen> {
  final title = TextEditingController();
  final content = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      title.text = widget.post!.title;
      content.text = widget.post!.content;
    }
  }

  void save() async {
    if (title.text.isEmpty || content.text.isEmpty) return;

    if (widget.post == null) {
      await DatabaseHelper.instance.insertPost(
        Post(
          title: title.text,
          content: content.text,
          createdAt: DateTime.now().toString(),
        ),
      );
    } else {
      await DatabaseHelper.instance.updatePost(
        Post(
          id: widget.post!.id,
          title: title.text,
          content: content.text,
          createdAt: widget.post!.createdAt,
          isFavorite: widget.post!.isFavorite,
        ),
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text(widget.post == null ? "Add" : "Edit")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: title,
                decoration: InputDecoration(labelText: "Title")),
            TextField(
                controller: content,
                decoration: InputDecoration(labelText: "Content")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: save, child: Text("Save"))
          ],
        ),
      ),
    );
  }
}