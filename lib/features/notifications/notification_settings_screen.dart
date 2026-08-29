import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:halkaarzbilgi/core/providers/auth_provider.dart';
import 'package:halkaarzbilgi/core/providers/market_provider.dart';
import 'package:halkaarzbilgi/core/providers/notification_settings_provider.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/core/widgets/auth_bottom_sheet.dart';
import 'package:halkaarzbilgi/features/home/models/stock_model.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen>
    with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });

    // Açılışta cihaz sistem bildirim iznini senkronize et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationSettingsProvider.notifier).syncWithSystemPermission();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Ayarlar sayfasından veya arka plandan dönüldüğünde izin durumunu anında güncelle
    if (state == AppLifecycleState.resumed) {
      ref.read(notificationSettingsProvider.notifier).syncWithSystemPermission();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final allStocksAsync = ref.watch(allMarketStocksProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.status == AuthStatus.authenticated;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: Text(
          'Bildirim Ayarları',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: allStocksAsync.when(
        data: (stocks) => _buildBody(context, settings, notifier, stocks, isLoggedIn),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (error, _) => Center(
          child: Text(
            'Hisseler yüklenirken hata oluştu: $error',
            style: GoogleFonts.inter(color: Colors.white70),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    NotificationSettingsState settings,
    NotificationSettingsNotifier notifier,
    List<StockModel> stocks,
    bool isLoggedIn,
  ) {
    final filteredStocks = stocks.where((stock) {
      if (_searchQuery.isEmpty) return true;
      return stock.symbol.toLowerCase().contains(_searchQuery) ||
          stock.companyName.toLowerCase().contains(_searchQuery);
    }).toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Master Switch Card
          _buildMasterSwitchCard(settings, notifier, isLoggedIn),

          // 2. Animated Collapsible Lower Section
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: (settings.masterEnabled && isLoggedIn) ? 1.0 : 0.0,
                curve: Curves.easeInOut,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 350),
                  offset: (settings.masterEnabled && isLoggedIn)
                      ? Offset.zero
                      : const Offset(0, -0.06),
                  curve: Curves.easeInOutCubic,
                  child: (settings.masterEnabled && isLoggedIn)
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 24),

                            // Notification Channels Header
                            Text(
                              'Bilgilendirme',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Categories Card
                            _buildCategoriesCard(settings, notifier),

                            // 3. Animated Collapsible Stock Preferences Section (Tavan bildirimlerine bağlı)
                            ClipRect(
                              child: AnimatedSize(
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOutCubic,
                                alignment: Alignment.topCenter,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: settings.tavanEnabled ? 1.0 : 0.0,
                                  curve: Curves.easeInOut,
                                  child: AnimatedSlide(
                                    duration: const Duration(milliseconds: 350),
                                    offset: settings.tavanEnabled
                                        ? Offset.zero
                                        : const Offset(0, -0.06),
                                    curve: Curves.easeInOutCubic,
                                    child: settings.tavanEnabled
                                        ? Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 24),

                                              // Stock Notifications Header
                                              Text(
                                                'Hisse tercihleri',
                                                style: GoogleFonts.inter(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              const SizedBox(height: 10),

                                              // Search Bar
                                              _buildSearchBar(),
                                              const SizedBox(height: 12),

                                              // Stock Items List
                                              if (filteredStocks.isEmpty)
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          vertical: 40),
                                                  child: Center(
                                                    child: Column(
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .search_off_rounded,
                                                          size: 40,
                                                          color: AppColors
                                                              .textSecondary
                                                              .withValues(
                                                                  alpha: 0.5),
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        Text(
                                                          'Aradığınız hisse bulunamadı',
                                                          style:
                                                              GoogleFonts.inter(
                                                            color: AppColors
                                                                .textSecondary,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              else
                                                ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      filteredStocks.length,
                                                  itemBuilder: (context, index) {
                                                    final stock =
                                                        filteredStocks[index];
                                                    final isFirst = index == 0;
                                                    final isLast = index ==
                                                        filteredStocks.length -
                                                            1;
                                                    final isEnabled = settings
                                                        .enabledStocks
                                                        .contains(stock.symbol);

                                                    return _buildStockItem(
                                                      stock: stock,
                                                      isEnabled: isEnabled,
                                                      isFirst: isFirst,
                                                      isLast: isLast,
                                                      isMasterEnabled: settings
                                                          .masterEnabled,
                                                      onToggle: () => notifier
                                                          .toggleStock(
                                                              stock.symbol),
                                                    );
                                                  },
                                                ),
                                              const SizedBox(height: 32),
                                            ],
                                          )
                                        : const SizedBox(
                                            width: double.infinity),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasterSwitchCard(
    NotificationSettingsState settings,
    NotificationSettingsNotifier notifier,
    bool isLoggedIn,
  ) {
    // Giriş yapmamış kullanıcılar için şalter görsel olarak kapalı.
    final effectiveEnabled = isLoggedIn && settings.masterEnabled;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Anlık bildirimler',
                    style: GoogleFonts.inter(
                      color: effectiveEnabled ? Colors.white : AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Anlık bildirimleri aktif et.',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            CupertinoSwitch(
              value: effectiveEnabled,
              activeTrackColor: const Color(0xFF00A34C),
              onChanged: (_) => _handleMasterSwitchToggle(
                isLoggedIn: isLoggedIn,
                currentlyEnabled: effectiveEnabled,
                notifier: notifier,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tüm Bildirimler şalteri toggle mantığı:
  /// - Giriş yapılmamışsa AuthBottomSheet açılır.
  /// - Kapatılmak istendiğinde doğrudan toggleMaster() çalışır.
  /// - Açılmak istendiğinde önce cihaz bildirim izni kontrol edilir.
  Future<void> _handleMasterSwitchToggle({
    required bool isLoggedIn,
    required bool currentlyEnabled,
    required NotificationSettingsNotifier notifier,
  }) async {
    // 1. Giriş yapmamış kullanıcı
    if (!isLoggedIn) {
      if (!mounted) return;
      AuthBottomSheet.show(context);
      return;
    }

    // 2. Kapatma işlemi — izin kontrolü gereksiz
    if (currentlyEnabled) {
      notifier.toggleMaster();
      return;
    }

    // 3. Açma işlemi — cihaz bildirim iznini kontrol et
    final status = await Permission.notification.status;

    if (status.isGranted) {
      // İzin zaten verilmiş
      notifier.toggleMaster();
      return;
    }

    if (status.isDenied) {
      // İlk kez veya tekrar sorulabilir durumda — yerel sistem diyaloğunu göster
      final result = await Permission.notification.request();
      if (result.isGranted) {
        notifier.toggleMaster();
      } else {
        // Reddedildi — ayarlara yönlendirme diyaloğu göster
        if (!mounted) return;
        _showSettingsRedirectDialog();
      }
      return;
    }

    // 4. Kalıcı olarak reddedilmiş veya kısıtlanmış
    if (!mounted) return;
    _showSettingsRedirectDialog();
  }

  /// Kullanıcıyı cihaz ayarlarına yönlendiren AuthBottomSheet tasarımına sahip bottom sheet.
  void _showSettingsRedirectDialog() {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      isScrollControlled: true,
      builder: (bottomSheetContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle (üst çekme çubuğu)
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Bildirim izinlerini ayarlamalısın',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Hisselerle ilgili bildirim alabilmek için ufak bir düzenlemeye ihtiyaç var',
                    style: GoogleFonts.inter(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Illustration Image (High Quality & Aspect Ratio Preserved)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/permission_second_dialog.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                const SizedBox(height: 24),

                // Primary Button: Ayarlar
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(bottomSheetContext).pop();
                      openAppSettings();
                    },
                    child: Text(
                      'Ayarlar',
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Secondary Button: Vazgeç
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFF2C2C2E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    child: Text(
                      'İptal',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesCard(
    NotificationSettingsState settings,
    NotificationSettingsNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        children: [
          _buildCategoryTile(
            title: 'Tavan bildirimleri',
            subtitle: 'Hisse tercihlerindeki tavan bildirimlerini etkinleştir.',
            value: settings.tavanEnabled,
            enabled: settings.masterEnabled,
            onChanged: notifier.toggleTavan,
            showDivider: true,
          ),
          _buildCategoryTile(
            title: 'Haber ve KAP bildirimleri',
            subtitle: 'Halka arzlar hakkında duyuruları elde et.',
            value: settings.newsEnabled,
            enabled: settings.masterEnabled,
            onChanged: notifier.toggleNews,
            showDivider: true,
          ),
          _buildCategoryTile(
            title: 'Yeni halka arz duyuruları',
            subtitle: 'Yeni onaylanan halka arz duyurularının anlık bildirimi etkinleştir.',
            value: settings.newIposEnabled,
            enabled: settings.masterEnabled,
            onChanged: notifier.toggleNewIpos,
            showDivider: false,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTile({
    required String title,
    required String subtitle,
    required bool value,
    required bool enabled,
    required VoidCallback onChanged,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        color: enabled ? Colors.white : AppColors.textSecondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              CupertinoSwitch(
                value: value && enabled,
                activeTrackColor: const Color(0xFF00A34C),
                onChanged: enabled ? (_) => onChanged() : null,
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 0.5,
            color: AppColors.border,
            indent: 16,
            endIndent: 16,
          ),
      ],
    );
  }


  Widget _buildSearchBar() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Hisse kodu veya şirket adı ara...',
          hintStyle: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStockItem({
    required StockModel stock,
    required bool isEnabled,
    required bool isFirst,
    required bool isLast,
    required bool isMasterEnabled,
    required VoidCallback onToggle,
  }) {
    final active = isMasterEnabled && isEnabled;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(14) : Radius.zero,
          bottom: isLast ? const Radius.circular(14) : Radius.zero,
        ),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: InkWell(
        onTap: isMasterEnabled ? onToggle : null,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(14) : Radius.zero,
          bottom: isLast ? const Radius.circular(14) : Radius.zero,
        ),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  _buildLogoCircle(symbol: stock.symbol, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.symbol,
                          style: GoogleFonts.inter(
                            color: isMasterEnabled ? Colors.white : AppColors.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
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
                  const SizedBox(width: 8),
                  CupertinoSwitch(
                    value: active,
                    activeTrackColor: const Color(0xFF00A34C),
                    onChanged: isMasterEnabled ? (_) => onToggle() : null,
                  ),
                ],
              ),
            ),
            if (!isLast)
              const Divider(
                height: 1,
                thickness: 0.5,
                color: AppColors.border,
                indent: 16,
                endIndent: 16,
              ),
          ],
        ),
      ),
    );
  }

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
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          style.$3,
          style: GoogleFonts.inter(
            color: style.$2,
            fontSize: size * 0.42,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
