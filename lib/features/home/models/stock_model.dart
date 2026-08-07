class StockModel {
  final String id;
  final String symbol;
  final String companyName;
  final int lots;
  final double costPrice;
  final double currentPrice;
  final double change;
  final double changePercent;
  final String? logoUrl;

  const StockModel({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.lots,
    required this.costPrice,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    this.logoUrl,
  });

  bool get isGain => change >= 0;

  static const List<StockModel> mockWatchlist = [
    StockModel(
      id: '1',
      symbol: 'ATATR',
      companyName: 'Ata Turizm İşletmecilik',
      lots: 65,
      costPrice: 3560.57,
      currentPrice: 65.50,
      change: -355.56,
      changePercent: -15.33,
    ),
    StockModel(
      id: '2',
      symbol: 'SARAE',
      companyName: 'Saray Enerji',
      lots: 35,
      costPrice: 2660.67,
      currentPrice: 35.50,
      change: -95.20,
      changePercent: -3.45,
    ),
    StockModel(
      id: '3',
      symbol: 'AAGYO',
      companyName: 'AA Gayrimenkul Yatırım',
      lots: 65,
      costPrice: 1350.75,
      currentPrice: 76.50,
      change: 124.80,
      changePercent: 2.15,
    ),
    StockModel(
      id: '4',
      symbol: 'KLNMA',
      companyName: 'Kalınma Holding',
      lots: 120,
      costPrice: 4890.40,
      currentPrice: 22.80,
      change: 456.00,
      changePercent: 8.72,
    ),
    StockModel(
      id: '5',
      symbol: 'BTCTR',
      companyName: 'Bitay Kripto Teknoloji',
      lots: 20,
      costPrice: 1680.00,
      currentPrice: 48.00,
      change: -210.40,
      changePercent: -11.20,
    ),
    StockModel(
      id: '6',
      symbol: 'YLDZE',
      companyName: 'Yıldız Enerji A.Ş.',
      lots: 50,
      costPrice: 3200.50,
      currentPrice: 17.40,
      change: 33.18,
      changePercent: 5.44,
    ),
    StockModel(
      id: '7',
      symbol: 'MRKEZ',
      companyName: 'Merkez Yapı Endüstri',
      lots: 80,
      costPrice: 2100.30,
      currentPrice: 9.60,
      change: -144.00,
      changePercent: -6.25,
    ),
    StockModel(
      id: '8',
      symbol: 'DENIZ',
      companyName: 'Deniz Lojistik Hizmetleri',
      lots: 40,
      costPrice: 1560.80,
      currentPrice: 31.20,
      change: 78.00,
      changePercent: 12.50,
    ),
  ];
}
