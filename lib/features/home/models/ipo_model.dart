class IpoModel {
  final String symbol;
  final String companyName;
  final String ipoDate;
  final double price;
  final double? change;
  final double? changePercent;
  final String? logoUrl;

  const IpoModel({
    required this.symbol,
    required this.companyName,
    required this.ipoDate,
    required this.price,
    this.change,
    this.changePercent,
    this.logoUrl,
  });

  bool get isGain => (change ?? 0) >= 0;

  /// Henüz çıkmamış halka arzlar (Yeni Halka Arzlar bölümü)
  static const List<IpoModel> mockIpos = [
    IpoModel(
      symbol: 'ATATR',
      companyName: 'Ata Turizm İşletmecilik',
      ipoDate: '15.08.2023',
      price: 11.20,
    ),
    IpoModel(
      symbol: 'SARAE',
      companyName: 'Saray Enerji',
      ipoDate: '22.08.2023',
      price: 35.50,
    ),
  ];

  /// Geçmişte çıkmış, hali hazırda listelenen halka arzlar (Halka Arzlar bölümü)
  static const List<IpoModel> mockAllIpos = [
    IpoModel(
      symbol: 'ATATR',
      companyName: 'Ata Turizm İşletmecilik',
      ipoDate: '13-14-15 Temmuz 2026',
      price: 65.50,
      change: -355.56,
      changePercent: -15.33,
    ),
    IpoModel(
      symbol: 'SARAE',
      companyName: 'Saray Enerji',
      ipoDate: '22-23-24 Ağustos 2026',
      price: 35.50,
      change: -95.20,
      changePercent: -3.45,
    ),
    IpoModel(
      symbol: 'AAGYO',
      companyName: 'AA Gayrimenkul Yatırım',
      ipoDate: '01-02-03 Eylül 2026',
      price: 76.50,
      change: 12.30,
      changePercent: 2.15,
    ),
  ];
}
