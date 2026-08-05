class IpoModel {
  final String symbol;
  final String companyName;
  final String ipoDate;
  final double price;
  final String? logoUrl;

  const IpoModel({
    required this.symbol,
    required this.companyName,
    required this.ipoDate,
    required this.price,
    this.logoUrl,
  });

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
}
