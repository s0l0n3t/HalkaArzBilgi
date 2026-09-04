import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/features/news/models/news_model.dart';

/// Okuma metin boyutu seçenekleri
enum NewsFontSize {
  small(
    label: 'Küçük',
    headlineSize: 19.0,
    summarySize: 13.5,
    bodySize: 14.0,
    lineHeight: 1.6,
  ),
  standard(
    label: 'Standart',
    headlineSize: 22.0,
    summarySize: 14.5,
    bodySize: 15.5,
    lineHeight: 1.65,
  ),
  large(
    label: 'Büyük',
    headlineSize: 25.0,
    summarySize: 16.0,
    bodySize: 17.5,
    lineHeight: 1.7,
  );

  final String label;
  final double headlineSize;
  final double summarySize;
  final double bodySize;
  final double lineHeight;

  const NewsFontSize({
    required this.label,
    required this.headlineSize,
    required this.summarySize,
    required this.bodySize,
    required this.lineHeight,
  });
}

class NewsDetailScreen extends StatefulWidget {
  final String id;
  final NewsModel? news;

  const NewsDetailScreen({
    super.key,
    required this.id,
    this.news,
  });

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  NewsFontSize _selectedFontSize = NewsFontSize.standard;
  late final NewsModel? _news;

  @override
  void initState() {
    super.initState();
    _news = widget.news ?? NewsModel.findById(widget.id);
  }

  void _showFontSizeBottomSheet() {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tutamaç (Drag Handle)
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Başlık
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Yazı Boyutu',
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _selectedFontSize.label,
                          style: GoogleFonts.inter(
                            color: AppColors.primaryGreen,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Seçenek Butonları
                    Row(
                      children: NewsFontSize.values.map((sizeOption) {
                        final isSelected = sizeOption == _selectedFontSize;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Material(
                              color: isSelected
                                  ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                  : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setModalState(() {
                                    _selectedFontSize = sizeOption;
                                  });
                                  setState(() {
                                    _selectedFontSize = sizeOption;
                                  });
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : AppColors.border,
                                      width: isSelected ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        'Aa',
                                        style: GoogleFonts.inter(
                                          color: isSelected
                                              ? AppColors.primaryGreen
                                              : Colors.white70,
                                          fontSize: sizeOption == NewsFontSize.small
                                              ? 14
                                              : sizeOption == NewsFontSize.standard
                                                  ? 17
                                                  : 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        sizeOption.label,
                                        style: GoogleFonts.inter(
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.textSecondary,
                                          fontSize: 12,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _shareNews(NewsModel news) {
    HapticFeedback.lightImpact();
    final buffer = StringBuffer();
    buffer.writeln(news.title);
    buffer.writeln();
    buffer.writeln(news.summary);
    if (news.url != null && news.url!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln('Haber Bağlantısı: ${news.url}');
    }
    Share.share(
      buffer.toString().trim(),
      subject: news.title,
    );
  }

  Future<void> _launchSourceUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final canLaunch = await canLaunchUrl(uri);
      if (canLaunch) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bağlantı açılamadı: $url',
            style: GoogleFonts.inter(color: Colors.white),
          ),
          backgroundColor: AppColors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final news = _news;

    if (news == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Haber Bulunamadı',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.newspaper_rounded,
                  color: AppColors.textSecondary, size: 48),
              const SizedBox(height: 16),
              Text(
                'Aradığınız haber yayından kaldırılmış olabilir.',
                style: GoogleFonts.inter(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    final paragraphs = news.fullContent
        .split('\n\n')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          tooltip: 'Geri',
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Haber Detayı',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded,
                color: Colors.white, size: 21),
            tooltip: 'Haberi Paylaş',
            onPressed: () => _shareNews(news),
          ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded,
                color: Colors.white, size: 22),
            tooltip: 'Yazı Boyutu',
            onPressed: _showFontSizeBottomSheet,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Üst Meta Bilgisi: Kaynak • Zaman ve Varsa #Sembol Çipi
            _buildMetaHeader(news),
            const SizedBox(height: 14),

            // 2. Büyük Manşet Başlığı
            Text(
              news.title,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: _selectedFontSize.headlineSize,
                fontWeight: FontWeight.bold,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // 3. Vurgulu 'Haber Özeti' Kartı
            _buildSummaryBox(news),
            const SizedBox(height: 12),

            // 4. 'Yapay Zeka Yorumu' Kartı (Haber özetiyle aynı minimal tasarımda)
            _buildAiCommentBox(news),
            const SizedBox(height: 20),

            // 5. Paragraflar Halinde Detaylı Haber Metni
            ...paragraphs.map((para) => Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    para,
                    style: GoogleFonts.inter(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontSize: _selectedFontSize.bodySize,
                      height: _selectedFontSize.lineHeight,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                )),

            const SizedBox(height: 8),

            // 6. Varsa İlgili Hisse Kartı
            if (news.symbol != null) ...[
              _buildRelatedStockCard(news.symbol!),
              const SizedBox(height: 20),
            ],

            // 7. Orijinal Kaynak Bağlantı Butonu
            if (news.url != null && news.url!.isNotEmpty) ...[
              _buildSourceButton(news),
              const SizedBox(height: 24),
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Üst meta başlığı: Kaynak • Zaman ve Varsa #Sembol Çipi
  Widget _buildMetaHeader(NewsModel news) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Kaynak ve Zaman
        Text(
          '${news.source} • ${news.timeAgo}',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),

        const Spacer(),

        // Varsa #Sembol Çipi (Tıklanabilir)
        if (news.symbol != null)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                context.push('/ipo/${news.symbol}');
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '#',
                      style: GoogleFonts.inter(
                        color: AppColors.primaryGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      news.symbol!,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: AppColors.primaryGreen,
                      size: 10,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Vurgulu 'Haber Özeti' Kartı
  Widget _buildSummaryBox(NewsModel news) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Haber Özeti',
                style: GoogleFonts.inter(
                  color: AppColors.primaryGreen,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            news.summary,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: _selectedFontSize.summarySize,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Yapay Zeka Yorumu Kartı (Haber özeti kartıyla birebir aynı minimal tasarımda)
  Widget _buildAiCommentBox(NewsModel news) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Yapay Zeka Yorumu',
                style: GoogleFonts.inter(
                  color: AppColors.primaryGreen,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            news.aiComment,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.95),
              fontSize: _selectedFontSize.summarySize,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Asla bir yatırım tavsiyesi değildir. Bilgi vermeyi amaçlamaktadır.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary.withValues(alpha: 0.8),
              fontSize: 11,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  /// İlgili Hisse Kartı (Tıklanınca /ipo/${symbol} sayfasına yönlendirir)
  Widget _buildRelatedStockCard(String symbol) {
    final ipo = IpoModel.findBySymbol(symbol);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          context.push('/ipo/$symbol');
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Hisse Sembol Avatarı
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  symbol.length >= 2 ? symbol.substring(0, 2) : symbol,
                  style: GoogleFonts.inter(
                    color: AppColors.primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Sembol ve Şirket Adı
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      symbol,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ipo.companyName,
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

              // Yönlendirme İpucu
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hisseye Git',
                    style: GoogleFonts.inter(
                      color: AppColors.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: AppColors.primaryGreen,
                    size: 12,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Orijinal Kaynak Bağlantı Butonu
  Widget _buildSourceButton(NewsModel news) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _launchSourceUrl(news.url!),
        icon: const Icon(
          Icons.open_in_new_rounded,
          size: 16,
          color: Colors.white,
        ),
        label: Text(
          'Kaynağı Görüntüle (${news.source})',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
