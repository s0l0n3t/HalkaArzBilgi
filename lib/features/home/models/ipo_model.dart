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
      ipoDate: '08.08.2026',
      price: 11.20,
    ),
    IpoModel(
      symbol: 'SARAE',
      companyName: 'Saray Enerji',
      ipoDate: '12.08.2026',
      price: 35.50,
    ),
    IpoModel(
      symbol: 'KLNMA',
      companyName: 'Kalınma Holding',
      ipoDate: '15.08.2026',
      price: 22.80,
    ),
    IpoModel(
      symbol: 'BTCTR',
      companyName: 'Bitay Kripto Teknoloji',
      ipoDate: '19.08.2026',
      price: 48.00,
    ),
    IpoModel(
      symbol: 'YLDZE',
      companyName: 'Yıldız Enerji A.Ş.',
      ipoDate: '25.08.2026',
      price: 17.40,
    ),
    IpoModel(
      symbol: 'MRKEZ',
      companyName: 'Merkez Yapı Endüstri',
      ipoDate: '02.09.2026',
      price: 9.60,
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
    IpoModel(
      symbol: 'KLNMA',
      companyName: 'Kalınma Holding',
      ipoDate: '05-06-07 Haziran 2026',
      price: 22.80,
      change: 45.60,
      changePercent: 8.72,
    ),
    IpoModel(
      symbol: 'BTCTR',
      companyName: 'Bitay Kripto Teknoloji',
      ipoDate: '10-11-12 Mayıs 2026',
      price: 48.00,
      change: -210.40,
      changePercent: -11.20,
    ),
    IpoModel(
      symbol: 'YLDZE',
      companyName: 'Yıldız Enerji A.Ş.',
      ipoDate: '18-19-20 Nisan 2026',
      price: 17.40,
      change: 33.18,
      changePercent: 5.44,
    ),
    IpoModel(
      symbol: 'MRKEZ',
      companyName: 'Merkez Yapı Endüstri',
      ipoDate: '02-03-04 Mart 2026',
      price: 9.60,
      change: -14.40,
      changePercent: -6.25,
    ),
    IpoModel(
      symbol: 'DENIZ',
      companyName: 'Deniz Lojistik Hizmetleri',
      ipoDate: '15-16-17 Şubat 2026',
      price: 31.20,
      change: 78.00,
      changePercent: 12.50,
    ),
  ];
}
