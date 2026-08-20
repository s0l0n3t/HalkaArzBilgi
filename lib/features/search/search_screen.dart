import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';

enum HeatmapTileSize { large, medium, small, mini, micro }

enum StockFilter { all, topGainers, topLosers }

class HeatmapTileItem {
  final String symbol;
  final String companyName;
  final double changePercent;
  final HeatmapTileSize size;
  final bool isGain;
  final double price;

  const HeatmapTileItem({
    required this.symbol,
    required this.companyName,
    required this.changePercent,
    required this.size,
    required this.isGain,
    required this.price,
  });
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _searchQuery = '';
  StockFilter _selectedFilter = StockFilter.all;

  // Tüm hisselerin veri havuzu
  static const List<HeatmapTileItem> _allStocks = [
    HeatmapTileItem(
      symbol: 'SARAE',
      companyName: 'Saray Enerji',
      changePercent: 39.92,
      size: HeatmapTileSize.large,
      isGain: true,
      price: 35.50,
    ),
    HeatmapTileItem(
      symbol: 'ATATR',
      companyName: 'Ata Turizm İşletmecilik',
      changePercent: 34.42,
      size: HeatmapTileSize.large,
      isGain: true,
      price: 65.50,
    ),
    HeatmapTileItem(
      symbol: 'AAGYO',
      companyName: 'AA Gayrimenkul Yatırım',
      changePercent: 134.23,
      size: HeatmapTileSize.medium,
      isGain: true,
      price: 76.50,
    ),
    HeatmapTileItem(
      symbol: 'KLNMA',
      companyName: 'Kalınma Holding',
      changePercent: 45.33,
      size: HeatmapTileSize.medium,
      isGain: true,
      price: 22.80,
    ),
    HeatmapTileItem(
      symbol: 'BTCTR',
      companyName: 'Bitay Kripto Teknoloji',
      changePercent: 44.12,
      size: HeatmapTileSize.medium,
      isGain: true,
      price: 48.00,
    ),
    HeatmapTileItem(
      symbol: 'YLDZE',
      companyName: 'Yıldız Enerji A.Ş.',
      changePercent: 7.98,
      size: HeatmapTileSize.medium,
      isGain: true,
      price: 17.40,
    ),
    HeatmapTileItem(
      symbol: 'MRKEZ',
      companyName: 'Merkez Yapı Endüstri',
      changePercent: 57.16,
      size: HeatmapTileSize.medium,
      isGain: true,
      price: 9.60,
    ),
    HeatmapTileItem(
      symbol: 'DENIZ',
      companyName: 'Deniz Lojistik Hizmetleri',
      changePercent: 15.22,
      size: HeatmapTileSize.medium,
      isGain: true,
      price: 31.20,
    ),
    HeatmapTileItem(
      symbol: 'KCHOL',
      companyName: 'Koç Holding',
      changePercent: 47.69,
      size: HeatmapTileSize.medium,
      isGain: true,
      price: 185.20,
    ),
    HeatmapTileItem(
      symbol: 'THYAO',
      companyName: 'Türk Hava Yolları',
      changePercent: 15.57,
      size: HeatmapTileSize.medium,
      isGain: true,
      price: 298.50,
    ),
    HeatmapTileItem(
      symbol: 'TUPRS',
      companyName: 'Tüpraş',
      changePercent: -5.30,
      size: HeatmapTileSize.small,
      isGain: false,
      price: 164.70,
    ),
    HeatmapTileItem(
      symbol: 'ASELS',
      companyName: 'Aselsan',
      changePercent: 42.51,
      size: HeatmapTileSize.small,
      isGain: true,
      price: 62.40,
    ),
    HeatmapTileItem(
      symbol: 'EREGL',
      companyName: 'Ereğli Demir Çelik',
      changePercent: -9.19,
      size: HeatmapTileSize.small,
      isGain: false,
      price: 49.30,
    ),
    HeatmapTileItem(
      symbol: 'BIMAS',
      companyName: 'BİM Mağazalar',
      changePercent: 80.91,
      size: HeatmapTileSize.small,
      isGain: true,
      price: 480.00,
    ),
    HeatmapTileItem(
      symbol: 'GARAN',
      companyName: 'Garanti BBVA',
      changePercent: -4.15,
      size: HeatmapTileSize.small,
      isGain: false,
      price: 112.40,
    ),
    HeatmapTileItem(
      symbol: 'SISE',
      companyName: 'Şişecam',
      changePercent: 12.30,
      size: HeatmapTileSize.mini,
      isGain: true,
      price: 46.80,
    ),
    HeatmapTileItem(
      symbol: 'SAHOL',
      companyName: 'Sabancı Holding',
      changePercent: -2.80,
      size: HeatmapTileSize.mini,
      isGain: false,
      price: 84.10,
    ),
    HeatmapTileItem(
      symbol: 'PGSUS',
      companyName: 'Pegasus Hava Taşımacılığı',
      changePercent: 18.40,
      size: HeatmapTileSize.mini,
      isGain: true,
      price: 232.00,
    ),
    HeatmapTileItem(
      symbol: 'FROTO',
      companyName: 'Ford Otosan',
      changePercent: -6.50,
      size: HeatmapTileSize.mini,
      isGain: false,
      price: 1045.00,
    ),
    HeatmapTileItem(
      symbol: 'KOZAL',
      companyName: 'Koza Altın',
      changePercent: 6.20,
      size: HeatmapTileSize.mini,
      isGain: true,
      price: 21.60,
    ),
    HeatmapTileItem(
      symbol: 'PETKM',
      companyName: 'Petkim Petrokimya',
      changePercent: -3.75,
      size: HeatmapTileSize.micro,
      isGain: false,
      price: 19.85,
    ),
    HeatmapTileItem(
      symbol: 'AKBNK',
      companyName: 'Akbank',
      changePercent: 8.90,
      size: HeatmapTileSize.micro,
      isGain: true,
      price: 53.20,
    ),
  ];

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

  List<HeatmapTileItem> get _filteredStocks {
    var list = List<HeatmapTileItem>.from(_allStocks);

    // Apply Filter
    if (_selectedFilter == StockFilter.topGainers) {
      list = list.where((s) => s.isGain).toList()
        ..sort((a, b) => b.changePercent.compareTo(a.changePercent));
    } else if (_selectedFilter == StockFilter.topLosers) {
      list = list.where((s) => !s.isGain).toList()
        ..sort((a, b) => a.changePercent.compareTo(b.changePercent));
    }

    // Apply Search Query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toUpperCase();
      list = list.where((stock) {
        final symMatch = stock.symbol.toUpperCase().contains(query);
        final nameMatch = stock.companyName.toUpperCase().contains(query);
        return symMatch || nameMatch;
      }).toList();
    }

    return list;
  }

  void _onStockTap(String symbol) {
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
    final isSearching = _searchQuery.isNotEmpty;

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

            // ── 2. Başlık: Sola Yaslı Büyük "Hisse Senetleri" ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
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
            const SizedBox(height: 12),

            // ── 3. Arama Kutusu (Pill Search Bar - Ferah Boşluklar) ────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _focusNode.hasFocus
                        ? AppColors.primaryGreen
                        : AppColors.border,
                    width: 0.8,
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  focusNode: _focusNode,
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  cursorColor: AppColors.primaryGreen,
                  decoration: InputDecoration(
                    hintText: 'SARAE.IS veya şirket ara...',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 15,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 18,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── 3. İçerik Alanı: Autocomplete Listesi VEYA Mozaik Isı Haritası ──
            Expanded(
              child: isSearching
                  ? _buildAutocompleteResults()
                  : _buildAdvancedHeatmap(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Otomatik Tamamlama (Autocomplete) Öneri Listesi ────────────────
  Widget _buildAutocompleteResults() {
    final results = _filteredStocks;

    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                color: AppColors.textSecondary,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                '"$_searchQuery" için sonuç bulunamadı',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Farklı bir hisse kodu veya şirket adı deneyin.',
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

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: results.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final stock = results[index];
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

  // ── Gelişmiş Mozaik Isı Haritası (TradingView / Görsel 3 Treemap) ──
  Widget _buildAdvancedHeatmap() {
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
                          stock: _allStocks[0],
                          size: HeatmapTileSize.large,
                        ),
                      ),
                      const SizedBox(height: 2),
                      // ATATR (+34.42%)
                      Expanded(
                        child: _buildHeatmapTile(
                          stock: _allStocks[1],
                          size: HeatmapTileSize.large,
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
                                stock: _allStocks[2], // AAGYO (+134.23%)
                                size: HeatmapTileSize.medium,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              flex: 5,
                              child: _buildHeatmapTile(
                                stock: _allStocks[3], // KLNMA (+45.33%)
                                size: HeatmapTileSize.medium,
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
                                stock: _allStocks[4], // BTCTR
                                size: HeatmapTileSize.medium,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: _allStocks[5], // YLDZE
                                size: HeatmapTileSize.medium,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: _allStocks[6], // MRKEZ
                                size: HeatmapTileSize.medium,
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
                                stock: _allStocks[7], // DENIZ
                                size: HeatmapTileSize.medium,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: _allStocks[8], // KCHOL
                                size: HeatmapTileSize.medium,
                              ),
                            ),
                            const SizedBox(width: 2),
                            Expanded(
                              child: _buildHeatmapTile(
                                stock: _allStocks[9], // THYAO
                                size: HeatmapTileSize.medium,
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
                                      stock: _allStocks[10], // TUPRS
                                      size: HeatmapTileSize.small,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Expanded(
                                    child: _buildHeatmapTile(
                                      stock: _allStocks[11], // ASELS
                                      size: HeatmapTileSize.small,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Expanded(
                                    child: _buildHeatmapTile(
                                      stock: _allStocks[12], // EREGL
                                      size: HeatmapTileSize.small,
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
                                            stock: _allStocks[13], // BIMAS (+80.91%)
                                            size: HeatmapTileSize.small,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: _allStocks[14], // GARAN (-4.15%)
                                            size: HeatmapTileSize.small,
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
                                            stock: _allStocks[15], // SISE
                                            size: HeatmapTileSize.mini,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: _allStocks[16], // SAHOL
                                            size: HeatmapTileSize.mini,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: _allStocks[17], // PGSUS
                                            size: HeatmapTileSize.mini,
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
                                            stock: _allStocks[18], // FROTO
                                            size: HeatmapTileSize.micro,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: _allStocks[19], // KOZAL
                                            size: HeatmapTileSize.micro,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: _allStocks[20], // PETKM
                                            size: HeatmapTileSize.micro,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Expanded(
                                          child: _buildHeatmapTile(
                                            stock: _allStocks[21], // AKBNK
                                            size: HeatmapTileSize.micro,
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
  }) {
    // Görseldeki Canlı Yeşil ve Canlı Kırmızı
    final tileColor = stock.isGain
        ? const Color(0xFF1E9E6D) // Vibrant Green
        : const Color(0xFFE02A1D); // Vibrant Red

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
                '${stock.isGain ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
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
                '${stock.isGain ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
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
                '${stock.isGain ? '+' : ''}${stock.changePercent.toStringAsFixed(2)}%',
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
