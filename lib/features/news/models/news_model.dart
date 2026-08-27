enum NewsCategory {
  all(title: 'Tümü'),
  ipo(title: 'Halka Arz'),
  kap(title: 'KAP Bildirimi'),
  bist(title: 'BIST 100'),
  company(title: 'Şirket Haberleri');

  final String title;
  const NewsCategory({required this.title});
}

class NewsModel {
  final String id;
  final String title;
  final String summary;
  final String source;
  final NewsCategory category;
  final String timeAgo;
  final String? symbol;
  final String? imageUrl;
  final String? url;
  final bool isBreaking;

  const NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.source,
    required this.category,
    required this.timeAgo,
    this.symbol,
    this.imageUrl,
    this.url,
    this.isBreaking = false,
  });

  /// Arama çubuğu placeholder'ı için popüler hisse sembol listesi.
  static const List<String> popularSymbols = [
    'SARAE', 'TKNKA', 'THYAO', 'AAGYO', 'ATATR',
    'BTCTR', 'ASELS', 'EREGL', 'GARAN', 'KCHOL',
    'TUPRS', 'BIMAS', 'FROTO', 'KOZAL',
  ];

  /// Haberlerdeki hisse etiketleri (# çipleri) için benzersiz sembol listesi.
  static List<String> get newsSymbols {
    final symbols = <String>{};
    for (final news in mockNews) {
      if (news.symbol != null) symbols.add(news.symbol!);
    }
    return symbols.toList();
  }

  static const List<NewsModel> mockNews = [
    NewsModel(
      id: 'news_1',
      title: 'SARAE Halka arzı SPK tarafından onaylandı: Talep toplama tarihleri belli oldu',
      summary: 'Saray Holding bünyesindeki SARAE halka arzı için konsorsiyum lideri belirlendi. Talep toplama 3 iş günü sürecek.',
      source: 'KAP',
      category: NewsCategory.ipo,
      timeAgo: '15 dk önce',
      symbol: 'SARAE',
      isBreaking: true,
    ),
    NewsModel(
      id: 'news_2',
      title: 'TKNKA Halka arzı SPK tarafından onaylandı: Talep toplama tarihleri belli oldu',
      summary: 'Teknika Mühendislik halka arz işlemleri için talep toplama süreci önümüzdeki hafta başlayacak.',
      source: 'KAP',
      category: NewsCategory.ipo,
      timeAgo: '15 dk önce',
      symbol: 'TKNKA',
    ),
    NewsModel(
      id: 'news_3',
      title: 'SARAE Halka arzı SPK tarafından onaylandı: Talep toplama tarihleri belli oldu',
      summary: 'Saray Holding halka arz sürecinde güncelleme: Fiyat aralığı ve talep tarihlerinde netleşme sağlandı.',
      source: 'Foreks',
      category: NewsCategory.ipo,
      timeAgo: '42 dk önce',
      symbol: 'SARAE',
    ),
    NewsModel(
      id: 'news_4',
      title: 'AAGYO Gayrimenkul portföyüne 1.2 milyar TL değerinde yeni lojistik merkezi ekledi',
      summary: 'Şirketten yapılan açıklamada yeni merkezin yıllık kira getirisinin ciroya %18 katkı sağlaması beklendiği belirtildi.',
      source: 'Matriks',
      category: NewsCategory.company,
      timeAgo: '42 dk önce',
      symbol: 'AAGYO',
    ),
    NewsModel(
      id: 'news_5',
      title: 'BIST 100 Endeksi güne %1.42 yükselişle rekor seviyeden başladı',
      summary: 'Bankacılık ve teknoloji hisseleri öncülüğünde Borsa İstanbul 10.850 puan seviyesini test ediyor.',
      source: 'Foreks',
      category: NewsCategory.bist,
      timeAgo: '1 saat önce',
    ),
    NewsModel(
      id: 'news_6',
      title: 'ATATR yeni GES yatırımı için ÇED olumlu raporu aldığını duyurdu',
      summary: 'Güneş enerjisi santrali projesinin 2026 yılı 3. çeyreğinde tam kapasiteyle devreye alınması hedefleniyor.',
      source: 'KAP',
      category: NewsCategory.kap,
      timeAgo: '2 saat önce',
      symbol: 'ATATR',
    ),
    NewsModel(
      id: 'news_7',
      title: 'BTCTR sermaye artırımı ve bedelsiz pay dağıtımı kararı aldı',
      summary: 'Şirket yönetim kurulu %200 oranında iç kaynaklardan bedelsiz sermaye artırımı başvurusunu SPK\'ya iletti.',
      source: 'KAP',
      category: NewsCategory.kap,
      timeAgo: '3 saat önce',
      symbol: 'BTCTR',
    ),
    NewsModel(
      id: 'news_8',
      title: 'SPK Bülteni yayınlandı: 2 yeni şirketin halka arzına onay çıktı',
      summary: 'Sermaye Piyasası Kurulu haftalık bülteninde iki teknoloji ve enerji şirketinin halka arz taslağını onayladı.',
      source: 'SPK',
      category: NewsCategory.ipo,
      timeAgo: '5 saat önce',
      isBreaking: true,
    ),
    NewsModel(
      id: 'news_9',
      title: 'THYAO filosuna 10 yeni nesil geniş gövdeli uçak katılacağını açıkladı',
      summary: 'Türk Hava Yolları, 2033 büyüme stratejisi kapsamında teslimat takvimini revize ettiğini bildirdi.',
      source: 'Bloomberg HT',
      category: NewsCategory.company,
      timeAgo: '6 saat önce',
      symbol: 'THYAO',
    ),
    NewsModel(
      id: 'news_10',
      title: 'Merkez Bankası faiz kararı sonrası piyasalarda ilk tepkiler ve analizler',
      summary: 'Para Politikası Kurulu toplantı özeti açıklandı. Borsa ve döviz piyasalarında volatilite azaldı.',
      source: 'Ekonomi Gazetesi',
      category: NewsCategory.bist,
      timeAgo: '8 saat önce',
    ),
  ];
}
