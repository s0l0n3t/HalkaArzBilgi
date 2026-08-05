import 'package:flutter/material.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111111),
      body: Center(
        child: Text(
          'Haberler',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
