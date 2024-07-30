import 'dart:convert';
import 'package:books_new/add_new_book.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:books_new/screens/login_page.dart';
import 'package:books_new/screens/book_details.dart';
import 'package:books_new/screens/favorites.dart';

class BookListPage extends StatefulWidget {
  const BookListPage({super.key});

  @override
  BookListPageState createState() => BookListPageState();
}

class BookListPageState extends State<BookListPage> {
  List<dynamic> books = [];
  List<dynamic> favoriteBooks = [];
  final databaseReference = FirebaseDatabase.instance.ref().child('books');

  @override
  void initState() {
    super.initState();
    showBooks();
    loadFavoriteBooks();
  }

  Future<void> showBooks() async {
    final snapshot = await databaseReference.get();
    if (snapshot.exists) {
      setState(() {
        books = snapshot.children.map((child) {
          var bookData = child.value as Map<dynamic, dynamic>;
          bookData['key'] = child.key;
          return bookData;
        }).toList();
      });
    } else {
      setState(() {
        books = [];
      });
    }
  }

  void loadFavoriteBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteBooks = prefs
              .getStringList('favoriteBooks')
              ?.map((e) => json.decode(e))
              .toList() ??
          [];
    });
  }

  void saveFavoriteBooks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> favoriteBooksJson =
        favoriteBooks.map((e) => json.encode(e)).toList();
    await prefs.setStringList('favoriteBooks', favoriteBooksJson);
  }

  void addToFavorites(dynamic book) {
    setState(() {
      if (!favoriteBooks.contains(book)) {
        favoriteBooks.add(book);
        saveFavoriteBooks();
      }
    });
  }

  void removeFromFavorites(dynamic book) {
    setState(() {
      favoriteBooks.remove(book);
      saveFavoriteBooks();
    });
  }

  void navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoriteBooksPage(
          favoriteBooks: favoriteBooks,
          removeFromFavorites: removeFromFavorites,
        ),
      ),
    );
  }

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  void openAddBook() {
    showModalBottomSheet<void>(
      useSafeArea: true,
      isScrollControlled: true,
      context: context,
      builder: (ctx) => NewBook(
        onSave: (Map<String, dynamic> map) {
          showBooks();
        },
      ),
    );
  }

  void showAlertBox(String bookKey) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Alert',
            style: TextStyle(
                color: Colors.lightBlue.shade300, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Do you want to delete this book?',
            style: TextStyle(color: Colors.lightBlue.shade300, fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'CANCEL',
                style: TextStyle(
                    color: Colors.lightBlue.shade300,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'OK',
                style: TextStyle(
                    color: Colors.lightBlue.shade300,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                databaseReference.child(bookKey).remove().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Book is deleted successfully')),
                  );
                  Navigator.pop(context);
                  showBooks();
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete book: $error')),
                  );
                });
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SystemNavigator.pop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Books List'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.star),
              tooltip: 'Favorites',
              onPressed: navigateToFavorites,
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Log Out',
              onPressed: logout,
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: openAddBook,
          foregroundColor: Colors.lightBlue.shade200,
          child: const Icon(Icons.add),
        ),
        body: books.isEmpty
            ? Center(
                child: Text(
                  'No books available. Please add some books.',
                  style: TextStyle(
                      color: Colors.lightBlue.shade300,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 4,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: books.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isFavorite = favoriteBooks.contains(books[index]);
                  String bookKey = books[index]['key'];

                  return InkWell(
                    onLongPress: () {
                      showAlertBox(bookKey);
                    },
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => BookDetails(
                          book: books[index],
                          addToFavorites: addToFavorites,
                          removeFromFavorites: removeFromFavorites,
                          isFavorite: isFavorite,
                        ),
                      ),
                    ),
                    child: GridTile(
                      child: Card(
                        elevation: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            const SizedBox(width: 10, height: 10),
                            SizedBox(
                              width: 170,
                              height: 150,
                              child: Card(
                                child: Center(
                                  child: books[index]['cover'] != null
                                      ? Image.network(books[index]['cover'])
                                      : const Icon(Icons.image),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10, height: 15),
                            Text(
                              books[index]['title'] ?? 'No Title',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.blueAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
