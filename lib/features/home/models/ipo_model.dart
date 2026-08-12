/// Tahsisat grubu — halka arzda her gruba ayrılan pay yüzdesi
class AllocationGroup {
  final String name;
  final double percent;
  final String colorHex;

  const AllocationGroup({
    required this.name,
    required this.percent,
    required this.colorHex,
  });
}

/// Halka arz sonuçları tablo satırı
class IpoResultRow {
  final String label;
  final String value;

  const IpoResultRow({required this.label, required this.value});
}

/// Halka arz dökümanı
class IpoDocument {
  final String name;
  final String fileType;
  final String url;

  const IpoDocument({
    required this.name,
    required this.fileType,
    this.url = '#',
  });
}

class IpoModel {
  final String symbol;
  final String companyName;
  final String ipoDate;
  final double price;
  final double? change;
  final double? changePercent;
  final String? logoUrl;

  // Detay sayfası alanları
  final double? participationIndex;
  final double? publicShareRatio;
  final double? priceStability;
  final String? sharesOffered;
  final List<AllocationGroup>? allocationGroups;
  final List<IpoResultRow>? ipoResults;
  final List<IpoDocument>? documents;

  // Yeni tasarım bilgi satırları ve tavan serisi alanları
  final String? ipoPrice;
  final String? ipoDates;
  final String? distributionMethod;
  final String? market;
  final String? firstTradeDate;
  final String? shares;
  final String? katilimEndeksi;
  final String? halkaAciklikOrani;
  final String? fiyatIstikrari;
  final String? halkaArzEdilecekPaylar;
  final int? tavanSeriDays;
  final int? tavanSeriCompleted;

  const IpoModel({
    required this.symbol,
    required this.companyName,
    required this.ipoDate,
    required this.price,
    this.change,
    this.changePercent,
    this.logoUrl,
    this.participationIndex,
    this.publicShareRatio,
    this.priceStability,
    this.sharesOffered,
    this.allocationGroups,
    this.ipoResults,
    this.documents,
    this.ipoPrice,
    this.ipoDates,
    this.distributionMethod,
    this.market,
    this.firstTradeDate,
    this.shares,
    this.katilimEndeksi,
    this.halkaAciklikOrani,
    this.fiyatIstikrari,
    this.halkaArzEdilecekPaylar,
    this.tavanSeriDays,
    this.tavanSeriCompleted,
  });

  bool get isGain => (change ?? 0) >= 0;

  static const List<AllocationGroup> _defaultAllocation = [
    AllocationGroup(
        name: 'Yurt İçi Bireysel Yatırımcılar',
        percent: 60.0,
        colorHex: '#00B856'),
    AllocationGroup(
        name: 'Yurt İçi Kurumsal Yatırımcılar',
        percent: 30.0,
        colorHex: '#4A90E2'),
    AllocationGroup(
        name: 'Yurt Dışı Kurumsal Yatırımcılar',
        percent: 7.0,
        colorHex: '#F5A623'),
    AllocationGroup(
        name: 'Şirket Çalışanları', percent: 3.0, colorHex: '#E74C3C'),
  ];

  /// Henüz çıkmamış halka arzlar (Yeni Halka Arzlar bölümü)
  static const List<IpoModel> mockIpos = [
    IpoModel(
        symbol: 'ATATR',
        companyName: 'Ata Turizm İşletmecilik',
        ipoDate: '08.08.2026',
        price: 11.20),
    IpoModel(
        symbol: 'SARAE',
        companyName: 'Saray Enerji',
        ipoDate: '12.08.2026',
        price: 35.50),
    IpoModel(
        symbol: 'KLNMA',
        companyName: 'Kalınma Holding',
        ipoDate: '15.08.2026',
        price: 22.80),
    IpoModel(
        symbol: 'BTCTR',
        companyName: 'Bitay Kripto Teknoloji',
        ipoDate: '19.08.2026',
        price: 48.00),
    IpoModel(
        symbol: 'YLDZE',
        companyName: 'Yıldız Enerji A.Ş.',
        ipoDate: '25.08.2026',
        price: 17.40),
    IpoModel(
        symbol: 'MRKEZ',
        companyName: 'Merkez Yapı Endüstri',
        ipoDate: '02.09.2026',
        price: 9.60),
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
      ipoPrice: '128,75 TL',
      ipoDates: '21-22-23 Ağustos',
      distributionMethod: 'Eşit dağıtım',
      market: 'Yıldız Pazar',
      firstTradeDate: '29 Ağustos',
      shares: '48.312.950 Lot',
      katilimEndeksi: 'Evet',
      halkaAciklikOrani: '%24,0',
      fiyatIstikrari: 'Planlanmıyor',
      halkaArzEdilecekPaylar: '48.312.950 Lot',
      tavanSeriDays: 3,
      tavanSeriCompleted: 2,
      participationIndex: 3.24,
      publicShareRatio: 18.5,
      priceStability: 87.4,
      sharesOffered: '12.500.000 Lot',
      allocationGroups: _defaultAllocation,
      ipoResults: [
        IpoResultRow(label: 'Toplam Talep', value: '42.187.500 Lot'),
        IpoResultRow(label: 'Talep / Arz Oranı', value: '3,37x'),
        IpoResultRow(label: 'Bireysel Kesinleşen Lot', value: '7.500.000'),
        IpoResultRow(label: 'Kurumsal Kesinleşen Lot', value: '3.750.000'),
        IpoResultRow(label: 'Halka Arz Fiyatı', value: '65,50 TL'),
        IpoResultRow(label: 'İşlem Başlangıç Tarihi', value: '18 Temmuz 2026'),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'SARAE',
      companyName: 'Saray Enerji',
      ipoDate: '22-23-24 Ağustos 2026',
      price: 35.50,
      change: -95.20,
      changePercent: -3.45,
      participationIndex: 2.11,
      publicShareRatio: 24.0,
      priceStability: 72.8,
      sharesOffered: '8.000.000 Lot',
      allocationGroups: _defaultAllocation,
      ipoResults: [
        IpoResultRow(label: 'Toplam Talep', value: '21.600.000 Lot'),
        IpoResultRow(label: 'Talep / Arz Oranı', value: '2,70x'),
        IpoResultRow(label: 'Bireysel Kesinleşen Lot', value: '4.800.000'),
        IpoResultRow(label: 'Kurumsal Kesinleşen Lot', value: '2.400.000'),
        IpoResultRow(label: 'Halka Arz Fiyatı', value: '35,50 TL'),
        IpoResultRow(label: 'İşlem Başlangıç Tarihi', value: '27 Ağustos 2026'),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'AAGYO',
      companyName: 'AA Gayrimenkul Yatırım',
      ipoDate: '01-02-03 Eylül 2026',
      price: 76.50,
      change: 12.30,
      changePercent: 2.15,
      participationIndex: 4.87,
      publicShareRatio: 20.0,
      priceStability: 91.2,
      sharesOffered: '15.000.000 Lot',
      allocationGroups: _defaultAllocation,
      ipoResults: [
        IpoResultRow(label: 'Toplam Talep', value: '73.050.000 Lot'),
        IpoResultRow(label: 'Talep / Arz Oranı', value: '4,87x'),
        IpoResultRow(label: 'Bireysel Kesinleşen Lot', value: '9.000.000'),
        IpoResultRow(label: 'Kurumsal Kesinleşen Lot', value: '4.500.000'),
        IpoResultRow(label: 'Halka Arz Fiyatı', value: '76,50 TL'),
        IpoResultRow(label: 'İşlem Başlangıç Tarihi', value: '06 Eylül 2026'),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
        IpoDocument(name: 'Bağımsız Denetim Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'KLNMA',
      companyName: 'Kalınma Holding',
      ipoDate: '05-06-07 Haziran 2026',
      price: 22.80,
      change: 45.60,
      changePercent: 8.72,
      participationIndex: 5.13,
      publicShareRatio: 30.0,
      priceStability: 78.5,
      sharesOffered: '20.000.000 Lot',
      allocationGroups: _defaultAllocation,
      ipoResults: [
        IpoResultRow(label: 'Toplam Talep', value: '102.600.000 Lot'),
        IpoResultRow(label: 'Talep / Arz Oranı', value: '5,13x'),
        IpoResultRow(label: 'Bireysel Kesinleşen Lot', value: '12.000.000'),
        IpoResultRow(label: 'Kurumsal Kesinleşen Lot', value: '6.000.000'),
        IpoResultRow(label: 'Halka Arz Fiyatı', value: '22,80 TL'),
        IpoResultRow(label: 'İşlem Başlangıç Tarihi', value: '10 Haziran 2026'),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'BTCTR',
      companyName: 'Bitay Kripto Teknoloji',
      ipoDate: '10-11-12 Mayıs 2026',
      price: 48.00,
      change: -210.40,
      changePercent: -11.20,
      participationIndex: 1.89,
      publicShareRatio: 15.0,
      priceStability: 61.3,
      sharesOffered: '6.250.000 Lot',
      allocationGroups: _defaultAllocation,
      ipoResults: [
        IpoResultRow(label: 'Toplam Talep', value: '11.812.500 Lot'),
        IpoResultRow(label: 'Talep / Arz Oranı', value: '1,89x'),
        IpoResultRow(label: 'Bireysel Kesinleşen Lot', value: '3.750.000'),
        IpoResultRow(label: 'Kurumsal Kesinleşen Lot', value: '1.875.000'),
        IpoResultRow(label: 'Halka Arz Fiyatı', value: '48,00 TL'),
        IpoResultRow(label: 'İşlem Başlangıç Tarihi', value: '15 Mayıs 2026'),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'YLDZE',
      companyName: 'Yıldız Enerji A.Ş.',
      ipoDate: '18-19-20 Nisan 2026',
      price: 17.40,
      change: 33.18,
      changePercent: 5.44,
      participationIndex: 3.56,
      publicShareRatio: 22.5,
      priceStability: 83.7,
      sharesOffered: '10.000.000 Lot',
      allocationGroups: _defaultAllocation,
      ipoResults: [
        IpoResultRow(label: 'Toplam Talep', value: '35.600.000 Lot'),
        IpoResultRow(label: 'Talep / Arz Oranı', value: '3,56x'),
        IpoResultRow(label: 'Bireysel Kesinleşen Lot', value: '6.000.000'),
        IpoResultRow(label: 'Kurumsal Kesinleşen Lot', value: '3.000.000'),
        IpoResultRow(label: 'Halka Arz Fiyatı', value: '17,40 TL'),
        IpoResultRow(label: 'İşlem Başlangıç Tarihi', value: '23 Nisan 2026'),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'MRKEZ',
      companyName: 'Merkez Yapı Endüstri',
      ipoDate: '02-03-04 Mart 2026',
      price: 9.60,
      change: -14.40,
      changePercent: -6.25,
      participationIndex: 2.44,
      publicShareRatio: 16.8,
      priceStability: 69.1,
      sharesOffered: '9.000.000 Lot',
      allocationGroups: _defaultAllocation,
      ipoResults: [
        IpoResultRow(label: 'Toplam Talep', value: '21.960.000 Lot'),
        IpoResultRow(label: 'Talep / Arz Oranı', value: '2,44x'),
        IpoResultRow(label: 'Bireysel Kesinleşen Lot', value: '5.400.000'),
        IpoResultRow(label: 'Kurumsal Kesinleşen Lot', value: '2.700.000'),
        IpoResultRow(label: 'Halka Arz Fiyatı', value: '9,60 TL'),
        IpoResultRow(label: 'İşlem Başlangıç Tarihi', value: '07 Mart 2026'),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'DENIZ',
      companyName: 'Deniz Lojistik Hizmetleri',
      ipoDate: '15-16-17 Şubat 2026',
      price: 31.20,
      change: 78.00,
      changePercent: 12.50,
      participationIndex: 6.22,
      publicShareRatio: 25.0,
      priceStability: 94.6,
      sharesOffered: '18.000.000 Lot',
      allocationGroups: _defaultAllocation,
      ipoResults: [
        IpoResultRow(label: 'Toplam Talep', value: '111.960.000 Lot'),
        IpoResultRow(label: 'Talep / Arz Oranı', value: '6,22x'),
        IpoResultRow(label: 'Bireysel Kesinleşen Lot', value: '10.800.000'),
        IpoResultRow(label: 'Kurumsal Kesinleşen Lot', value: '5.400.000'),
        IpoResultRow(label: 'Halka Arz Fiyatı', value: '31,20 TL'),
        IpoResultRow(label: 'İşlem Başlangıç Tarihi', value: '20 Şubat 2026'),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
        IpoDocument(name: 'Bağımsız Denetim Raporu', fileType: 'PDF'),
      ],
    ),
  ];
}


