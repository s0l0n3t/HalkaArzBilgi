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
  final String? content;
  final String? aiAnalysis;
  final String source;
  final NewsCategory category;
  final String timeAgo;
  final String? symbol;
  final String? imageUrl;
  final String? url;
  final bool isBreaking;
  final int readTimeMinutes;

  const NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    this.content,
    this.aiAnalysis,
    required this.source,
    required this.category,
    required this.timeAgo,
    this.symbol,
    this.imageUrl,
    this.url,
    this.isBreaking = false,
    this.readTimeMinutes = 2,
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

  /// ID'ye göre haber arama yardımcısı.
  static NewsModel? findById(String id) {
    try {
      return mockNews.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Tam içerik veya özet döndüren getter.
  String get fullContent => (content != null && content!.trim().isNotEmpty) ? content! : summary;

  /// Yapay zeka yorumu getter'ı.
  String get aiComment =>
      (aiAnalysis != null && aiAnalysis!.trim().isNotEmpty)
          ? aiAnalysis!
          : 'Bu gelişme, ilgili sektör ve şirket dinamikleri açısından piyasa tarafından yakından takip edilmekte olup, operasyonel hedeflerin gerçekleşme hızı orta vadeli fiyatlamayı belirleyecektir.';

  static const List<NewsModel> mockNews = [
    NewsModel(
      id: 'news_1',
      title: 'SARAE Halka arzı SPK tarafından onaylandı: Talep toplama tarihleri belli oldu',
      summary: 'Saray Holding bünyesindeki SARAE halka arzı için konsorsiyum lideri belirlendi. Talep toplama 3 iş günü sürecek.',
      content:
          'Saray Holding bünyesinde faaliyet gösteren SARAE paylarının halka arzı Sermaye Piyasası Kurulu (SPK) tarafından onaylandı. Konsorsiyum lideri eşliğinde yürütülecek olan talep toplama süreci önümüzdeki hafta başlayacak ve toplamda 3 iş günü süresince devam edecektir.\n\n'
          'Halka arz kapsamında çıkarılmış sermayenin artırılması yoluyla ihraç edilecek yeni payların yanı sıra ortak satışı da planlanmaktadır. Bireysel yatırımcılara tamamen eşit dağıtım prensibi uygulanacak olup, yatırımcılar konsorsiyum üyesi tüm aracı kurum ve bankalar aracılığıyla talep iletebileceklerdir.\n\n'
          'Şirket yönetiminden yapılan açıklamada, halka arzdan elde edilecek net fon gelirinin %60\'ının yeni üretim tesisleri ve kapasite artırımı yatırımlarında, %40\'ının ise işletme sermayesi ihtiyacının finansmanında kullanılacağı belirtildi.',
      aiAnalysis:
          'Eşit dağıtım yöntemi ve fonun %60\'ının doğrudan üretim tesisleri ve kapasite artırımına yönlendirilmesi, şirketin orta-uzun vadeli büyüme potansiyelini desteklemektedir. Bireysel yatırımcı ilgisinin yüksek olması, ilk işlem günlerinde dengeli ve güçlü bir talep oluşturabilir.',
      source: 'KAP',
      category: NewsCategory.ipo,
      timeAgo: '15 dk önce',
      symbol: 'SARAE',
      isBreaking: true,
      readTimeMinutes: 2,
      url: 'https://www.kap.org.tr',
    ),
    NewsModel(
      id: 'news_2',
      title: 'TKNKA Halka arzı SPK tarafından onaylandı: Talep toplama tarihleri belli oldu',
      summary: 'Teknika Mühendislik halka arz işlemleri için talep toplama süreci önümüzdeki hafta başlayacak.',
      content:
          'Teknoloji ve mühendislik alanında geniş bir pazar payına sahip olan Teknika Mühendislik (TKNKA), SPK onayının ardından halka arz izahnamesini kamuoyuyla paylaştı. Talep toplama işlemleri önümüzdeki hafta çarşamba, perşembe ve cuma günleri gerçekleştirilecektir.\n\n'
          'Halka arzın büyüklüğü ve şirketin güçlü özkaynak yapısı piyasa uzmanları tarafından olumlu karşılandı. Şirket, elde edeceği halka arz gelirinin önemli bir kısmını AR-GE yatırımları ve küresel pazarlara açılma stratejisi doğrultusunda değerlendirecektir.\n\n'
          'Yatırımcılar T1 ve T2 bakiye kullanım imkanlarını aracı kurumları üzerinden sorgulayabilecek olup, dağıtım sonuçlarının talep toplama bitimini takip eden ilk iş gününde açıklanması beklenmektedir.',
      aiAnalysis:
          'Mühendislik ve yüksek teknoloji odaklı sermaye girişi, şirketin ihracat yetkinliğini artıracaktır. T1 ve T2 bakiye kullanım esnekliği, yatırımcı katılım tabanını genişleterek halka arza ilgiyi olumlu etkileyebilir.',
      source: 'KAP',
      category: NewsCategory.ipo,
      timeAgo: '15 dk önce',
      symbol: 'TKNKA',
      readTimeMinutes: 2,
      url: 'https://www.kap.org.tr',
    ),
    NewsModel(
      id: 'news_3',
      title: 'SARAE Halka arzı SPK tarafından onaylandı: Talep toplama tarihleri belli oldu',
      summary: 'Saray Holding halka arz sürecinde güncelleme: Fiyat aralığı ve talep tarihlerinde netleşme sağlandı.',
      content:
          'Saray Holding (SARAE) halka arzına ilişkin konsorsiyum üyeleri tarafından yayımlanan fiyat tespit raporunda, şirketin çarpan analizleri ve iskonto oranı detaylandırıldı. Yatırımcılar için pay başına belirlenen sabit fiyat üzerinden talep toplanacak.\n\n'
          'Piyasa analistleri, holdingin döviz bazlı ihracat gelirlerinin güçlü seyrini koruması nedeniyle halka arza kurumsal ve bireysel yatırımcı ilgisinin yüksek seviyede olacağını tahmin ediyor.\n\n'
          'Halka arz sürecine ilişkin güncellemeler ve onaylı izahname ekleri KAP ve şirketin kurumsal yatırımcı ilişkileri sayfasında erişime açılmıştır.',
      aiAnalysis:
          'Fiyat tespit raporundaki iskonto oranı ve şirketin döviz kazandırıcı faaliyetleri, makroekonomik dalgalanmalara karşı koruma kalkanı sunmaktadır. Bu durum arza olan kurumsal iştahı destekleyen temel faktörlerdendir.',
      source: 'Foreks',
      category: NewsCategory.ipo,
      timeAgo: '42 dk önce',
      symbol: 'SARAE',
      readTimeMinutes: 2,
      url: 'https://www.foreks.com',
    ),
    NewsModel(
      id: 'news_4',
      title: 'AAGYO Gayrimenkul portföyüne 1.2 milyar TL değerinde yeni lojistik merkezi ekledi',
      summary: 'Şirketten yapılan açıklamada yeni merkezin yıllık kira getirisinin ciroya %18 katkı sağlaması beklendiği belirtildi.',
      content:
          'AAGYO Gayrimenkul Yatırım Ortaklığı, stratejik büyüme hedefleri kapsamında Marmara lojistik koridorunda yer alan dev lojistik merkezinin satın alma sözleşmesini imzaladığını duyurdu. 1.2 milyar TL yatırım değeriyle portföye eklenen merkezin doluluk oranı %100 seviyesindedir.\n\n'
          'Şirket KAP açıklamasında, yeni tesisin yıllık kira getirisinin şirket cirosuna yaklaşık %18 oranında doğrudan pozitif katkı sunacağını açıkladı. Kira sözleşmelerinin TÜFE ve döviz endeksli uzun vadeli kontratlara dayandığı bildirildi.\n\n'
          'Bu hamle ile birlikte AAGYO\'nun toplam portföy büyüklüğü 8 milyar TL sınırını aşmış olup, depolama ve lojistik segmentindeki pazar payı önemli ölçüde güçlenmiştir.',
      aiAnalysis:
          'Tam doluluk oranına sahip lojistik tesisi alımı, şirketin net aktif değerine (NAD) doğrudan prim katacaktır. Yıllık ciroya beklenen %18\'lik düzenli kira artışı, temettü dağıtım potansiyelini orta vadede yukarı taşıyabilir.',
      source: 'Matriks',
      category: NewsCategory.company,
      timeAgo: '42 dk önce',
      symbol: 'AAGYO',
      readTimeMinutes: 3,
      url: 'https://www.matriksdata.com',
    ),
    NewsModel(
      id: 'news_5',
      title: 'BIST 100 Endeksi güne %1.42 yükselişle rekor seviyeden başladı',
      summary: 'Bankacılık ve teknoloji hisseleri öncülüğünde Borsa İstanbul 10.850 puan seviyesini test ediyor.',
      content:
          'Borsa İstanbul BIST 100 endeksi, güne küresel risk iştahının artması ve para politikasındaki güven verici adımların etkisiyle %1.42 artışla 10.850 puan seviyesinde rekorla başladı.\n\n'
          'Açılışta özellikle bankacılık endeksi %2.10, teknoloji endeksi ise %1.85 oranında değer kazandı. Yabancı yatırımcıların BIST 30 hisselerine yönelik net alımları seansın ilk saatlerinde işlem hacminin son bir ayın ortalamasının üzerine çıkmasını sağladı.\n\n'
          'Teknik analistler, 10.800 seviyesinin üzerinde kalıcılık sağlanması durumunda 11.000 psikolojik direncinin hedeflenebileceğini, olası kâr satışlarında ise 10.650 seviyesinin ilk güçlü destek olarak izleneceğini belirtiyor.',
      aiAnalysis:
          'Bankacılık hisselerindeki güçlü girişler ve CDS primindeki iyileşme, yabancı yatırımcı ilgisinin devam ettiğini göstermektedir. 10.800 üzerinde kapanışlar momentumu 11.000 seviyesine taşıyabilir, ancak kâr satışlarına karşı temkinli olunmalıdır.',
      source: 'Foreks',
      category: NewsCategory.bist,
      timeAgo: '1 saat önce',
      readTimeMinutes: 3,
      url: 'https://www.foreks.com',
    ),
    NewsModel(
      id: 'news_6',
      title: 'ATATR yeni GES yatırımı için ÇED olumlu raporu aldığını duyurdu',
      summary: 'Güneş enerjisi santrali projesinin 2026 yılı 3. çeyreğinde tam kapasiteyle devreye alınması hedefleniyor.',
      content:
          'ATATR Enerji Grubu, İç Anadolu Bölgesi\'nde inşası planlanan 50 MW kurulu gücündeki yeni Güneş Enerjisi Santrali (GES) projesi için Çevre, Şehircilik ve İklim Değişikliği Bakanlığı\'ndan Çevresel Etki Değerlendirmesi (ÇED) Olumlu kararının alındığını duyurdu.\n\n'
          'Toplam yatırım bütçesi yaklaşık 45 milyon dolar olarak öngörülen tesisin 2026 yılının üçüncü çeyreğinde şebekeye elektrik üretmeye başlaması planlanıyor. Santral faaliyete geçtiğinde şirketin öz tüketim enerji maliyetlerini sıfırlaması ve fazla üretimi şebekeye satarak ilave gelir üretmesi hedeflenmektedir.\n\n'
          'Şirket hisseleri, yeşil enerji dönüşümü kapsamındaki bu önemli gelişmenin ardından günün ilk seansında %3.2 değer kazancıyla işlem görüyor.',
      aiAnalysis:
          '50 MW GES santralinin devreye girmesi, şirketin elektrik maliyetlerini minimize ederek FAVÖK marjında kayda değer bir genişleme yaratacaktır. Yeşil enerji dönüşümü aynı zamanda uluslararası ESG fonlarının ilgisini çekebilir.',
      source: 'KAP',
      category: NewsCategory.kap,
      timeAgo: '2 saat önce',
      symbol: 'ATATR',
      readTimeMinutes: 2,
      url: 'https://www.kap.org.tr',
    ),
    NewsModel(
      id: 'news_7',
      title: 'BTCTR sermaye artırımı ve bedelsiz pay dağıtımı kararı aldı',
      summary: 'Şirket yönetim kurulu %200 oranında iç kaynaklardan bedelsiz sermaye artırımı başvurusunu SPK\'ya iletti.',
      content:
          'BTCTR Yönetim Kurulu toplantısında alınan karar neticesinde, şirketin 100.000.000 TL olan ödenmiş sermayesinin tamamı geçmiş yıl kârları ve emisyon primlerinden karşılanmak üzere %200 oranında artırılarak 300.000.000 TL\'ye çıkarılması kararlaştırıldı.\n\n'
          'Bedelsiz sermaye artırımı ihraç belgesinin onaylanması amacıyla Sermaye Piyasası Kurulu\'na (SPK) resmi başvuru tamamlandı.\n\n'
          'Sermaye artırımı onaylandığında pay sahiplerine ellerindeki her 1 pay için 2 yeni pay bedelsiz olarak dağıtılacak. Bu hamlenin hisse likiditesini ve piyasa derinliğini artırması bekleniyor.',
      aiAnalysis:
          'Bedelsiz sermaye artırımları şirketin özkaynak toplamını değiştirmemekle birlikte, pay fiyatını nominal olarak bölerek küçük yatırımcılar için erişilebilirliği ve hissenin tahta likiditesini olumlu yönde etkiler.',
      source: 'KAP',
      category: NewsCategory.kap,
      timeAgo: '3 saat önce',
      symbol: 'BTCTR',
      readTimeMinutes: 2,
      url: 'https://www.kap.org.tr',
    ),
    NewsModel(
      id: 'news_8',
      title: 'SPK Bülteni yayınlandı: 2 yeni şirketin halka arzına onay çıktı',
      summary: 'Sermaye Piyasası Kurulu haftalık bülteninde iki teknoloji ve enerji şirketinin halka arz taslağını onayladı.',
      content:
          'Sermaye Piyasası Kurulu (SPK), yayımladığı 2026 yılı haftalık bülteninde iki yeni şirketin ilk halka arz başvurusunu onayladığını duyurdu. Onay alan şirketlerden biri yenilenebilir enerji altyapısı, diğeri ise kurumsal yazılım teknolojileri sektöründe yer alıyor.\n\n'
          'Bültende yer alan bilgilere göre her iki şirketin halka arzında da bireysel yatırımcı kategorisine tamamen eşit dağıtım uygulanacak. Halka arz gelirlerinin büyük kısmının yatırımlara ve borçluluğun azaltılmasına ayrılacağı açıklandı.\n\n'
          'Konsorsiyum liderleri tarafından onaylı izahnamelerin ve talep toplama tarihlerinin bu hafta içerisinde kamuoyuyla paylaşılması bekleniyor.',
      aiAnalysis:
          'Enerji ve yazılım temalı yeni halka arzlar, borsa ekosistemine yeni yatırımcı çekmede katalizör görevi görebilir. Eşit dağıtım yöntemi bireysel katılımcıların güvenini ve portföy çeşitlendirmesini teşvik etmektedir.',
      source: 'SPK',
      category: NewsCategory.ipo,
      timeAgo: '5 saat önce',
      isBreaking: true,
      readTimeMinutes: 3,
      url: 'https://www.spk.gov.tr',
    ),
    NewsModel(
      id: 'news_9',
      title: 'THYAO filosuna 10 yeni nesil geniş gövdeli uçak katılacağını açıkladı',
      summary: 'Türk Hava Yolları, 2033 büyüme stratejisi kapsamında teslimat takvimini revize ettiğini bildirdi.',
      content:
          'Türk Hava Yolları (THYAO), 2033 stratejik vizyonu doğrultusunda filo büyümesini sürdürüyor. Şirket, uçak üreticileri ile varılan mutabakat çerçevesinde teslimat takvimi öne çekilen 10 adet yeni nesil geniş gövdeli uçağın yıl sonuna kadar filoya dahil olacağını duyurdu.\n\n'
          'Yeni uçaklar daha düşük yakıt tüketimi ve yüksek yolcu kapasitesiyle THYAO\'nun uzak kıtalararası rotalardaki operasyonel kârlılığını artıracak.\n\n'
          'Havacılık sektörü analistleri, turizm sezonunun güçlü seyrettiği bu dönemde kapasite artışının şirketin üçüncü ve dördüncü çeyrek finansal sonuçlarına çarpan etkisi yapacağını değerlendiriyor.',
      aiAnalysis:
          'Geniş gövdeli filo takviyesi, birim koltuk/kilometre maliyetlerini aşağı çekerken kıtalararası transit yolcu gelirlerinde çift haneli büyüme sağlayabilir. Şirketin küresel pazar payını artırma hedefiyle tam uyumludur.',
      source: 'Bloomberg HT',
      category: NewsCategory.company,
      timeAgo: '6 saat önce',
      symbol: 'THYAO',
      readTimeMinutes: 2,
      url: 'https://www.bloomberght.com',
    ),
    NewsModel(
      id: 'news_10',
      title: 'Merkez Bankası faiz kararı sonrası piyasalarda ilk tepkiler ve analizler',
      summary: 'Para Politikası Kurulu toplantı özeti açıklandı. Borsa ve döviz piyasalarında volatilite azaldı.',
      content:
          'Türkiye Cumhuriyet Merkez Bankası (TCMB) Para Politikası Kurulu (PPK) toplantı özetinde enflasyon beklentileri, kredi büyümesi ve iç talep dengelenmesine dair kritik mesajlar verildi. Politika faizinin sabit bırakılmasının ardından piyasalarda volatilite geriledi.\n\n'
          'Açıklamada, enflasyonda kalıcı düşüş sağlanana kadar sıkı para politikası duruşunun kararlılıkla sürdürüleceği ve gerektiğinde ilave sterilizasyon araçlarının devreye alınacağı yinelendi.\n\n'
          'Piyasa uzmanları, bankanın net duruşunun TL varlıklara olan güveni desteklediğini ve Borsa İstanbul\'da orta vadeli beklentileri pozitif tutmaya devam ettiğini belirtiyor.',
      aiAnalysis:
          'TCMB\'nin öngörülebilir ve kararlı duruşu, ülke risk primindeki gerilemeyi destekleyerek yabancı girişlerinin önünü açmaktadır. Faiz politikasındaki istikrar, özellikle bankacılık ve sanayi endeksleri için olumlu bir zemin hazırlar.',
      source: 'Ekonomi Gazetesi',
      category: NewsCategory.bist,
      timeAgo: '8 saat önce',
      readTimeMinutes: 3,
      url: 'https://www.ekonomim.com',
    ),
  ];
}
