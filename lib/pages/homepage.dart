import 'package:checklist/util/navbar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      body: Center(
        child: Text("Home Page - Selected Index: $_selectedIndex",
          style: TextStyle(fontSize: 24),
        ),
    ),
        bottomNavigationBar: LiquidGlassNavbar(
            selectedIndex: _selectedIndex,
            onTabSelected: _onTabSelected)
      );
  }
}
