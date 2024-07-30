import 'package:books_new/screens/books_list_page.dart';
import 'package:books_new/screens/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyDt259GuVmGIe8UhxauElG6ijOrYYMBdUc",
          appId: '1:567018453862:android:f8e3d306749bbbc3ff66a7',
          messagingSenderId: '567018453862',
          projectId: 'project-final-b60bf',
          databaseURL:
              'https://project-final-b60bf-default-rtdb.asia-southeast1.firebasedatabase.app'));
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget homeDirect = const LoginPage();

  @override
  void initState() {
    super.initState();
    isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        //brightness: Brightness.dark,
        seedColor: const Color.fromARGB(255, 9, 83, 202),
      ),
      textTheme: GoogleFonts.latoTextTheme(),
    );

    return MaterialApp(
      theme: theme,
      home: homeDirect,
    );
  }

  void isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('login') == true) {
      homeDirect = const BookListPage();
    }
  }
}
