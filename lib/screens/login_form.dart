import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:books_new/screens/books_list_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  LoginFormState createState() => LoginFormState();
}

class LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  void initState() {
    super.initState();
    loadSavedCredentials();
  }

  void loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedUsername = prefs.getString('username');
    String? savedPassword = prefs.getString('password');

    if (savedUsername != null && savedPassword != null) {
      setState(() {
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
        rememberMe = true;
      });
    }
  }

  void _submitForm({bool isSignUp = false}) async {
    if (isSignUp) {
      await clearStoredCredentials();
      setState(() {
        _usernameController.text = '';
        _passwordController.text = '';
        rememberMe = false;
      });
    } else {
      String username = _usernameController.text.trim();
      String password = _passwordController.text.trim();

      if (username.isNotEmpty && password.isNotEmpty) {
        if (rememberMe) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('username', username);
          prefs.setString('password', password);
          prefs.setBool('login', true);
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BookListPage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text(
              'Error',
              style: TextStyle(
                  color: Colors.blueAccent, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Invalid credentials. Please try again.',
              style: TextStyle(color: Colors.blueAccent, fontSize: 18),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> clearStoredCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
    prefs.setBool('login', false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: NetworkImage(
                      'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSIdm9_rqiZFoksDFb4DJXQt8j2HSJ7-85rMQ&s',
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: GoogleFonts.montserrat(
                        textStyle: TextStyle(
                            fontSize: 55,
                            color: Colors.blue.shade300,
                            fontWeight: FontWeight.w300),
                      ),
                    ),
                    Text(
                      'welcome!',
                      style: GoogleFonts.nunito(
                        textStyle: TextStyle(
                            color: Colors.blue.shade300,
                            fontSize: 45,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  style:
                      const TextStyle(color: Colors.blueAccent, fontSize: 20),
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: TextField(
                  style:
                      const TextStyle(color: Colors.blueAccent, fontSize: 18),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (bool? newValue) {
                        setState(() {
                          rememberMe = newValue ?? false;
                        });
                      },
                    ),
                    Text(
                      'Remember me',
                      style:
                          TextStyle(color: Colors.blue.shade300, fontSize: 18),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 36.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => _submitForm(),
                      child:
                          const Text('Login', style: TextStyle(fontSize: 20)),
                    ),
                    const SizedBox(width: 130),
                    ElevatedButton(
                      onPressed: () => _submitForm(isSignUp: true),
                      child:
                          const Text('SignUp', style: TextStyle(fontSize: 20)),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
