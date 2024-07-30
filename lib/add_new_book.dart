import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class NewBook extends StatefulWidget {
  final dynamic book;
  final Function(Map<String, dynamic>)? onSave;

  const NewBook({
    super.key,
    this.book,
    this.onSave,
  });

  @override
  State<NewBook> createState() => _NewBookState();
}

class _NewBookState extends State<NewBook> {
  final titleController = TextEditingController();
  final authorController = TextEditingController();
  final pagesController = TextEditingController();
  final descriptionController = TextEditingController();
  final coverController = TextEditingController();

  late final databaseReference = FirebaseDatabase.instance.ref().child('books');
  String? bookId;

  @override
  void initState() {
    super.initState();
    if (widget.book != null) {
      final book = widget.book!;
      titleController.text = book['title'] ?? '';
      authorController.text = book['author'] ?? '';
      pagesController.text = book['pages']?.toString() ?? '';
      descriptionController.text = book['description'] ?? '';
      coverController.text = book['cover'] ?? '';
      bookId = book['key'];
    }
  }

  void saveBookToFirebase() {
    String title = titleController.text.trim();
    String author = authorController.text.trim();
    int pages = int.tryParse(pagesController.text.trim()) ?? 0;
    String description = descriptionController.text.trim();
    String cover = coverController.text.trim();

    if (title.isEmpty || author.isEmpty || pages <= 0 || cover.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Invalid Input',
              style: TextStyle(
                  color: Colors.lightBlue.shade300,
                  fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Please enter valid book details.',
              style: TextStyle(color: Colors.lightBlue.shade300, fontSize: 20),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(
                      color: Colors.lightBlue.shade300,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      return;
    }

    Map<String, dynamic> bookData = {
      'title': title,
      'author': author,
      'pages': pages,
      'description': description,
      'cover': cover,
    };

    if (bookId == null) {
      databaseReference.push().set(bookData).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book added successfully')),
        );
        if (widget.onSave != null) {
          widget.onSave!(bookData);
        }
        Navigator.pop(context);
      });
    } else {
      databaseReference.child(bookId!).update(bookData).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book updated successfully')),
        );
        if (widget.onSave != null) {
          widget.onSave!(bookData);
        }
        Navigator.pop(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: double.infinity,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.book == null ? 'Add a New Book' : 'Edit Book Details',
                style: TextStyle(
                    color: Colors.lightBlue.shade300,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                keyboardType: TextInputType.multiline,
                decoration:
                    const InputDecoration(labelText: 'Name of the Book'),
                style:
                    TextStyle(color: Colors.lightBlue.shade300, fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: authorController,
                keyboardType: TextInputType.multiline,
                decoration:
                    const InputDecoration(labelText: 'Name of the Author'),
                style:
                    TextStyle(color: Colors.lightBlue.shade300, fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: coverController,
                decoration: const InputDecoration(labelText: 'Cover Image URL'),
                style:
                    TextStyle(color: Colors.lightBlue.shade300, fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pagesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Number of Pages'),
                style:
                    TextStyle(color: Colors.lightBlue.shade300, fontSize: 20),
              ),
              const SizedBox(height: 16),
              TextField(
                keyboardType: TextInputType.multiline,
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                style:
                    TextStyle(color: Colors.lightBlue.shade300, fontSize: 20),
              ),
              const SizedBox(height: 60),
              OutlinedButton(
                onPressed: saveBookToFirebase,
                child: Text(
                  widget.book == null ? 'Submit' : 'Update',
                  style:
                      TextStyle(fontSize: 20, color: Colors.lightBlue.shade300),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
