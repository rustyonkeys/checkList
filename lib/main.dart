import 'package:checklist/pages/addtaskpage.dart';
import 'package:checklist/pages/analytic%20page.dart';
import 'package:checklist/pages/homepage.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: true,
      home: const HomePage(),
    );
  }
}

