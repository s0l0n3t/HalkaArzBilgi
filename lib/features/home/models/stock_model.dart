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
      change: -355.56,
      changePercent: -3.45,
    ),
    StockModel(
      id: '3',
      symbol: 'AAGYO',
      companyName: 'AA Gayrimenkul Yatırım',
      lots: 65,
      costPrice: 1350.75,
      currentPrice: 76.50,
      change: -355.56,
      changePercent: -13.45,
    ),
  ];
}
