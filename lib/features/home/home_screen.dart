import 'package:flutter/material.dart';
import 'package:halkaarzbilgi/features/home/widgets/account_card.dart';
import 'package:halkaarzbilgi/features/home/widgets/new_ipos_section.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF111111),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AccountCard(),
                SizedBox(height: 24),
                NewIposSection(),
                SizedBox(height: 24),
                WatchlistSection(),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
