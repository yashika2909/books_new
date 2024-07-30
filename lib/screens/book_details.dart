import 'package:books_new/add_new_book.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class BookDetails extends StatefulWidget {
  final dynamic book;
  final Function(dynamic) addToFavorites;
  final Function(dynamic) removeFromFavorites;
  final bool isFavorite;

  const BookDetails({
    super.key,
    required this.book,
    required this.addToFavorites,
    required this.removeFromFavorites,
    required this.isFavorite,
  });

  @override
  BookDetailsState createState() => BookDetailsState();
}

class BookDetailsState extends State<BookDetails> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void openEditBook() async {
    final updatedBook = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => NewBook(
        book: widget.book,
        onSave: (bookData) {
          Navigator.of(context).pop(bookData);
        },
      ),
    );

    if (updatedBook != null) {
      final bookRef = FirebaseDatabase.instance
          .ref()
          .child('books')
          .child(widget.book['key']);
      await bookRef.update(updatedBook);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book details updated successfully')),
      );
      setState(() {
        widget.book.addAll(updatedBook);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['title'] ?? ''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              width: double.infinity,
              child: Image.network(
                widget.book['cover'] ?? '',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 26.0),
            RichText(
              text: TextSpan(
                text: 'Part: ',
                style: TextStyle(color: Colors.blue[800], fontSize: 20),
                children: <TextSpan>[
                  TextSpan(
                    text: '${widget.book['number'] ?? ''}',
                    style: TextStyle(color: Colors.blue[300], fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            RichText(
              text: TextSpan(
                text: 'Title: ',
                style: TextStyle(color: Colors.blue[800], fontSize: 20),
                children: <TextSpan>[
                  TextSpan(
                    text: '${widget.book['title'] ?? ''}',
                    style: TextStyle(color: Colors.blue[300], fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            RichText(
              text: TextSpan(
                text: 'Number of pages: ',
                style: TextStyle(color: Colors.blue[800], fontSize: 20),
                children: <TextSpan>[
                  TextSpan(
                    text: '${widget.book['pages'] ?? ''}',
                    style: TextStyle(color: Colors.blue[300], fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            RichText(
              text: TextSpan(
                text: 'Release Date: ',
                style: TextStyle(color: Colors.blue[800], fontSize: 20),
                children: <TextSpan>[
                  TextSpan(
                    text: '${widget.book['releaseDate'] ?? ''}',
                    style: TextStyle(color: Colors.blue[300], fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            RichText(
              text: TextSpan(
                text: 'Description: ',
                style: TextStyle(color: Colors.blue[800], fontSize: 20),
                children: <TextSpan>[
                  TextSpan(
                    text: '${widget.book['description'] ?? ''}',
                    style: TextStyle(color: Colors.blue[300], fontSize: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 36.0),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_isFavorite) {
                      widget.removeFromFavorites(widget.book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Removed from Favorites',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    } else {
                      widget.addToFavorites(widget.book);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Added to Favorites',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    }
                    setState(() {
                      _isFavorite = !_isFavorite;
                    });
                  },
                  child: Text(
                    _isFavorite ? 'Remove from Favorites' : 'Add to Favorites',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 90),
                IconButton.filledTonal(
                  onPressed: openEditBook,
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit the book information',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
