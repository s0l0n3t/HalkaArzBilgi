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
      tavanSeriDays: 3,
      tavanSeriCompleted: 2,
    ),
    StockModel(
      id: '2',
      symbol: 'SARAE',
      companyName: 'Saray Enerji',
      currentPrice: 35.50,
      change: -1.26,
      changePercent: -3.45,
      tavanSeriDays: 5,
      tavanSeriCompleted: 5,
    ),
    StockModel(
      id: '3',
      symbol: 'AAGYO',
      companyName: 'AA Gayrimenkul Yatırım',
      currentPrice: 76.50,
      change: 1.61,
      changePercent: 2.15,
      tavanSeriDays: 4,
      tavanSeriCompleted: 3,
    ),
    StockModel(
      id: '4',
      symbol: 'KLNMA',
      companyName: 'Kalınma Holding',
      currentPrice: 22.80,
      change: 1.83,
      changePercent: 8.72,
      tavanSeriDays: 7,
      tavanSeriCompleted: 7,
    ),
    StockModel(
      id: '5',
      symbol: 'BTCTR',
      companyName: 'Bitay Kripto Teknoloji',
      currentPrice: 48.00,
      change: -6.06,
      changePercent: -11.20,
      tavanSeriDays: 0,
      tavanSeriCompleted: 0,
    ),
    StockModel(
      id: '6',
      symbol: 'YLDZE',
      companyName: 'Yıldız Enerji A.Ş.',
      currentPrice: 17.40,
      change: 0.90,
      changePercent: 5.44,
      tavanSeriDays: 3,
      tavanSeriCompleted: 1,
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
  ];
}
