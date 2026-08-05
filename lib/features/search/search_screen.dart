import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111111),
      body: Center(
        child: Text(
          'Arama',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
