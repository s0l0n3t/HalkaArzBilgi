import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:halkaarzbilgi/core/providers/market_provider.dart';
import 'package:halkaarzbilgi/core/providers/tab_provider.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';
import 'package:halkaarzbilgi/features/search/widgets/search_screen_skeleton.dart';

enum HeatmapTileSize { large, medium, small, mini, micro }

enum StockFilter { all, topGainers, topLosers }

class HeatmapTileItem {
  final String symbol;
  final String companyName;
  final double changePercent;
  final HeatmapTileSize size;
  final bool isGain;
  final double price;
  final bool isEmpty; // Pad for missing data

  const HeatmapTileItem({
    required this.symbol,
    required this.companyName,
    required this.changePercent,
    required this.size,
    required this.isGain,
    required this.price,
    this.isEmpty = false,
  });

  factory HeatmapTileItem.empty() => const HeatmapTileItem(
        symbol: '',
        companyName: '',
        changePercent: 0,
        size: HeatmapTileSize.micro,
        isGain: true,
        price: 0,
        isEmpty: true,
      );
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  StockFilter _selectedFilter = StockFilter.all;

  /// Kullanıcının kutucuklar için özelleştirdiği hisse eşleşmeleri: { slotIndex: symbol }
  Map<int, String> _slotOverrides = {};

  @override
  void initState() {
    super.initState();
    _loadSlotOverrides();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
  }

  Future<void> _loadSlotOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('heatmap_custom_slot_overrides');
      if (savedJson != null && savedJson.isNotEmpty) {
        final decoded = jsonDecode(savedJson) as Map<String, dynamic>;
        if (mounted) {
          setState(() {
            _slotOverrides = decoded.map((key, value) => MapEntry(int.parse(key), value as String));
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _handleStockSelection({
    required int slotIndex,
    required HeatmapTileItem currentStock,
    required StockModel newStock,
    required List<HeatmapTileItem> allGridItems,
  }) async {
    final newSymbol = newStock.symbol;

    // Haritada döngüsel tekrardan dolayı mükerrer hisse var mı kontrol et
    final validItems = allGridItems.where((i) => !i.isEmpty).toList();
    final uniqueSymbols = validItems.map((i) => i.symbol).toSet();
    final hasDuplicates = uniqueSymbols.length < validItems.length;

    String snackBarMessage;
    if (!hasDuplicates) {
      // API'den 45+ benzersiz hisse geldiğinde: Takas (Swap) mantığı çalışır
      int? existingSlot;
      for (int i = 0; i < allGridItems.length; i++) {
        if (i != slotIndex && !allGridItems[i].isEmpty && allGridItems[i].symbol == newSymbol) {
          existingSlot = i;
          break;
        }
      }

      if (existingSlot != null) {
        final displacedSymbol = currentStock.isEmpty ? '' : currentStock.symbol;
        setState(() {
          _slotOverrides[slotIndex] = newSymbol;
          _slotOverrides[existingSlot!] = displacedSymbol;
        });

        if (displacedSymbol.isEmpty) {
          snackBarMessage = '$newSymbol kutucuğa taşındı, eski kutusu boşaltıldı';
        } else {
          snackBarMessage = '$newSymbol ile $displacedSymbol yer değiştirdi';
        }
      } else {
        setState(() {
          _slotOverrides[slotIndex] = newSymbol;
        });
        snackBarMessage = '$newSymbol kutucuğa eklendi';
      }
    } else {
      // Döngüsel tekrarda (aynı hisse 2-3 kutuda varken): Doğrudan atama yapılır
      setState(() {
        _slotOverrides[slotIndex] = newSymbol;
      });
      snackBarMessage = '$newSymbol kutucuğa eklendi';
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final mapToSave = _slotOverrides.map((key, value) => MapEntry(key.toString(), value));
      await prefs.setString('heatmap_custom_slot_overrides', jsonEncode(mapToSave));
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            snackBarMessage,
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A1A1C),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  List<HeatmapTileItem> _getMappedStocks(List<StockModel> rawStocks) {
    // 1. Convert to HeatmapTileItem
    var list = rawStocks.map((s) => HeatmapTileItem(
      symbol: s.symbol,
      companyName: s.companyName,
      changePercent: s.changePercent, // Uses the graph percentage
      size: HeatmapTileSize.medium, // Temp size, overridden by layout
      isGain: s.isGain,
      price: s.currentPrice,
    )).toList();

    // 2. Apply Filter
    if (_selectedFilter == StockFilter.topGainers) {
      list = list.where((s) => s.isGain).toList()
        ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    } else if (_selectedFilter == StockFilter.topLosers) {
      list = list.where((s) => !s.isGain).toList()
        ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    }

    // 3. Apply Search Query - Arama yapılıyorsa doğrudan eşleşen listeyi döndür (mozaik 45 kısıtlamasına sokma)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toUpperCase();
      return list.where((stock) {
        final symMatch = stock.symbol.toUpperCase().contains(query);
        final nameMatch = stock.companyName.toUpperCase().contains(query);
        return symMatch || nameMatch;
      }).toList();
    }

    // 4. Mozaik katmanlarına dengeli biçimde dağıt.
    // Filtre 'Tümü' (StockFilter.all) iken kullanıcının özel hisseleri korunur;
    // Filtre açıkken (Artanlar/Azalanlar) tüm pazar hisseleri filtreye göre kutuları doldurur.
    return _distributeStocksAcrossGrid(
      list,
      45,
      rawStocks,
      applyOverrides: _selectedFilter == StockFilter.all,
    );
  }

  /// Aktif hisseleri ve %0 boş blokları mozaikteki tüm katmanlara (Dev, Orta, Küçük, Mini, Mikro)
  /// dengeli ve karışık biçimde yerleştirir.
  List<HeatmapTileItem> _distributeStocksAcrossGrid(
    List<HeatmapTileItem> activeStocks,
    int totalSlots,
    List<StockModel> rawStocks, {
    bool applyOverrides = true,
  }) {
    if (activeStocks.isEmpty) {
      return List.generate(totalSlots, (_) => HeatmapTileItem.empty());
    }

    // Mozaikteki tüm katmanlara (Dev, Orta, Küçük, Mini, Mikro - Üst ve Alt) dengeli dağılım sırası
    const slotPriorityOrder = [
      0,   // Üst Sol Dev Blok (Large)
      2,   // Üst Sağ Satır 1 (Medium - Flex 6)
      22,  // Alt Sol Dev Blok (Large)
      5,   // Üst Sağ Satır 2 (Medium)
      10,  // Üst Sol Dikey (Small)
      24,  // Alt Sağ Satır 1 (Medium - Flex 6)
      13,  // Üst Sağ Mozaik Üst (Small)
      8,   // Üst Sağ Satır 3 (Medium)
      27,  // Alt Sağ Satır 2 (Medium)
      15,  // Üst Sağ Mini (Mini)
      32,  // Alt Sol Dikey (Small)
      18,  // Üst Sağ Mikro (Micro)
      35,  // Alt Sağ Mozaik Üst (Small)
      30,  // Alt Sağ Satır 3 (Medium)
      37,  // Alt Sağ Mini (Mini)
      40,  // Alt Sağ Mikro (Micro)
      1,   // Üst Sol Dev 2 (Large)
      3,   // Üst Sağ Satır 1 (Medium - Flex 5)
      23,  // Alt Sol Dev 2 (Large)
      4, 6, 7, 9, 11, 12, 14, 16, 17, 19, 20, 21,
      25, 26, 28, 29, 31, 33, 34, 36, 38, 39, 41, 42, 43, 44,
    ];

    final result = List<HeatmapTileItem>.generate(
      totalSlots,
      (_) => HeatmapTileItem.empty(),
    );

    // Eldeki hisseler 45'ten az olsa bile döngüsel olarak (i % activeStocks.length)
    // tüm kutucukları eksiksiz doldurur. İleride API ile 45+ hisse geldiğinde
    // her kutucuk benzersiz bir hisse ile dolar.
    for (int i = 0; i < totalSlots && i < slotPriorityOrder.length; i++) {
      final targetSlot = slotPriorityOrder[i];
      if (targetSlot < totalSlots) {
        result[targetSlot] = activeStocks[i % activeStocks.length];
      }
    }

    // Kullanıcının elle değiştirdiği slotları (overrides) yalnızca filtre 'Tümü' iken uygula
    if (applyOverrides) {
      for (final entry in _slotOverrides.entries) {
        final slot = entry.key;
        final symbol = entry.value;
        if (slot >= 0 && slot < totalSlots) {
          if (symbol.isEmpty) {
            result[slot] = HeatmapTileItem.empty();
          } else {
            final match = rawStocks.where((s) => s.symbol == symbol).firstOrNull;
            if (match != null) {
              result[slot] = HeatmapTileItem(
                symbol: match.symbol,
                companyName: match.companyName,
                changePercent: match.changePercent,
                size: HeatmapTileSize.medium,
                isGain: match.isGain,
                price: match.currentPrice,
              );
            }
          }
        }
      }
    }

    return result;
  }

  void _onStockTap(String symbol) {
    if (symbol.isEmpty) return; // Boş (pad) blok tıklandığında yoksay
    context.push('/ipo/$symbol');
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Filtreleme Seçenekleri',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFilterOption(
                      sheetContext: sheetContext,
                      title: 'Tümü',
                      subtitle: 'Tüm hisse senetleri',
                      filter: StockFilter.all,
                      icon: Icons.grid_view_rounded,
                      setSheetState: setSheetState,
                    ),
                    _buildFilterOption(
                      sheetContext: sheetContext,
                      title: 'En Çok Artanlar',
                      subtitle: 'Yükselişteki hisseler',
                      filter: StockFilter.topGainers,
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.primaryGreen,
                      setSheetState: setSheetState,
                    ),
                    _buildFilterOption(
                      sheetContext: sheetContext,
                      title: 'En Çok Azalanlar',
                      subtitle: 'Düşüşteki hisseler',
                      filter: StockFilter.topLosers,
                      icon: Icons.trending_down_rounded,
                      iconColor: AppColors.lossRed,
                      setSheetState: setSheetState,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption({
    required BuildContext sheetContext,
    required String title,
    required String subtitle,
    required StockFilter filter,
    required IconData icon,
    Color? iconColor,
    required StateSetter setSheetState,
  }) {
    final isSelected = _selectedFilter == filter;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        setState(() {
          _selectedFilter = filter;
        });
        setSheetState(() {});
        Navigator.of(sheetContext).pop();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2C2C2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: (iconColor ?? Colors.white).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryGreen,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sekme geçişi dinleyicisi: Keşfet/Arama sekmesine her girildiğinde filtreleri ve aramayı sıfırla
    ref.listen<int>(tabIndexProvider, (previous, next) {
      if (next == 3 && previous != 3) {
        _searchController.clear();
        setState(() {
          _searchQuery = '';
          _selectedFilter = StockFilter.all;
        });
        _focusNode.unfocus();
      }
    });

    final isSearching = _searchQuery.isNotEmpty;
    final asyncStocks = ref.watch(allMarketStocksProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryGreen,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            ref.invalidate(allMarketStocksProvider);
            try {
              await ref.read(allMarketStocksProvider.future);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Başlık & Filtre İkonu: Hisse Senetleri (Aynı Satırda) ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 12, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Hisse Senetleri',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        icon: Stack(
                          alignment: Alignment.topRight,
                          children: [
                            const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            if (_selectedFilter != StockFilter.all)
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                              ),
                          ],
                        ),
                        onPressed: _showFilterSheet,
                      ),
                    ],
                  ),
                ),

                // ── 2. Arama Çubuğu (Pill Shape) ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 16),
                        const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _focusNode,
                            style: GoogleFonts.inter(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Hisse veya şirket adı ara...',
                              hintStyle: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        if (_searchQuery.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _focusNode.unfocus();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // ── 3. Dinamik İçerik (AsyncValue Yükleme, Hata, Veri Durumları) ──
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: asyncStocks.when(
                    loading: () => SearchScreenSkeleton(
                      key: const ValueKey('search_loading_skeleton'),
                      isSearching: isSearching,
                    ),
                    error: (err, stack) => Center(
                      key: const ValueKey('search_error'),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.redAccent.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.cloud_off_rounded,
                                color: Colors.redAccent,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Piyasa Verileri Alınamadı',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sunucuya bağlanırken bir hata oluştu. Lütfen bağlantınızı kontrol edip tekrar deneyin.',
                              style: GoogleFonts.inter(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => ref.invalidate(allMarketStocksProvider),
                              icon: const Icon(Icons.refresh_rounded, size: 18),
                              label: Text(
                                'Tekrar Dene',
                                style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryGreen,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    data: (rawStocks) {
                      if (rawStocks.isEmpty) {
                        return Center(
                          key: const ValueKey('search_empty_data'),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border, width: 0.5),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.analytics_outlined,
                                  color: AppColors.textSecondary,
                                  size: 48,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Henüz Piyasa Verisi Bulunmuyor',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Piyasa verileri güncellendiğinde burada görüntülenecektir.',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton.icon(
                                  onPressed: () => ref.invalidate(allMarketStocksProvider),
                                  icon: const Icon(Icons.refresh_rounded, size: 18),
                                  label: Text(
                                    'Yenile',
                                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2C2C2E),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final mappedStocks = _getMappedStocks(rawStocks);

                      if (isSearching) {
                        return KeyedSubtree(
                          key: const ValueKey('search_list_data'),
                          child: _buildListView(mappedStocks),
                        );
                      }
                      return KeyedSubtree(
                        key: const ValueKey('search_heatmap_data'),
                        child: _buildAdvancedHeatmap(mappedStocks, rawStocks),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Arama ve Filtreleme Sonuçları (Liste Görünümü) ──
  Widget _buildListView(List<HeatmapTileItem> results) {
    if (results.isEmpty || (results.every((s) => s.isEmpty))) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Sonuç bulunamadı',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Başka bir arama yapmayı deneyin',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Yalnızca dolu (empty pad olmayan) hisseleri göster
    final validResults = results.where((s) => !s.isEmpty).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: validResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final stock = validResults[index];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onStockTap(stock.symbol),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border,
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                _buildLogoCircle(symbol: stock.symbol, size: 38),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stock.symbol,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        stock.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${stock.price.toStringAsFixed(2).replaceAll('.', ',')} TL',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    PercentageBadge(
                      percent: stock.changePercent,
                      isGain: stock.isGain,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Colorsheet Paletine Göre Dinamik 4 Kademeli Isı Haritası Rengi ──
  // Artıştan azalışa sıra: #23A983 (%100), #1C8769, #15664F, #0E4434, #333333 (%0), #761805, #9C2007, #D62C0A, #EA300B (-%100)
  static const _heatmapGreenPalette = [
    Color(0xFF0E4434), // %0 - %25   (0'a yakın en koyu yeşil)
    Color(0xFF15664F), // %25 - %50  (koyu yeşil)
    Color(0xFF1C8769), // %50 - %75  (canlı zümrüt)
    Color(0xFF23A983), // %75 - %100 (en yüksek artış, en canlı açık yeşil)
  ];
  static const _heatmapRedPalette = [
    Color(0xFF761805), // %0 - %25   (0'a yakın en koyu bordo)
    Color(0xFF9C2007), // %25 - %50  (koyu kırmızı)
    Color(0xFFD62C0A), // %50 - %75  (canlı kırmızı)
    Color(0xFFEA300B), // %75 - %100 (en yüksek düşüş, en canlı parlak kırmızı)
  ];
  static const _heatmapNeutral = Color(0xFF333333); // %0

  Color _getHeatmapColor({
    required double changePercent,
    required bool isGain,
    required double maxGain,
    required double maxLoss,
  }) {
    if (changePercent == 0) return _heatmapNeutral;

    final absChange = changePercent.abs();
    if (absChange == 0) {
      return const Color(0xFF1E222D);
    }
    if (isGain) {
      final maxVal = maxGain > 0 ? maxGain : 1.0;
      final ratio = (absChange / maxVal).clamp(0.0, 1.0);
      final index = (ratio * 3.99).floor().clamp(0, 3);
      return _heatmapGreenPalette[index];
    } else {
      final maxVal = maxLoss > 0 ? maxLoss : 1.0;
      final ratio = (absChange / maxVal).clamp(0.0, 1.0);
      final index = (ratio * 3.99).floor().clamp(0, 3);
      return _heatmapRedPalette[index];
    }
  }

  // ── Gelişmiş İki Katmanlı Zengin Mozaik Isı Haritası (45 Hisse Treemap) ──
  Widget _buildAdvancedHeatmap(List<HeatmapTileItem> items, List<StockModel> rawStocks) {
    // Dinamik max artış/düşüş hesapla (mutlak değerler)
    final gains = items.where((i) => i.isGain && !i.isEmpty).map((i) => i.changePercent.abs());
    final losses = items.where((i) => !i.isGain && !i.isEmpty).map((i) => i.changePercent.abs());
    final maxGain = gains.isNotEmpty ? gains.reduce((a, b) => a > b ? a : b) : 1.0;
    final maxLoss = losses.isNotEmpty ? losses.reduce((a, b) => a > b ? a : b) : 1.0;

    Widget tile(int index, HeatmapTileSize size) {
      return _buildHeatmapTile(
        stock: items[index],
        slotIndex: index,
        allStocks: rawStocks,
        allGridItems: items,
        size: size,
        maxGain: maxGain,
        maxLoss: maxLoss,
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          // ── 1. ÜST MOZAİK GRUBU (1-22. Hisse — Yükseklik: 520px) ───────────
          SizedBox(
            height: 520,
            child: Row(
              children: [
                // Sol Sütun: 2 Dev Blok (items 0, 1)
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      Expanded(child: tile(0, HeatmapTileSize.large)),
                      const SizedBox(height: 2),
                      Expanded(child: tile(1, HeatmapTileSize.large)),
                    ],
                  ),
                ),
                const SizedBox(width: 2),

                // Sağ Sütun: Çok Katmanlı Izgara
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      // 1. Satır: 2 Orta Blok (items 2, 3)
                      Expanded(
                        flex: 13,
                        child: Row(
                          children: [
                            Expanded(flex: 6, child: tile(2, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(flex: 5, child: tile(3, HeatmapTileSize.medium)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 2. Satır: 3 Orta Blok (items 4, 5, 6)
                      Expanded(
                        flex: 11,
                        child: Row(
                          children: [
                            Expanded(child: tile(4, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(child: tile(5, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(child: tile(6, HeatmapTileSize.medium)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 3. Satır: 3 Orta Blok (items 7, 8, 9)
                      Expanded(
                        flex: 11,
                        child: Row(
                          children: [
                            Expanded(child: tile(7, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(child: tile(8, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(child: tile(9, HeatmapTileSize.medium)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 4. Bölüm (Alt Karma Izgara: Sol dikey 3 blok + Sağ mozaik)
                      Expanded(
                        flex: 20,
                        child: Row(
                          children: [
                            // Sol dikey 3 blok (items 10, 11, 12)
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  Expanded(child: tile(10, HeatmapTileSize.small)),
                                  const SizedBox(height: 2),
                                  Expanded(child: tile(11, HeatmapTileSize.small)),
                                  const SizedBox(height: 2),
                                  Expanded(child: tile(12, HeatmapTileSize.small)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 2),

                            // Sağ Mozaik Izgara (items 13..21)
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  // Üst Küçük Satır (items 13, 14)
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Expanded(child: tile(13, HeatmapTileSize.small)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(14, HeatmapTileSize.small)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Orta Mini Satır (items 15, 16, 17)
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(child: tile(15, HeatmapTileSize.mini)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(16, HeatmapTileSize.mini)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(17, HeatmapTileSize.mini)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Alt Micro Satır (items 18, 19, 20, 21)
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(child: tile(18, HeatmapTileSize.micro)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(19, HeatmapTileSize.micro)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(20, HeatmapTileSize.micro)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(21, HeatmapTileSize.micro)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),

          // ── 2. ALT MOZAİK GRUBU (23-45. Hisse — Yükseklik: 520px) ───────────
          SizedBox(
            height: 520,
            child: Row(
              children: [
                // Sol Sütun: 2 Büyük Blok (items 22, 23)
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      Expanded(child: tile(22, HeatmapTileSize.large)),
                      const SizedBox(height: 2),
                      Expanded(child: tile(23, HeatmapTileSize.large)),
                    ],
                  ),
                ),
                const SizedBox(width: 2),

                // Sağ Sütun: Çok Katmanlı Izgara
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      // 1. Satır: 2 Orta Blok (items 24, 25)
                      Expanded(
                        flex: 13,
                        child: Row(
                          children: [
                            Expanded(flex: 6, child: tile(24, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(flex: 5, child: tile(25, HeatmapTileSize.medium)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 2. Satır: 3 Orta Blok (items 26, 27, 28)
                      Expanded(
                        flex: 11,
                        child: Row(
                          children: [
                            Expanded(child: tile(26, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(child: tile(27, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(child: tile(28, HeatmapTileSize.medium)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 3. Satır: 3 Orta Blok (items 29, 30, 31)
                      Expanded(
                        flex: 11,
                        child: Row(
                          children: [
                            Expanded(child: tile(29, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(child: tile(30, HeatmapTileSize.medium)),
                            const SizedBox(width: 2),
                            Expanded(child: tile(31, HeatmapTileSize.medium)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 4. Bölüm (Alt Karma Izgara: Sol dikey 3 blok + Sağ mozaik)
                      Expanded(
                        flex: 20,
                        child: Row(
                          children: [
                            // Sol dikey 3 blok (items 32, 33, 34)
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  Expanded(child: tile(32, HeatmapTileSize.small)),
                                  const SizedBox(height: 2),
                                  Expanded(child: tile(33, HeatmapTileSize.small)),
                                  const SizedBox(height: 2),
                                  Expanded(child: tile(34, HeatmapTileSize.small)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 2),

                            // Sağ Mozaik Izgara (items 35..44 - 10 hisse)
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  // Üst Küçük Satır (items 35, 36)
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Expanded(child: tile(35, HeatmapTileSize.small)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(36, HeatmapTileSize.small)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Orta Mini Satır (items 37, 38, 39)
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(child: tile(37, HeatmapTileSize.mini)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(38, HeatmapTileSize.mini)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(39, HeatmapTileSize.mini)),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Alt Micro Satır (items 40, 41, 42, 43, 44 - 5 hisse!)
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(child: tile(40, HeatmapTileSize.micro)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(41, HeatmapTileSize.micro)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(42, HeatmapTileSize.micro)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(43, HeatmapTileSize.micro)),
                                        const SizedBox(width: 2),
                                        Expanded(child: tile(44, HeatmapTileSize.micro)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tekil Isı Haritası Bloğu (Heatmap Tile) ────────────────────────
  Widget _buildHeatmapTile({
    required HeatmapTileItem stock,
    required int slotIndex,
    required List<StockModel> allStocks,
    required List<HeatmapTileItem> allGridItems,
    required HeatmapTileSize size,
    double maxGain = 20.0,
    double maxLoss = 20.0,
  }) {
    // Colorsheet paletine göre dinamik 4 kademeli renk
    final tileColor = _getHeatmapColor(
      changePercent: stock.changePercent,
      isGain: stock.isGain,
      maxGain: maxGain,
      maxLoss: maxLoss,
    );

    return Material(
      color: tileColor,
      borderRadius: BorderRadius.zero, // Köşeler yuvarlatılmamış (sharp)
      child: InkWell(
        borderRadius: BorderRadius.zero,
        onTap: () => _onStockTap(stock.symbol),
        onLongPress: () {
          // Filtre etkinken (Artanlar veya Azalanlar) özel kutucuk değişimi engellenir
          if (_selectedFilter != StockFilter.all) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Hisse tercihleri değişikliği için filtre kapatılmalı',
                  style: GoogleFonts.inter(color: Colors.white),
                ),
                backgroundColor: const Color(0xFF1A1A1C),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
                ),
              ),
            );
            return;
          }

          _showChangeStockDialog(
            slotIndex: slotIndex,
            currentStock: stock,
            allStocks: allStocks,
            allGridItems: allGridItems,
          );
        },
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(4),
          alignment: Alignment.center,
          child: _buildTileContent(stock, size),
        ),
      ),
    );
  }

  // ── Heatmap Hisse Değiştirme Bottom Sheet (Görsel Tasarımı ile Aynı) ──
  void _showChangeStockDialog({
    required int slotIndex,
    required HeatmapTileItem currentStock,
    required List<StockModel> allStocks,
    required List<HeatmapTileItem> allGridItems,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (dialogContext) {
        return _ChangeStockBottomSheet(
          currentStock: currentStock,
          allStocks: allStocks,
          onStockSelected: (newStock) {
            _handleStockSelection(
              slotIndex: slotIndex,
              currentStock: currentStock,
              newStock: newStock,
              allGridItems: allGridItems,
            );
          },
        );
      },
    );
  }

  // ── Boyut Kurallarına Göre Blok İçeriği (Görsel Oranları & Tipografi) ─
  Widget _buildTileContent(HeatmapTileItem stock, HeatmapTileSize size) {
    if (stock.isEmpty) {
      return const SizedBox.shrink();
    }
    switch (size) {
      // 1. Büyük Blok (SARAE & ATATR — MSFT / GOOGL Gibi)
      case HeatmapTileSize.large:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoCircle(symbol: stock.symbol, size: 58),
              const SizedBox(height: 10),
              Text(
                stock.symbol,
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${stock.isGain ? '%' : '-%'}${stock.changePercent.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      // 2. Orta Blok (AAGYO, KLNMA, BTCTR, DENIZ, KCHOL, THYAO)
      case HeatmapTileSize.medium:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoCircle(symbol: stock.symbol, size: 34),
              const SizedBox(height: 4),
              Text(
                stock.symbol,
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${stock.isGain ? '%' : '-%'}${stock.changePercent.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      // 3. Küçük Blok (TUPRS, ASELS, BIMAS, GARAN)
      case HeatmapTileSize.small:
        return FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogoCircle(symbol: stock.symbol, size: 28),
              const SizedBox(height: 2),
              Text(
                stock.symbol,
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                '${stock.isGain ? '%' : '-%'}${stock.changePercent.abs().toStringAsFixed(2).replaceAll('.', ',')}',
                maxLines: 1,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );

      // 4. Mini Blok (SISE, SAHOL, PGSUS)
      case HeatmapTileSize.mini:
        return Center(
          child: _buildLogoCircle(symbol: stock.symbol, size: 24),
        );

      // 5. Micro Blok (FROTO, KOZAL, PETKM, AKBNK)
      case HeatmapTileSize.micro:
        return Center(
          child: _buildLogoCircle(symbol: stock.symbol, size: 18),
        );
    }
  }

  // ── Dairesel Marka Logosu (Görseldeki Gibi Renkli & Belirgin) ───────
  Widget _buildLogoCircle({required String symbol, double size = 32}) {
    final Map<String, (Color bg, Color fg, String text)> logoStyles = {
      'SARAE': (const Color(0xFFFFFFFF), const Color(0xFF00B856), 'S'),
      'ATATR': (const Color(0xFFFFFFFF), const Color(0xFFD6301A), 'A'),
      'AAGYO': (const Color(0xFFFFFFFF), const Color(0xFF32ADE6), 'AA'),
      'KLNMA': (const Color(0xFFFFFFFF), const Color(0xFFFF9F0A), 'K'),
      'BTCTR': (const Color(0xFFFFFFFF), const Color(0xFFF7931A), '₿'),
      'YLDZE': (const Color(0xFFFFFFFF), const Color(0xFFFFD60A), '★'),
      'MRKEZ': (const Color(0xFFFFFFFF), const Color(0xFFAF52DE), 'M'),
      'DENIZ': (const Color(0xFFFFFFFF), const Color(0xFF004080), 'D'),
      'KCHOL': (const Color(0xFFFFFFFF), const Color(0xFFC8102E), 'K'),
      'THYAO': (const Color(0xFFC8102E), const Color(0xFFFFFFFF), 'THY'),
      'TUPRS': (const Color(0xFFFFFFFF), const Color(0xFF004B87), 'T'),
      'ASELS': (const Color(0xFFFFFFFF), const Color(0xFF002B49), 'A'),
      'EREGL': (const Color(0xFFFFFFFF), const Color(0xFFE87722), 'E'),
      'BIMAS': (const Color(0xFF002F6C), const Color(0xFFFFFFFF), 'BIM'),
      'GARAN': (const Color(0xFFFFFFFF), const Color(0xFF008542), 'G'),
      'SISE': (const Color(0xFFFFFFFF), const Color(0xFF005596), 'Ş'),
      'SAHOL': (const Color(0xFF003865), const Color(0xFFFFFFFF), 'SA'),
      'PGSUS': (const Color(0xFFFFCC00), const Color(0xFF000000), 'PGS'),
      'FROTO': (const Color(0xFF002C6C), const Color(0xFFFFFFFF), 'F'),
      'KOZAL': (const Color(0xFFFFD700), const Color(0xFF000000), 'K'),
      'PETKM': (const Color(0xFFFFFFFF), const Color(0xFFD62828), 'P'),
      'AKBNK': (const Color(0xFFED1C24), const Color(0xFFFFFFFF), 'AK'),
    };

    final style = logoStyles[symbol] ??
        (
          symbol.isNotEmpty ? const Color(0xFFFFFFFF) : const Color(0xFF2A2A30),
          symbol.isNotEmpty ? const Color(0xFF00B856) : const Color(0xFF8E8E93),
          symbol.isNotEmpty ? symbol.substring(0, 1) : '-'
        );

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.$1,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          style.$3,
          style: GoogleFonts.inter(
            color: style.$2,
            fontSize: style.$3.length > 2
                ? size * 0.35
                : (style.$3.length > 1 ? size * 0.42 : size * 0.52),
            fontWeight: FontWeight.w900,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// Heatmap hisse değiştirme bottom sheet'i (Görseldeki modern iOS tarzı kaydırılabilir sheet)
class _ChangeStockBottomSheet extends StatefulWidget {
  final HeatmapTileItem currentStock;
  final List<StockModel> allStocks;
  final ValueChanged<StockModel> onStockSelected;

  const _ChangeStockBottomSheet({
    required this.currentStock,
    required this.allStocks,
    required this.onStockSelected,
  });

  @override
  State<_ChangeStockBottomSheet> createState() => _ChangeStockBottomSheetState();
}

class _ChangeStockBottomSheetState extends State<_ChangeStockBottomSheet> {
  late final TextEditingController _searchController;
  late final DraggableScrollableController _sheetController;
  String _searchQuery = '';
  bool _isExpanded = false;
  double _dragStartY = 0;
  bool _isSnapping = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _sheetController = DraggableScrollableController();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });

    _sheetController.addListener(() {
      if (!_sheetController.isAttached) return;
      final isExp = _sheetController.size > 0.68;
      if (isExp != _isExpanded) {
        setState(() {
          _isExpanded = isExp;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _sheetController.dispose();
    super.dispose();
  }

  List<StockModel> _getFilteredStocks() {
    if (_searchQuery.isEmpty) {
      return widget.allStocks;
    }
    final q = _searchQuery.toUpperCase();
    return widget.allStocks.where((s) {
      final symMatch = s.symbol.toUpperCase().contains(q);
      final nameMatch = s.companyName.toUpperCase().contains(q);
      return symMatch || nameMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredStocks();

    return NotificationListener<DraggableScrollableNotification>(
      onNotification: (notification) {
        final isExp = notification.extent > 0.68;
        if (isExp != _isExpanded) {
          setState(() {
            _isExpanded = isExp;
          });
        }
        return false;
      },
      child: DraggableScrollableSheet(
        controller: _sheetController,
        initialChildSize: 0.52,
        minChildSize: 0.40,
        maxChildSize: 0.92, // Ekranı tamamen kaplamaz, üstte son kullanıcının sheet'te olduğunu gösteren boşluk kalır
        snap: true,
        snapSizes: const [0.52, 0.92],
        snapAnimationDuration: const Duration(milliseconds: 260),
        expand: false,
        builder: (context, sheetScrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1C),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              border: Border(
                top: BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
                left: BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
                right: BorderSide(color: Color(0xFF2C2C2E), width: 0.5),
              ),
            ),
            child: Column(
              children: [
                // ── Görseldeki Tüm Üst Alan: Tutamaç, Başlık, Alt Başlık, Arama Çubuğu ──
                SingleChildScrollView(
                  controller: sheetScrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    width: double.infinity,
                    color: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Başlık ve Tutamaç Alanı (Hassas Snap Algılayıcı ve Tıkla-Aç Desteği)
                        Listener(
                          behavior: HitTestBehavior.translucent,
                          onPointerDown: (event) {
                            _dragStartY = event.position.dy;
                            _isSnapping = false;
                          },
                          onPointerMove: (event) {
                            if (_isSnapping || !_sheetController.isAttached) return;
                            final delta = event.position.dy - _dragStartY;

                            // Yukarı doğru biraz bile (8px) kaydırılsa anında en üst limite (0.92) fırla
                            if (!_isExpanded && delta < -8) {
                              _isSnapping = true;
                              _sheetController.animateTo(
                                0.92,
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                              );
                            }
                            // En üstteyken aşağı doğru biraz bile (8px) kaydırılsa anında 0.52'ye in
                            else if (_isExpanded && delta > 8) {
                              _isSnapping = true;
                              _sheetController.animateTo(
                                0.52,
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                              );
                            }
                            // Yarım boyuttayken aşağı doğru 25px çekilirse pencereyi kapat
                            else if (!_isExpanded && delta > 25) {
                              _isSnapping = true;
                              Navigator.of(context).pop();
                            }
                          },
                          onPointerUp: (_) => _isSnapping = false,
                          onPointerCancel: (_) => _isSnapping = false,
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              if (!_sheetController.isAttached) return;
                              _sheetController.animateTo(
                                _isExpanded ? 0.52 : 0.92,
                                duration: const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tutamaç çubuğu (Drag indicator)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 6),
                                    child: Container(
                                      width: 38,
                                      height: 4.5,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF3F3F46),
                                        borderRadius: BorderRadius.circular(2.5),
                                      ),
                                    ),
                                  ),
                                ),

                                // ── Üst Başlık & Sağ Üst Çarpı (X) Butonu ──
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(20, 6, 16, 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Ana Başlık Satırı: "Hisseyi Değiştir" ve sağ karşısında aynı seviyedeki "X" butonu
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Hisseyi Değiştir',
                                              style: GoogleFonts.inter(
                                                color: Colors.white,
                                                fontSize: 24, // Büyütüldü (20px -> 24px)
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: -0.5,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Çarpı (X) butonu: Ana başlıkla aynı seviyede hizalı
                                          AnimatedOpacity(
                                            opacity: _isExpanded ? 1.0 : 0.0,
                                            duration: const Duration(milliseconds: 200),
                                            child: IgnorePointer(
                                              ignoring: !_isExpanded,
                                              child: Material(
                                                color: const Color(0xFF242426),
                                                shape: const CircleBorder(),
                                                child: InkWell(
                                                  customBorder: const CircleBorder(),
                                                  onTap: () => Navigator.of(context).pop(),
                                                  child: const Padding(
                                                    padding: EdgeInsets.all(8),
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 3),
                                      // Alt Başlık (Doğrudan ana başlığın altında, X butonunu aşağı çekmez)
                                      Text(
                                        widget.currentStock.isEmpty
                                            ? 'Henüz hisse eklenmedi'
                                            : '${widget.currentStock.symbol} — ${widget.currentStock.companyName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.inter(
                                          color: const Color(0xFF8E8E93),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ── Arama Çubuğu: Yalnızca yukarı kaydırıldığında görünür ──
                        AnimatedCrossFade(
                          firstChild: const SizedBox(width: double.infinity, height: 0),
                          secondChild: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 2, 20, 10),
                            child: Container(
                              height: 46,
                              decoration: BoxDecoration(
                                color: const Color(0xFF111111),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF2C2C2E), width: 0.5),
                              ),
                              child: Row(
                                children: [
                                  const SizedBox(width: 12),
                                  const Icon(
                                    Icons.search_rounded,
                                    color: Color(0xFF8E8E93),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        hintText: 'Hisse veya şirket adı ara...',
                                        hintStyle: GoogleFonts.inter(
                                          color: const Color(0xFF48484A),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.close_rounded, color: Color(0xFF8E8E93), size: 18),
                                      onPressed: () => _searchController.clear(),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          duration: const Duration(milliseconds: 250),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 2),

                // ── Hisseler Listesi (Aşağı yukarı serbestçe kaydırılabilir) ──
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30),
                            child: Text(
                              'Hisse bulunamadı',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF8E8E93),
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          itemCount: filteredList.length,
                          separatorBuilder: (_, _) => const Divider(
                            color: Color(0xFF2C2C2E),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final stock = filteredList[index];

                            return InkWell(
                              borderRadius: BorderRadius.circular(8),
                              onTap: () {
                                // Hisseye tıklandığında işlem gerçekleşir ve pencere kapanır
                                widget.onStockSelected(stock);
                                Navigator.of(context).pop();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                                child: Row(
                                  children: [
                                    // Hisse ikonu / rozeti
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF242426),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: const Color(0xFF333336),
                                          width: 0.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        stock.symbol.isNotEmpty ? stock.symbol[0] : '?',
                                        style: GoogleFonts.inter(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            stock.symbol,
                                            style: GoogleFonts.inter(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            stock.companyName,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: GoogleFonts.inter(
                                              color: const Color(0xFF8E8E93),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${stock.currentPrice.toStringAsFixed(2).replaceAll('.', ',')} TL',
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        PercentageBadge(
                                          percent: stock.changePercent,
                                          isGain: stock.isGain,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Alt güvenli alan (Butonlar silindi, liste alt boşluğu)
                const SafeArea(
                  top: false,
                  child: SizedBox(height: 8),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
