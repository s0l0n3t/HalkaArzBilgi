import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/features/home/widgets/account_card.dart';
import 'package:halkaarzbilgi/features/home/widgets/all_ipos_section.dart';
import 'package:halkaarzbilgi/features/home/widgets/new_ipos_section.dart';
import 'package:halkaarzbilgi/features/home/widgets/watchlist_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoggedIn) ...[
                  // Giriş yapmış kullanıcılar: AccountCard + Portföy + Yeni Halka Arzlar
                  const AccountCard(),
                  const SizedBox(height: 24),
                  const NewIposSection(),
                  const SizedBox(height: 24),
                  const WatchlistSection(),
                  const SizedBox(height: 24),
                ] else ...[
                  // Giriş yapmamış (guest) kullanıcılar: Yeni Halka Arzlar + Halka Arzlar
                  const NewIposSection(),
                  const SizedBox(height: 24),
                  const AllIposSection(),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
