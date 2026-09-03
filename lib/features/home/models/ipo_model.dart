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

/// Halka arz dağıtım / talep sonuçları tablo satırı
class IpoDistributionResult {
  final String investorGroup;
  final String personCount;
  final String lotCount;
  final String ratio;
  final bool isTotal;

  const IpoDistributionResult({
    required this.investorGroup,
    required this.personCount,
    required this.lotCount,
    required this.ratio,
    this.isTotal = false,
  });
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
  final bool isTraded;

  // Detay sayfası alanları
  final double? participationIndex;
  final double? publicShareRatio;
  final double? priceStability;
  final String? sharesOffered;
  final List<AllocationGroup>? allocationGroups;
  final List<IpoDistributionResult>? distributionResults;
  final List<IpoDistributionResult>? demandResults;
  final String? perPersonLot;
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
    this.distributionResults,
    this.demandResults,
    this.perPersonLot,
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
    this.isTraded = true,
  });

  bool get isGain => (change ?? 0) >= 0;

  /// Henüz BIST'te işlem görmemiş (yaklaşan / yeni) halka arz mı?
  bool get isUpcoming => !isTraded;

  /// Türkçe tarih metinlerindeki baştaki sıfırları temizler (Örn: "05-06 Ekim" -> "5-6 Ekim", "07-08 Aralık" -> "7-8 Aralık", "07 Eylül" -> "7 Eylül")
  static String formatTurkishDateString(String? text) {
    if (text == null || text.isEmpty) return '-';
    return text.replaceAllMapped(RegExp(r'\b0([1-9])\b'), (m) => m[1]!);
  }

  /// Formatlanmış halka arz tarihleri (baştaki sıfırlar temizlenmiş)
  String get formattedIpoDates => formatTurkishDateString(ipoDates ?? ipoDate);

  /// Formatlanmış BIST ilk işlem tarihi (baştaki sıfırlar temizlenmiş)
  String get formattedFirstTradeDate => formatTurkishDateString(firstTradeDate);

  /// Hem mockAllIpos hem mockIpos listelerinden sembol bazında arama yapar.
  static IpoModel findBySymbol(String symbol) {
    final traded = mockAllIpos.where((i) => i.symbol == symbol);
    if (traded.isNotEmpty) return traded.first;
    final upcoming = mockIpos.where((i) => i.symbol == symbol);
    if (upcoming.isNotEmpty) return upcoming.first;
    return mockAllIpos.first;
  }

  static const List<IpoDistributionResult> _defaultDistribution = [
    IpoDistributionResult(
      investorGroup: 'Yurt İçi Bireysel',
      personCount: '582.468',
      lotCount: '28.987.770',
      ratio: '%60',
    ),
    IpoDistributionResult(
      investorGroup: 'Yurt İçi Kurumsal',
      personCount: '39',
      lotCount: '19.325.180',
      ratio: '%40',
    ),
    IpoDistributionResult(
      investorGroup: 'TOPLAM',
      personCount: '582.507',
      lotCount: '48.312.950',
      ratio: '%100',
      isTotal: true,
    ),
  ];

  static const List<IpoDistributionResult> _defaultDemand = [
    IpoDistributionResult(
      investorGroup: 'Yurt İçi Bireysel',
      personCount: '589.652',
      lotCount: '37.902.061',
      ratio: '%65',
    ),
    IpoDistributionResult(
      investorGroup: 'Yurt İçi Kurumsal',
      personCount: '40',
      lotCount: '20.668.477',
      ratio: '%35',
    ),
    IpoDistributionResult(
      investorGroup: 'TOPLAM',
      personCount: '589.692',
      lotCount: '58.570.538',
      ratio: '%100',
      isTotal: true,
    ),
  ];

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

  /// Henüz çıkmamış / işlem görmemiş yeni halka arzlar (Yeni Halka Arzlar bölümü)
  static const List<IpoModel> mockIpos = [
    IpoModel(
      symbol: 'TABGD',
      companyName: 'TAB Gıda Sanayi ve Ticaret A.Ş.',
      ipoDate: '18.10.2026',
      price: 130.00,
      isTraded: false,
      ipoPrice: '130,00 TL',
      ipoDates: '18-19-20 Ekim',
      distributionMethod: 'Eşit dağıtım',
      market: 'Yıldız Pazar',
      firstTradeDate: '26 Ekim',
      shares: '52.500.000 Lot',
      halkaArzEdilecekPaylar: '52.500.000 Lot',
      katilimEndeksi: 'Evet',
      halkaAciklikOrani: '%20,09',
      fiyatIstikrari: '15 Gün',
      allocationGroups: [
        AllocationGroup(
          name: 'Yurt İçi Bireysel Yatırımcılar',
          percent: 78.0,
          colorHex: '#00B856',
        ),
        AllocationGroup(
          name: 'Grup Şirket Çalışanları',
          percent: 2.0,
          colorHex: '#E74C3C',
        ),
        AllocationGroup(
          name: 'Yurt İçi Kurumsal Yatırımcılar',
          percent: 20.0,
          colorHex: '#4A90E2',
        ),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
        IpoDocument(name: 'Fon Kullanım Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'EBEBK',
      companyName: 'Ebebek Mağazacılık A.Ş.',
      ipoDate: '29.08.2026',
      price: 46.50,
      isTraded: false,
      ipoPrice: '46,50 TL',
      ipoDates: '29-31 Ağustos - 1 Eylül',
      distributionMethod: 'Eşit dağıtım',
      market: 'Yıldız Pazar',
      firstTradeDate: '7 Eylül',
      shares: '40.000.000 Lot',
      halkaArzEdilecekPaylar: '40.000.000 Lot',
      katilimEndeksi: 'Evet',
      halkaAciklikOrani: '%29,41',
      fiyatIstikrari: '30 Gün',
      allocationGroups: [
        AllocationGroup(
          name: 'Yurt İçi Bireysel Yatırımcılar',
          percent: 48.0,
          colorHex: '#00B856',
        ),
        AllocationGroup(
          name: 'Grup Çalışanları',
          percent: 2.0,
          colorHex: '#E74C3C',
        ),
        AllocationGroup(
          name: 'Yurt İçi Kurumsal Yatırımcılar',
          percent: 25.0,
          colorHex: '#4A90E2',
        ),
        AllocationGroup(
          name: 'Yurt Dışı Kurumsal Yatırımcılar',
          percent: 25.0,
          colorHex: '#F5A623',
        ),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'MEKAG',
      companyName: 'Meka Beton Santralleri A.Ş.',
      ipoDate: '05.10.2026',
      price: 25.00,
      isTraded: false,
      ipoPrice: '25,00 TL',
      ipoDates: '5-6 Ekim',
      distributionMethod: 'Eşit dağıtım',
      market: 'Ana Pazar',
      firstTradeDate: '12 Ekim',
      shares: '16.900.000 Lot',
      halkaArzEdilecekPaylar: '16.900.000 Lot',
      katilimEndeksi: 'Evet',
      halkaAciklikOrani: '%27,04',
      fiyatIstikrari: 'Planlanmıyor',
      allocationGroups: [
        AllocationGroup(
          name: 'Yurt İçi Bireysel Yatırımcılar',
          percent: 100.0,
          colorHex: '#00B856',
        ),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Tasarruf Sahiplerine Satış Duyurusu', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'BORLS',
      companyName: 'Borlease Otomotiv A.Ş.',
      ipoDate: '11.10.2026',
      price: 25.29,
      isTraded: false,
      ipoPrice: '25,29 TL',
      ipoDates: '11-12-13 Ekim',
      distributionMethod: 'Eşit dağıtım',
      market: 'Yıldız Pazar',
      firstTradeDate: '19 Ekim',
      shares: '47.000.000 Lot',
      halkaArzEdilecekPaylar: '47.000.000 Lot',
      katilimEndeksi: 'Katılmıyor',
      halkaAciklikOrani: '%28,05',
      fiyatIstikrari: '30 Gün',
      allocationGroups: [
        AllocationGroup(
          name: 'Yurt İçi Bireysel Yatırımcılar',
          percent: 70.0,
          colorHex: '#00B856',
        ),
        AllocationGroup(
          name: 'Şirket Çalışanları',
          percent: 5.0,
          colorHex: '#E74C3C',
        ),
        AllocationGroup(
          name: 'Yurt İçi Kurumsal Yatırımcılar',
          percent: 25.0,
          colorHex: '#4A90E2',
        ),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'MHRGY',
      companyName: 'MHR Gayrimenkul Yatırım Ortaklığı',
      ipoDate: '12.10.2026',
      price: 4.30,
      isTraded: false,
      ipoPrice: '4,30 TL',
      ipoDates: '12-13 Ekim',
      distributionMethod: 'Tamamı Eşit Dağıtım',
      market: 'Yıldız Pazar',
      firstTradeDate: '18 Ekim',
      shares: '207.000.000 Lot',
      halkaArzEdilecekPaylar: '207.000.000 Lot',
      katilimEndeksi: 'Evet',
      halkaAciklikOrani: '%25,03',
      fiyatIstikrari: 'Planlanmıyor',
      allocationGroups: [
        AllocationGroup(
          name: 'Tüm Yatırımcılar (Eşit Dağıtım)',
          percent: 100.0,
          colorHex: '#00B856',
        ),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
        IpoDocument(name: 'Bağımsız Denetim Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'SURGY',
      companyName: 'Sur Tatil Evleri GYO A.Ş.',
      ipoDate: '07.12.2026',
      price: 49.18,
      isTraded: false,
      ipoPrice: '49,18 TL',
      ipoDates: '7-8 Aralık',
      distributionMethod: 'Eşit dağıtım',
      market: 'Yıldız Pazar',
      firstTradeDate: '14 Aralık',
      shares: '45.000.000 Lot',
      halkaArzEdilecekPaylar: '45.000.000 Lot',
      katilimEndeksi: 'Evet',
      halkaAciklikOrani: '%26,79',
      fiyatIstikrari: '30 Gün',
      allocationGroups: [
        AllocationGroup(
          name: 'Yurt İçi Bireysel Yatırımcılar',
          percent: 80.0,
          colorHex: '#00B856',
        ),
        AllocationGroup(
          name: 'Yurt İçi Kurumsal Yatırımcılar',
          percent: 20.0,
          colorHex: '#4A90E2',
        ),
      ],
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
      ],
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
      tavanSeriDays: 8,
      tavanSeriCompleted: 5,
      participationIndex: 3.24,
      publicShareRatio: 18.5,
      priceStability: 87.4,
      sharesOffered: '12.500.000 Lot',
      allocationGroups: _defaultAllocation,
      distributionResults: _defaultDistribution,
      demandResults: _defaultDemand,
      perPersonLot: '50 Lot (6.437,50 TL)',
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
      tavanSeriDays: 6,
      tavanSeriCompleted: 6,
      participationIndex: 2.11,
      publicShareRatio: 24.0,
      priceStability: 72.8,
      sharesOffered: '8.000.000 Lot',
      allocationGroups: _defaultAllocation,
      distributionResults: _defaultDistribution,
      demandResults: _defaultDemand,
      perPersonLot: '50 Lot (6.437,50 TL)',
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'AAGYO',
      companyName: 'AA Gayrimenkul Yatırım',
      ipoDate: '1-2-3 Eylül 2026',
      price: 76.50,
      change: 12.30,
      changePercent: 2.15,
      tavanSeriDays: 7,
      tavanSeriCompleted: 3,
      participationIndex: 4.87,
      publicShareRatio: 20.0,
      priceStability: 91.2,
      sharesOffered: '15.000.000 Lot',
      allocationGroups: _defaultAllocation,
      distributionResults: _defaultDistribution,
      demandResults: _defaultDemand,
      perPersonLot: '50 Lot (6.437,50 TL)',
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
      ipoDate: '5-6-7 Haziran 2026',
      price: 22.80,
      change: 45.60,
      changePercent: 8.72,
      tavanSeriDays: 0,
      tavanSeriCompleted: 0,
      participationIndex: 5.13,
      publicShareRatio: 30.0,
      priceStability: 78.5,
      sharesOffered: '20.000.000 Lot',
      allocationGroups: _defaultAllocation,
      distributionResults: _defaultDistribution,
      demandResults: _defaultDemand,
      perPersonLot: '50 Lot (6.437,50 TL)',
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
      tavanSeriDays: 5,
      tavanSeriCompleted: 2,
      participationIndex: 1.89,
      publicShareRatio: 15.0,
      priceStability: 61.3,
      sharesOffered: '6.250.000 Lot',
      allocationGroups: _defaultAllocation,
      distributionResults: _defaultDistribution,
      demandResults: _defaultDemand,
      perPersonLot: '50 Lot (6.437,50 TL)',
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
      tavanSeriDays: 4,
      tavanSeriCompleted: 4,
      participationIndex: 3.56,
      publicShareRatio: 22.5,
      priceStability: 83.7,
      sharesOffered: '10.000.000 Lot',
      allocationGroups: _defaultAllocation,
      distributionResults: _defaultDistribution,
      demandResults: _defaultDemand,
      perPersonLot: '50 Lot (6.437,50 TL)',
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'MRKEZ',
      companyName: 'Merkez Yapı Endüstri',
      ipoDate: '2-3-4 Mart 2026',
      price: 9.60,
      change: -14.40,
      changePercent: -6.25,
      tavanSeriDays: 0,
      tavanSeriCompleted: 0,
      participationIndex: 2.44,
      publicShareRatio: 16.8,
      priceStability: 69.1,
      sharesOffered: '9.000.000 Lot',
      allocationGroups: _defaultAllocation,
      distributionResults: _defaultDistribution,
      demandResults: _defaultDemand,
      perPersonLot: '50 Lot (6.437,50 TL)',
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
      tavanSeriDays: 6,
      tavanSeriCompleted: 4,
      participationIndex: 6.22,
      publicShareRatio: 25.0,
      priceStability: 94.6,
      sharesOffered: '18.000.000 Lot',
      allocationGroups: _defaultAllocation,
      distributionResults: _defaultDistribution,
      demandResults: _defaultDemand,
      perPersonLot: '50 Lot (6.437,50 TL)',
      documents: [
        IpoDocument(name: 'İzahname', fileType: 'PDF'),
        IpoDocument(name: 'Sermaye Piyasası Aracı Notu', fileType: 'PDF'),
        IpoDocument(name: 'Özet', fileType: 'PDF'),
        IpoDocument(name: 'Fiyat Tespit Raporu', fileType: 'PDF'),
        IpoDocument(name: 'Bağımsız Denetim Raporu', fileType: 'PDF'),
      ],
    ),
    IpoModel(
      symbol: 'THYAO',
      companyName: 'Türk Hava Yolları A.O.',
      ipoDate: 'BIST 30',
      price: 294.50,
      change: 8.00,
      changePercent: 2.79,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Evet',
      tavanSeriDays: 8,
      tavanSeriCompleted: 8,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'ASELS',
      companyName: 'Aselsan Elektronik Sanayi ve Ticaret A.Ş.',
      ipoDate: 'BIST 30',
      price: 62.10,
      change: 0.90,
      changePercent: 1.47,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Evet',
      tavanSeriDays: 5,
      tavanSeriCompleted: 3,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'TUPRS',
      companyName: 'Türkiye Petrol Rafinerileri A.Ş.',
      ipoDate: 'BIST 30',
      price: 172.30,
      change: -1.40,
      changePercent: -0.81,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Katılmıyor',
      tavanSeriDays: 0,
      tavanSeriCompleted: 0,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'EREGL',
      companyName: 'Ereğli Demir ve Çelik Fabrikaları T.A.Ş.',
      ipoDate: 'BIST 30',
      price: 51.40,
      change: 0.25,
      changePercent: 0.49,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Evet',
      tavanSeriDays: 4,
      tavanSeriCompleted: 1,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'KCHOL',
      companyName: 'Koç Holding A.Ş.',
      ipoDate: 'BIST 30',
      price: 215.00,
      change: 4.10,
      changePercent: 1.94,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Katılmıyor',
      tavanSeriDays: 7,
      tavanSeriCompleted: 7,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'BIMAS',
      companyName: 'BİM Birleşik Mağazalar A.Ş.',
      ipoDate: 'BIST 30',
      price: 485.00,
      change: -5.50,
      changePercent: -1.12,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Evet',
      tavanSeriDays: 6,
      tavanSeriCompleted: 2,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'SISE',
      companyName: 'Türkiye Şişe ve Cam Fabrikaları A.Ş.',
      ipoDate: 'BIST 30',
      price: 48.90,
      change: 0.44,
      changePercent: 0.91,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Evet',
      tavanSeriDays: 0,
      tavanSeriCompleted: 0,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'SAHOL',
      companyName: 'Hacı Ömer Sabancı Holding A.Ş.',
      ipoDate: 'BIST 30',
      price: 94.20,
      change: 1.95,
      changePercent: 2.11,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Katılmıyor',
      tavanSeriDays: 5,
      tavanSeriCompleted: 5,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'GARAN',
      companyName: 'Türkiye Garanti Bankası A.Ş.',
      ipoDate: 'BIST 30',
      price: 118.50,
      change: -0.50,
      changePercent: -0.42,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Katılmıyor',
      tavanSeriDays: 3,
      tavanSeriCompleted: 2,
      isTraded: true,
    ),
    IpoModel(
      symbol: 'FROTO',
      companyName: 'Ford Otomotiv Sanayi A.Ş.',
      ipoDate: 'BIST 30',
      price: 1045.00,
      change: 32.00,
      changePercent: 3.16,
      market: 'Yıldız Pazar',
      katilimEndeksi: 'Evet',
      tavanSeriDays: 8,
      tavanSeriCompleted: 6,
      isTraded: true,
    ),
  ];
}
