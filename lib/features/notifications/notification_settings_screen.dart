import 'package:flutter/material.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111111),
      body: Center(
        child: Text(
          'Bildirim Ayarları',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
      ),
    );
  }
}
