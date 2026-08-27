import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Alt gezinme çubuğundaki (BottomNavBar) aktif sekme indeksini takip eden provider.
/// 0: Anasayfa (/home)
/// 1: Haberler (/news)
/// 2: Bildirimler (/notifications)
/// 3: Keşfet/Arama (/search)
final tabIndexProvider = StateProvider<int>((ref) => 0);
