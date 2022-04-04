import 'package:flutter/material.dart';
import 'package:my_own_flashcards/db/database.dart';
import 'package:my_own_flashcards/screens/home_screen.dart';

late MyDatabase database;

void main() {
  database = MyDatabase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '私だけの単語帳',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Lanobe',
      ),
      home: HomeScreen(),
    );
  }
}


