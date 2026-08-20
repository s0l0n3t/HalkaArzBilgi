import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/core/repositories/stock_repository.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';

/// Repository nesnesini sağlayan Provider.
/// Veritabanı entegrasyonu (REST/Supabase) yapıldığında MockRemoteStockRepository 
/// yerine asıl repository sınıfı buraya eklenecek.
final stockRepositoryProvider = Provider<IStockRepository>((ref) {
  return MockRemoteStockRepository();
});

/// Tüm borsa hisselerini asenkron olarak çeken FutureProvider.
/// Heatmap ve arama ekranları gibi yerlerde kullanılacak.
final allMarketStocksProvider = FutureProvider<List<StockModel>>((ref) async {
  final repository = ref.watch(stockRepositoryProvider);
  return await repository.getAllStocks();
});
