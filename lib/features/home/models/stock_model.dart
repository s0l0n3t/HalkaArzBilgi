class StockModel {
  final String id;
  final String symbol;
  final String companyName;
  final double currentPrice;
  final double change;
  final double changePercent;
  final String? logoUrl;
  final int? tavanSeriDays;
  final int? tavanSeriCompleted;

  const StockModel({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    this.logoUrl,
    this.tavanSeriDays,
    this.tavanSeriCompleted,
  });

  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '',
      companyName: json['companyName'] as String? ?? '',
      currentPrice: (json['currentPrice'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercent: (json['changePercent'] as num?)?.toDouble() ?? 0.0,
      logoUrl: json['logoUrl'] as String?,
      tavanSeriDays: json['tavanSeriDays'] as int?,
      tavanSeriCompleted: json['tavanSeriCompleted'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'companyName': companyName,
      'currentPrice': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'logoUrl': logoUrl,
      'tavanSeriDays': tavanSeriDays,
      'tavanSeriCompleted': tavanSeriCompleted,
    };
  }

  bool get isGain => change >= 0;

  static const List<StockModel> mockWatchlist = [
    StockModel(
      id: '1',
      symbol: 'ATATR',
      companyName: 'Ata Turizm İşletmecilik',
      currentPrice: 65.50,
      change: -11.83,
      changePercent: -15.33,
      tavanSeriDays: 8,
      tavanSeriCompleted: 5,
    ),
    StockModel(
      id: '2',
      symbol: 'SARAE',
      companyName: 'Saray Enerji',
      currentPrice: 35.50,
      change: -1.26,
      changePercent: -3.45,
      tavanSeriDays: 6,
      tavanSeriCompleted: 6,
    ),
    StockModel(
      id: '3',
      symbol: 'AAGYO',
      companyName: 'AA Gayrimenkul Yatırım',
      currentPrice: 76.50,
      change: 1.61,
      changePercent: 2.15,
      tavanSeriDays: 7,
      tavanSeriCompleted: 3,
    ),
    StockModel(
      id: '4',
      symbol: 'KLNMA',
      companyName: 'Kalınma Holding',
      currentPrice: 22.80,
      change: 1.83,
      changePercent: 8.72,
      tavanSeriDays: 0,
      tavanSeriCompleted: 0,
    ),
    StockModel(
      id: '5',
      symbol: 'BTCTR',
      companyName: 'Bitay Kripto Teknoloji',
      currentPrice: 48.00,
      change: -6.06,
      changePercent: -11.20,
      tavanSeriDays: 5,
      tavanSeriCompleted: 2,
    ),
    StockModel(
      id: '6',
      symbol: 'YLDZE',
      companyName: 'Yıldız Enerji A.Ş.',
      currentPrice: 17.40,
      change: 0.90,
      changePercent: 5.44,
      tavanSeriDays: 4,
      tavanSeriCompleted: 4,
    ),
    StockModel(
      id: '7',
      symbol: 'MRKEZ',
      companyName: 'Merkez Yapı Endüstri',
      currentPrice: 9.60,
      change: -0.64,
      changePercent: -6.25,
      tavanSeriDays: 0,
      tavanSeriCompleted: 0,
    ),
    StockModel(
      id: '8',
      symbol: 'DENIZ',
      companyName: 'Deniz Lojistik Hizmetleri',
      currentPrice: 31.20,
      change: 3.47,
      changePercent: 12.50,
      tavanSeriDays: 6,
      tavanSeriCompleted: 4,
    ),
    StockModel(
      id: '9',
      symbol: 'THYAO',
      companyName: 'Türk Hava Yolları A.O.',
      currentPrice: 294.50,
      change: 8.00,
      changePercent: 2.79,
    ),
    StockModel(
      id: '10',
      symbol: 'ASELS',
      companyName: 'Aselsan Elektronik Sanayi',
      currentPrice: 62.10,
      change: 0.90,
      changePercent: 1.47,
    ),
    StockModel(
      id: '11',
      symbol: 'TUPRS',
      companyName: 'Türkiye Petrol Rafinerileri (Tüpraş)',
      currentPrice: 172.30,
      change: -1.40,
      changePercent: -0.81,
    ),
    StockModel(
      id: '12',
      symbol: 'EREGL',
      companyName: 'Ereğli Demir ve Çelik Fabrikaları',
      currentPrice: 51.40,
      change: 0.25,
      changePercent: 0.49,
    ),
    StockModel(
      id: '13',
      symbol: 'KCHOL',
      companyName: 'Koç Holding A.Ş.',
      currentPrice: 215.00,
      change: 4.10,
      changePercent: 1.94,
    ),
    StockModel(
      id: '14',
      symbol: 'BIMAS',
      companyName: 'BİM Birleşik Mağazalar',
      currentPrice: 485.00,
      change: -5.50,
      changePercent: -1.12,
    ),
    StockModel(
      id: '15',
      symbol: 'SISE',
      companyName: 'Türkiye Şişe ve Cam Fabrikaları',
      currentPrice: 48.90,
      change: 0.44,
      changePercent: 0.91,
    ),
    StockModel(
      id: '16',
      symbol: 'SAHOL',
      companyName: 'Hacı Ömer Sabancı Holding',
      currentPrice: 94.20,
      change: 1.95,
      changePercent: 2.11,
    ),
    StockModel(
      id: '17',
      symbol: 'GARAN',
      companyName: 'Türkiye Garanti Bankası',
      currentPrice: 118.50,
      change: -0.50,
      changePercent: -0.42,
    ),
    StockModel(
      id: '18',
      symbol: 'FROTO',
      companyName: 'Ford Otomotiv Sanayi',
      currentPrice: 1045.00,
      change: 32.00,
      changePercent: 3.16,
    ),
  ];
}
