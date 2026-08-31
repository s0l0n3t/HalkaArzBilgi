import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';

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

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim();
      });
    });
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

    // 3. Apply Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toUpperCase();
      list = list.where((stock) {
        final symMatch = stock.symbol.toUpperCase().contains(query);
        final nameMatch = stock.companyName.toUpperCase().contains(query);
        return symMatch || nameMatch;
      }).toList();
    }

    // 4. Pad to exactly 22 items for the hardcoded grid
    // In a real squarified treemap, the layout handles N items.
    // For this specific 22-slot TradingView clone layout:
    while (list.length < 22) {
      list.add(HeatmapTileItem.empty());
    }

    return list;
  }

  void _onStockTap(String symbol) {
    if (symbol.isEmpty) return; // Boş (pad) blok tıklandığında yoksay
    context.push('/ipo/$symbol');
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
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
                      title: 'Tümü',
                      subtitle: 'Tüm hisse senetleri',
                      filter: StockFilter.all,
                      icon: Icons.grid_view_rounded,
                      setSheetState: setSheetState,
                    ),
                    _buildFilterOption(
                      title: 'En Çok Artanlar',
                      subtitle: 'Yükselişteki hisseler',
                      filter: StockFilter.topGainers,
                      icon: Icons.trending_up_rounded,
                      iconColor: AppColors.primaryGreen,
                      setSheetState: setSheetState,
                    ),
                    _buildFilterOption(
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
        Navigator.pop(context);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Top Bar: Geri Butonu (Sol) & Filtre İkonu (Sağ) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
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
            const SizedBox(height: 12),

            // ── 2. Başlık: Hisse Senetleri ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Hisse Senetleri',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 3. Arama Çubuğu (Pill Shape) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
            const SizedBox(height: 24),

            // ── 4. Dinamik İçerik (AsyncValue Yükleme, Hata, Veri Durumları) ──
            Expanded(
              child: AnimatedSwitcher(
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
                    child: Text(
                      'Veriler yüklenirken hata oluştu: $err',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  data: (rawStocks) {
                    final mappedStocks = _getMappedStocks(rawStocks);

                    if (isSearching) {
                      return KeyedSubtree(
                        key: const ValueKey('search_list_data'),
                        child: _buildListView(mappedStocks),
                      );
                    }
                    return KeyedSubtree(
                      key: const ValueKey('search_heatmap_data'),
                      child: _buildAdvancedHeatmap(mappedStocks),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Arama ve Filtreleme Sonuçları (Liste Görünümü) ──
  Widget _buildListView(List<HeatmapTileItem> results) {
    if (results.isEmpty || (results.every((s) => s.isEmpty))) {
      return Center(
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
      );
    }

    // Yalnızca dolu (empty pad olmayan) hisseleri göster
    final validResults = results.where((s) => !s.isEmpty).toList();

    return ListView.separated(
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

  // ── Gelişmiş Mozaik Isı Haritası (TradingView / Görsel 3 Treemap) ──
  Widget _buildAdvancedHeatmap(List<HeatmapTileItem> items) {
    // Dinamik max artış/düşüş hesapla (mutlak değerler)
    final gains = items.where((i) => i.isGain && !i.isEmpty).map((i) => i.changePercent.abs());
    final losses = items.where((i) => !i.isGain && !i.isEmpty).map((i) => i.changePercent.abs());
    final maxGain = gains.isNotEmpty ? gains.reduce((a, b) => a > b ? a : b) : 1.0;
    final maxLoss = losses.isNotEmpty ? losses.reduce((a, b) => a > b ? a : b) : 1.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Column(
        children: [
          // ── ÜST BLOK: Sol Büyük Kareler + Sağ Çok Katmanlı Izgara ──
          SizedBox(
            height: 520,
            child: Row(
              children: [
                // ── SOL SÜTUN (MSFT & GOOGL gibi Dev Bloklar) ─────────
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      // SARAE (+39.92%)
                      Expanded(
                        child: _buildHeatmapTile(
                          stock: items[0],
                          size: HeatmapTileSize.large,
                          maxGain: maxGain,
                          maxLoss: maxLoss,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // ATATR (+34.42%)
                      Expanded(
                        child: _buildHeatmapTile(
                          stock: items[1],
                          size: HeatmapTileSize.large,
                          maxGain: maxGain,
                          maxLoss: maxLoss,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 2),

                // ── SAĞ SÜTUN (Çok Katmanlı Izgara) ───────────────────
                Expanded(
                  flex: 10,
                  child: Column(
                    children: [
                      // 1. Satır: META (+134.23%) & ORCL (+45.33%)
                      Expanded(
                        flex: 13,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 6,
                              child: _buildHeatmapTile(
                                stock: items[2], // AAGYO (+134.23%)
                                size: HeatmapTileSize.medium,
                                maxGain: maxGain,
                                maxLoss: maxLoss,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              flex: 5,
                              child: _buildHeatmapTile(
                                stock: items[3], // KLNMA (+45.33%)
                                size: HeatmapTileSize.medium,
                                maxGain: maxGain,
                                maxLoss: maxLoss,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 2. Satır: ADBE (+44.12%), CSCO (+7.98%), CRM (+57.16%)
                      Expanded(
                        flex: 11,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: items[4], // BTCTR
                                size: HeatmapTileSize.medium,
                                maxGain: maxGain,
                                maxLoss: maxLoss,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: items[5], // YLDZE
                                size: HeatmapTileSize.medium,
                                maxGain: maxGain,
                                maxLoss: maxLoss,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: items[6], // MRKEZ
                                size: HeatmapTileSize.medium,
                                maxGain: maxGain,
                                maxLoss: maxLoss,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 3. Satır: ACN (+15.22%), NFLX (+47.69%), INTU (+15.57%)
                      Expanded(
                        flex: 11,
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: items[7], // DENIZ
                                size: HeatmapTileSize.medium,
                                maxGain: maxGain,
                                maxLoss: maxLoss,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: items[8], // KCHOL
                                size: HeatmapTileSize.medium,
                                maxGain: maxGain,
                                maxLoss: maxLoss,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: items[9], // THYAO
                                size: HeatmapTileSize.medium,
                                maxGain: maxGain,
                                maxLoss: maxLoss,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),

                      // 4. Bölüm (Alt Karma Izgara: Sol dikey 3 blok + Sağ mozaik) ───
                      Expanded(
                        flex: 20,
                        child: Row(
                          children: [
                            // Sol dikey 3 blok: TUPRS (-5.30%), ASELS (+42.51%), EREGL (-9.19%)
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: _buildHeatmapTile(
                                      stock: items[10], // TUPRS
                                      size: HeatmapTileSize.small,
                                      maxGain: maxGain,
                                      maxLoss: maxLoss,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Expanded(
                                    child: _buildHeatmapTile(
                                      stock: items[11], // ASELS
                                      size: HeatmapTileSize.small,
                                      maxGain: maxGain,
                                      maxLoss: maxLoss,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Expanded(
                                    child: _buildHeatmapTile(
                                      stock: items[12], // EREGL
                                      size: HeatmapTileSize.small,
                                      maxGain: maxGain,
                                      maxLoss: maxLoss,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 2),

                            // Sağ Mozaik Izgara (Küçük ve Minik Kareler)
                            Expanded(
                              flex: 6,
                              child: Column(
                                children: [
                                  // Üst Küçük Satır (BIMAS & GARAN)
                                  Expanded(
                                    flex: 3,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[13], // BIMAS (+80.91%)
                                            size: HeatmapTileSize.small,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[14], // GARAN (-4.15%)
                                            size: HeatmapTileSize.small,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Orta Mini Satır (SISE, SAHOL, PGSUS)
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[15], // SISE
                                            size: HeatmapTileSize.mini,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[16], // SAHOL
                                            size: HeatmapTileSize.mini,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[17], // PGSUS
                                            size: HeatmapTileSize.mini,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 2),

                                  // Alt Micro Satır (FROTO, KOZAL, PETKM, AKBNK)
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[18], // FROTO
                                            size: HeatmapTileSize.micro,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[19], // KOZAL
                                            size: HeatmapTileSize.micro,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[20], // PETKM
                                            size: HeatmapTileSize.micro,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: items[21], // AKBNK
                                            size: HeatmapTileSize.micro,
                                            maxGain: maxGain,
                                            maxLoss: maxLoss,
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
          ),
        ],
      ),
    );
  }

  // ── Tekil Isı Haritası Bloğu (Heatmap Tile) ────────────────────────
  Widget _buildHeatmapTile({
    required HeatmapTileItem stock,
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

  // ── Boyut Kurallarına Göre Blok İçeriği (Görsel Oranları & Tipografi) ─
  Widget _buildTileContent(HeatmapTileItem stock, HeatmapTileSize size) {
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
          const Color(0xFFFFFFFF),
          const Color(0xFF00B856),
          symbol.isNotEmpty ? symbol.substring(0, 1) : 'X'
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
