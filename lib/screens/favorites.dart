import 'package:flutter/material.dart';

class FavoriteBooksPage extends StatefulWidget {
  final List<dynamic> favoriteBooks;
  final Function(dynamic) removeFromFavorites;

  const FavoriteBooksPage({
    super.key,
    required this.favoriteBooks,
    required this.removeFromFavorites,
  });

  @override
  FavoriteBooksPageState createState() => FavoriteBooksPageState();
}

class FavoriteBooksPageState extends State<FavoriteBooksPage> {
  List<dynamic> favoriteBooks = [];

  @override
  void initState() {
    super.initState();
    favoriteBooks = widget.favoriteBooks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Books'),
      ),
      body: favoriteBooks.isEmpty
          ? const Center(
              child: Text(
                'No favorite books added.',
                style: TextStyle(color: Colors.blueAccent, fontSize: 18),
              ),
            )
          : ListView.builder(
              itemCount: favoriteBooks.length,
              itemBuilder: (BuildContext context, int index) {
                return Dismissible(
                  key: Key(favoriteBooks[index]['title']),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text(
                            "Confirm",
                            style: TextStyle(color: Colors.lightBlueAccent),
                          ),
                          content: const Text(
                            "Are you sure you want to remove this book from favorites?",
                            style: TextStyle(
                                color: Colors.lightBlueAccent, fontSize: 20),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("CANCEL"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text(
                                "REMOVE",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      widget.removeFromFavorites(favoriteBooks[index]);
                      setState(() {
                        favoriteBooks.removeAt(index);
                      });
                    }
                  },
                  child: ListTile(
                    title: Text(favoriteBooks[index]['title'] ?? ''),
                    subtitle:
                        Text('Part: ${favoriteBooks[index]['number'] ?? ''}'),
                    leading: Image.network(
                      favoriteBooks[index]['cover'] ?? '',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
