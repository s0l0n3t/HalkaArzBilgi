import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';

class IpoCalendarWidget extends StatefulWidget {
  const IpoCalendarWidget({super.key});

  @override
  State<IpoCalendarWidget> createState() => _IpoCalendarWidgetState();
}

class _IpoCalendarWidgetState extends State<IpoCalendarWidget>
    with SingleTickerProviderStateMixin {
  late PageController _weekPageController;
  late PageController _monthPageController;
  late DateTime _today;

  // Genişletilmiş (Aylık) vs Daraltılmış (Haftalık) durumu
  bool _isExpanded = false;

  // Kullanılabilir aylar ve haftalar listesi (Sadece halka arzı olan aylar ve mevcut ay)
  late final List<DateTime> _availableMonths;
  late final List<DateTime> _availableWeeks;
  int _currentWeekIndex = 0;
  int _currentMonthIndex = 0;

  DateTime? _selectedDate;
  List<IpoModel>? _selectedIpos;
  int _selectedDayIndex = -1; // 0-6 arası sütun
  int _selectedRowIndex = 0; // Aylık ızgara için satır

  // Geçmiş günler için soluk renk
  static const Color _pastDayColor = Color(0xFF444444);

  // Tooltip arka plan rengi
  static const Color _tooltipBg = Color(0xFF222222);

  // Türkçe kısa ay isimleri
  static const List<String> _turkishShortMonths = [
    'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
    'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
  ];

  // Türkçe tam gün isimleri
  static const List<String> _turkishFullDays = [
    'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar',
  ];

  // Türkçe gün kısaltmaları (Pazartesi ilk gün)
  static const List<String> _dayLabels = [
    'Pt', 'Sa', 'Ça', 'Pe', 'Cu', 'Ct', 'Pa',
  ];

  // Türkçe ay isimleri eşleme haritası
  static const Map<String, int> _monthNameToNumber = {
    'ocak': 1,
    'şubat': 2,
    'mart': 3,
    'nisan': 4,
    'mayıs': 5,
    'haziran': 6,
    'temmuz': 7,
    'ağustos': 8,
    'eylül': 9,
    'ekim': 10,
    'kasım': 11,
    'aralık': 12,
  };

  // Halka arz tarihlerini hızlı erişim için map olarak tut (Aynı günde birden fazla halka arz olabilir)
  late final Map<DateTime, List<IpoModel>> _ipoDateMap;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();

    // 1. mockIpos tarihlerini (ipoDates) ayrıştır ve map'e ekle
    _ipoDateMap = {};
    final Set<DateTime> uniqueMonthStarts = {
      DateTime(_today.year, _today.month, 1),
    };

    for (final ipo in IpoModel.mockIpos) {
      final dates = _parseIpoDates(ipo);
      for (final date in dates) {
        final normalized = DateTime(date.year, date.month, date.day);
        _ipoDateMap.putIfAbsent(normalized, () => []).add(ipo);
        uniqueMonthStarts.add(DateTime(date.year, date.month, 1));
      }
    }

    // 2. İlk aydan son aya kadar tüm ayları kesintisiz oluştur (Aylar arasında atlama olmaması için)
    final sortedUnique = uniqueMonthStarts.toList()
      ..sort((a, b) => a.compareTo(b));
    final firstMonth = sortedUnique.first;
    final lastMonth = sortedUnique.last;

    _availableMonths = [];
    var currentMonth = DateTime(firstMonth.year, firstMonth.month, 1);
    final endMonth = DateTime(lastMonth.year, lastMonth.month, 1);
    while (!currentMonth.isAfter(endMonth)) {
      _availableMonths.add(currentMonth);
      currentMonth = DateTime(
        currentMonth.month == 12 ? currentMonth.year + 1 : currentMonth.year,
        currentMonth.month == 12 ? 1 : currentMonth.month + 1,
        1,
      );
    }

    // 3. Bu ayları kapsayan haftaları oluştur
    final firstMonday =
        firstMonth.subtract(Duration(days: firstMonth.weekday - 1));
    final lastDayOfLastMonth =
        DateTime(lastMonth.year, lastMonth.month + 1, 0);
    final lastMonday = lastDayOfLastMonth
        .subtract(Duration(days: lastDayOfLastMonth.weekday - 1));

    _availableWeeks = [];
    var currentMonday =
        DateTime(firstMonday.year, firstMonday.month, firstMonday.day);
    final endMonday =
        DateTime(lastMonday.year, lastMonday.month, lastMonday.day);

    while (!currentMonday.isAfter(endMonday)) {
      _availableWeeks.add(currentMonday);
      currentMonday = currentMonday.add(const Duration(days: 7));
    }

    // Bugünün bulunduğu ay ve hafta indekslerini bul
    final todayMonthStart = DateTime(_today.year, _today.month, 1);
    final todayWeekday = _today.weekday;
    final thisWeekMonday = DateTime(_today.year, _today.month, _today.day)
        .subtract(Duration(days: todayWeekday - 1));

    _currentMonthIndex = _availableMonths.indexOf(todayMonthStart);
    if (_currentMonthIndex == -1) _currentMonthIndex = 0;

    _currentWeekIndex = _availableWeeks.indexWhere((w) =>
        w.year == thisWeekMonday.year &&
        w.month == thisWeekMonday.month &&
        w.day == thisWeekMonday.day);
    if (_currentWeekIndex == -1) _currentWeekIndex = 0;

    _monthPageController = PageController(initialPage: _currentMonthIndex);
    _weekPageController = PageController(initialPage: _currentWeekIndex);
  }

  @override
  void dispose() {
    _weekPageController.dispose();
    _monthPageController.dispose();
    super.dispose();
  }

  /// "dd.MM.yyyy" formatını DateTime'a çevir
  DateTime? _parseIpoDate(String dateStr) {
    try {
      final parts = dateStr.split('.');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (_) {}
    return null;
  }

  /// `ipoDates` (örn: "18-19-20 Ekim", "29-31 Ağustos - 1 Eylül", "05-06 Ekim") veya `ipoDate` alanından tüm günleri DateTime listesi olarak çıkarır
  List<DateTime> _parseIpoDates(IpoModel ipo) {
    final List<DateTime> result = [];
    int baseYear = _today.year;

    // ipoDate'den (örn: 18.10.2026) yıl almayı dene
    if (ipo.ipoDate.isNotEmpty) {
      final parts = ipo.ipoDate.split('.');
      if (parts.length == 3) {
        final parsedYear = int.tryParse(parts[2]);
        if (parsedYear != null) baseYear = parsedYear;
      }
    }

    final rawDatesStr = ipo.ipoDates;
    if (rawDatesStr != null && rawDatesStr.trim().isNotEmpty) {
      // Birden fazla ay parçası varsa " - " veya "," ile ayrılabilir
      final segments = rawDatesStr.contains(' - ') && rawDatesStr.contains(RegExp(r'[a-zA-ZçğıöşüÇĞİÖŞÜ]'))
          ? rawDatesStr.split(RegExp(r'\s+-\s+(?=\d)'))
          : [rawDatesStr];

      for (final segment in segments) {
        int? month;
        final words = segment.trim().toLowerCase().split(RegExp(r'\s+'));
        for (final word in words) {
          final cleanWord = word.replaceAll(RegExp(r'[^a-zçğıöşü]'), '');
          if (_monthNameToNumber.containsKey(cleanWord)) {
            month = _monthNameToNumber[cleanWord];
            break;
          }
        }

        if (month != null) {
          final dayPart = segment.replaceAll(RegExp(r'[a-zA-ZçğıöşüÇĞİÖŞÜ]'), '').trim();
          if (dayPart.contains('-')) {
            final dayTokens = dayPart.split('-').map((s) => int.tryParse(s.trim())).whereType<int>().toList();
            if (dayTokens.length == 2 && dayTokens[1] - dayTokens[0] > 1) {
              // "29-31" gibi aralık
              for (int d = dayTokens[0]; d <= dayTokens[1]; d++) {
                result.add(DateTime(baseYear, month, d));
              }
            } else {
              // "18-19-20" veya "05-06" gibi liste
              for (final d in dayTokens) {
                result.add(DateTime(baseYear, month, d));
              }
            }
          } else {
            final singleDay = int.tryParse(dayPart);
            if (singleDay != null) {
              result.add(DateTime(baseYear, month, singleDay));
            }
          }
        }
      }
    }

    if (result.isEmpty) {
      final date = _parseIpoDate(ipo.ipoDate);
      if (date != null) {
        result.add(date);
      }
    }

    return result;
  }

  /// Verilen hafta indeksine göre haftanın başlangıç gününü (Pazartesi) hesapla
  DateTime _getWeekStart(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _availableWeeks.length) {
      return _availableWeeks[pageIndex];
    }
    return _today;
  }

  /// Verilen ay indeksine göre ayın 1. gününü hesapla
  DateTime _getMonthDate(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _availableMonths.length) {
      return _availableMonths[pageIndex];
    }
    return DateTime(_today.year, _today.month, 1);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isPastDay(DateTime date) {
    final todayNormalized = DateTime(_today.year, _today.month, _today.day);
    final dateNormalized = DateTime(date.year, date.month, date.day);
    return dateNormalized.isBefore(todayNormalized);
  }

  void _onDayTapped(DateTime date, int dayIndex, {int rowIndex = 0}) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final ipos = _ipoDateMap[normalizedDate];

    setState(() {
      if (ipos != null && ipos.isNotEmpty) {
        // Zaten seçili olan güne tekrar tıklandıysa kapat
        if (_selectedDate != null && _isSameDay(_selectedDate!, date)) {
          _selectedDate = null;
          _selectedIpos = null;
          _selectedDayIndex = -1;
          _selectedRowIndex = 0;
        } else {
          _selectedDate = date;
          _selectedIpos = ipos;
          _selectedDayIndex = dayIndex;
          _selectedRowIndex = rowIndex;
        }
      } else {
        // Halka arz olmayan güne tıklandıysa baloncuğu kapat
        _selectedDate = null;
        _selectedIpos = null;
        _selectedDayIndex = -1;
        _selectedRowIndex = 0;
      }
    });
  }

  void _goToPrevious() {
    if (_isExpanded) {
      if (_currentMonthIndex > 0) {
        _monthPageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (_currentWeekIndex > 0) {
        _weekPageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _goToNext() {
    if (_isExpanded) {
      if (_currentMonthIndex < _availableMonths.length - 1) {
        _monthPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (_currentWeekIndex < _availableWeeks.length - 1) {
        _weekPageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _toggleExpand([bool? forceState]) {
    final newExpanded = forceState ?? !_isExpanded;

    if (newExpanded) {
      // Haftalık → Aylık: Mevcut haftanın ayına senkronize et
      final currentWeekMonday = _availableWeeks[_currentWeekIndex];
      final midWeek = currentWeekMonday.add(const Duration(days: 3));
      final todayNorm = DateTime(_today.year, _today.month, _today.day);
      final weekEnd = currentWeekMonday.add(const Duration(days: 6));

      DateTime targetMonth;
      if (!todayNorm.isBefore(currentWeekMonday) && !todayNorm.isAfter(weekEnd)) {
        targetMonth = DateTime(_today.year, _today.month, 1);
      } else {
        targetMonth = DateTime(midWeek.year, midWeek.month, 1);
      }

      int targetIndex = _availableMonths.indexWhere((m) =>
          m.year == targetMonth.year && m.month == targetMonth.month);
      if (targetIndex == -1) targetIndex = 0;
      _currentMonthIndex = targetIndex;
    } else {
      // Aylık → Haftalık: Mevcut ayın uygun haftasına senkronize et
      final monthDate = _availableMonths[_currentMonthIndex];
      DateTime targetWeekMonday;

      if (monthDate.year == _today.year && monthDate.month == _today.month) {
        final todayWeekday = _today.weekday;
        targetWeekMonday = DateTime(_today.year, _today.month, _today.day)
            .subtract(Duration(days: todayWeekday - 1));
      } else {
        targetWeekMonday =
            monthDate.subtract(Duration(days: monthDate.weekday - 1));
      }

      int targetIndex = _availableWeeks.indexWhere((w) =>
          w.year == targetWeekMonday.year &&
          w.month == targetWeekMonday.month &&
          w.day == targetWeekMonday.day);
      if (targetIndex == -1) targetIndex = 0;
      _currentWeekIndex = targetIndex;
    }

    setState(() {
      _isExpanded = newExpanded;
      _selectedDate = null;
      _selectedIpos = null;
      _selectedDayIndex = -1;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (newExpanded) {
        if (_monthPageController.hasClients) {
          _monthPageController.jumpToPage(_currentMonthIndex);
        }
      } else {
        if (_weekPageController.hasClients) {
          _weekPageController.jumpToPage(_currentWeekIndex);
        }
      }
    });
  }

  void _closeTooltip() {
    if (_selectedIpos != null || _selectedDate != null) {
      setState(() {
        _selectedDate = null;
        _selectedIpos = null;
        _selectedDayIndex = -1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TapRegion(
      onTapOutside: (_) => _closeTooltip(),
      child: GestureDetector(
        onTap: () {
          // Takvim içindeki boş bir alana tıklandığında açık olan pop-up'ı kapat
          if (_selectedIpos != null) {
            _closeTooltip();
          }
        },
        // Takvimin herhangi bir yerinden aşağı/yukarı kaydırarak açma/kapama
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            if (details.primaryVelocity! > 150 && !_isExpanded) {
              _toggleExpand(true);
            } else if (details.primaryVelocity! < -150 && _isExpanded) {
              _toggleExpand(false);
            }
          }
        },
        behavior: HitTestBehavior.translucent,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Sol üstte tarih/ay başlığı, sağ üstte < > okları
              _buildHeader(),
              const SizedBox(height: 16),
              // Gün kısaltma başlıkları (Pt, Sa, Ça...)
              _buildDayLabels(),
              const SizedBox(height: 12),
              // Takvim Gövdesi (Haftalık/Aylık Grid + Alt Çizgi + En Üst Katmanda Pop-up)
              _buildCalendarBody(),
            ],
          ),
        ),
      ),
    );
  }

  /// Sol üst başlık:
  /// - Mevcut zamandaysa: "29 Ağu, 26 Cumartesi" (Tarih beyaz, gün adı gri)
  /// - Farklı bir aya/haftaya kaydırıldığında: Değişen ay ismi kalın yeşil ("Eyl, 26") ve gün adı kaldırılır.
  Widget _buildHeader() {
    DateTime viewedDate;
    bool isCurrentTime;

    if (_isExpanded) {
      viewedDate = _getMonthDate(_currentMonthIndex);
      isCurrentTime = viewedDate.year == _today.year && viewedDate.month == _today.month;
    } else {
      final weekStart = _getWeekStart(_currentWeekIndex);
      final weekEnd = weekStart.add(const Duration(days: 6));
      final todayNorm = DateTime(_today.year, _today.month, _today.day);
      final startNorm = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final endNorm = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);

      isCurrentTime = !todayNorm.isBefore(startNorm) && !todayNorm.isAfter(endNorm);
      viewedDate = isCurrentTime ? _today : weekStart;
    }

    final dayStr = '${_today.day}';
    final monthStr = _turkishShortMonths[viewedDate.month - 1];
    final yearStr = viewedDate.year.toString().substring(2);
    final weekdayStr = _turkishFullDays[_today.weekday - 1];

    final bool canGoPrevious =
        _isExpanded ? _currentMonthIndex > 0 : _currentWeekIndex > 0;
    final bool canGoNext = _isExpanded
        ? _currentMonthIndex < _availableMonths.length - 1
        : _currentWeekIndex < _availableWeeks.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Sol üst başlık
        if (isCurrentTime)
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$dayStr $monthStr, $yearStr',
                style: GoogleFonts.inter(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                weekdayStr,
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          )
        else
          // Farklı aya/haftaya geçildiğinde: Değişen ay ismi kalın yeşil, gün adı yok
          Text(
            '$monthStr, $yearStr',
            style: GoogleFonts.inter(
              color: AppColors.primaryGreen,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

        // Sağ üst: < > okları yan yana (sınırda pasifleşir)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: canGoPrevious ? _goToPrevious : null,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(
                  Icons.chevron_left_rounded,
                  color: canGoPrevious
                      ? AppColors.textSecondary
                      : const Color(0xFF444444),
                  size: 22,
                ),
              ),
            ),
            GestureDetector(
              onTap: canGoNext ? _goToNext : null,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: canGoNext
                      ? AppColors.textSecondary
                      : const Color(0xFF444444),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDayLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: _dayLabels.map((label) {
        return SizedBox(
          width: 38,
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Takvim Gövdesi: Haftalık (38px) veya Aylık Izgara (AnimatedSize)
  Widget _buildCalendarBody() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalWidth = constraints.maxWidth;

        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isExpanded)
                    // HAFTALIK GÖRÜNÜM
                    SizedBox(
                      height: 38,
                      child: PageView.builder(
                        controller: _weekPageController,
                        itemCount: _availableWeeks.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentWeekIndex = index;
                            _selectedDate = null;
                            _selectedIpos = null;
                            _selectedDayIndex = -1;
                          });
                        },
                        itemBuilder: (context, pageIndex) {
                          return _buildWeekRow(pageIndex);
                        },
                      ),
                    )
                  else
                    // AYLIK TAM IZGARA GÖRÜNÜMÜ (Sabit 6 satır: 278px)
                    SizedBox(
                      height: 278.0,
                      child: PageView.builder(
                        controller: _monthPageController,
                        itemCount: _availableMonths.length,
                        onPageChanged: (index) {
                          setState(() {
                            _currentMonthIndex = index;
                            _selectedDate = null;
                            _selectedIpos = null;
                            _selectedDayIndex = -1;
                          });
                        },
                        itemBuilder: (context, pageIndex) {
                          return _buildMonthGrid(pageIndex);
                        },
                      ),
                    ),
                  const SizedBox(height: 6),
                  // Alt çizgi indikatörü (Tooltip'in altında kalır)
                  _buildDragHandle(),
                ],
              ),

              // Floating Pop-up Tooltip (Tüm elemanların ve alt çizginin önünde en üst katmanda açılır)
              if (_selectedIpos != null && _selectedIpos!.isNotEmpty && _selectedDayIndex >= 0)
                Positioned(
                  top: (!_isExpanded ? 0 : _selectedRowIndex) * 48.0 + 40.0,
                  left: 0,
                  right: 0,
                  child: _buildFloatingTooltip(totalWidth),
                ),
            ],
          ),
        );
      },
    );
  }

  /// Haftalık tek satır
  Widget _buildWeekRow(int pageIndex) {
    final weekStart = _getWeekStart(pageIndex);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(7, (i) {
        final date = weekStart.add(Duration(days: i));
        final isToday = _isSameDay(date, _today);
        final normalizedDate = DateTime(date.year, date.month, date.day);
        final hasIpo = _ipoDateMap.containsKey(normalizedDate);
        final isSelected =
            _selectedDate != null && _isSameDay(date, _selectedDate!);
        final isPast = _isPastDay(date);

        return _buildDayCell(date, isToday, hasIpo, isSelected, isPast, i, rowIndex: 0);
      }),
    );
  }

  /// Aylık tam ızgara (Sabit 6 satırlı profesyonel ızgara)
  Widget _buildMonthGrid(int pageIndex) {
    final monthDate = _getMonthDate(pageIndex);
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstDay = DateTime(monthDate.year, monthDate.month, 1);
    final leadingBlanks = firstDay.weekday - 1;
    const fixedRowCount = 6;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(fixedRowCount, (rowIndex) {
        return Padding(
          padding: EdgeInsets.only(bottom: rowIndex == fixedRowCount - 1 ? 0 : 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (colIndex) {
              final cellIndex = rowIndex * 7 + colIndex;
              final dayNum = cellIndex - leadingBlanks + 1;

              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox(width: 38, height: 38);
              }

              final date = DateTime(monthDate.year, monthDate.month, dayNum);
              final isToday = _isSameDay(date, _today);
              final normalizedDate = DateTime(date.year, date.month, date.day);
              final hasIpo = _ipoDateMap.containsKey(normalizedDate);
              final isSelected =
                  _selectedDate != null && _isSameDay(date, _selectedDate!);
              final isPast = _isPastDay(date);

              return _buildDayCell(
                date,
                isToday,
                hasIpo,
                isSelected,
                isPast,
                colIndex,
                rowIndex: rowIndex,
              );
            }),
          ),
        );
      }),
    );
  }

  Widget _buildDayCell(
    DateTime date,
    bool isToday,
    bool hasIpo,
    bool isSelected,
    bool isPast,
    int dayIndex, {
    required int rowIndex,
  }) {
    Color textColor;
    Color circleColor;
    Color dotColor;

    if (isSelected) {
      // Seçili gün: Tamamen dolu yeşil daire, siyah metin ve siyah nokta
      circleColor = AppColors.primaryGreen;
      textColor = AppColors.background;
      dotColor = AppColors.background;
    } else if (isToday) {
      // Bugün (seçili değilken): Dolgusuz, yeşil metin ve yeşil nokta
      circleColor = Colors.transparent;
      textColor = AppColors.primaryGreen;
      dotColor = AppColors.primaryGreen;
    } else if (isPast) {
      // Geçmiş günler: Dolgusuz, soluk gri metin ve soluk gri nokta
      circleColor = Colors.transparent;
      textColor = _pastDayColor;
      dotColor = _pastDayColor;
    } else {
      // Normal günler: Dolgusuz, beyaz metin ve yeşil nokta
      circleColor = Colors.transparent;
      textColor = AppColors.textPrimary;
      dotColor = AppColors.primaryGreen;
    }

    return GestureDetector(
      onTap: () => _onDayTapped(date, dayIndex, rowIndex: rowIndex),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 38,
        height: 38,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: circleColor,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                '${date.day}',
                style: GoogleFonts.inter(
                  color: textColor,
                  fontSize: 14,
                  fontWeight:
                      isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              if (hasIpo)
                Positioned(
                  bottom: 4,
                  child: Container(
                    width: 4.5,
                    height: 4.5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dotColor,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Alt çizgi indikatörü (tıklayarak da açma/kapama)
  Widget _buildDragHandle() {
    return GestureDetector(
      onTap: () => _toggleExpand(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        child: Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  /// Tasarımın önünde havada açılan konuşma balonu tooltip (Günün hemen altında açılır)
  Widget _buildFloatingTooltip(double totalWidth) {
    final ipos = _selectedIpos!;
    final columnWidth = totalWidth / 7;
    final dayCenterX = columnWidth * _selectedDayIndex + columnWidth / 2;
    const arrowSize = 5.0;
    const bubbleWidth = 160.0;

    // Baloncuğun sol kenarını ekran sınırları içinde tut
    final bubbleLeft =
        (dayCenterX - bubbleWidth / 2).clamp(4.0, totalWidth - bubbleWidth - 4.0);
    // Okun baloncuk içindeki yatay konumu (tam tıklanan günün merkezine hizalanır)
    final localArrowX = (dayCenterX - bubbleLeft).clamp(12.0, bubbleWidth - 12.0);

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(left: bubbleLeft),
          child: CustomPaint(
            painter: _TooltipArrowPainter(
              arrowTipX: localArrowX,
              tooltipColor: _tooltipBg,
              arrowSize: arrowSize,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: arrowSize),
                GestureDetector(
                  onTap: _closeTooltip,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: bubbleWidth,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: _tooltipBg,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 0; i < ipos.length; i++) ...[
                          if (i > 0)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Divider(
                                color: Color(0xFF383838),
                                height: 1,
                                thickness: 1,
                              ),
                            ),
                          // 1. Satır: Hisse Kodu (Yeşil) + Fiyat (Beyaz) - Tıklanınca hisse detay sayfasına yönlendirir
                          GestureDetector(
                            onTap: () {
                              _closeTooltip();
                              context.push('/ipo/${ipos[i].symbol}');
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ipos[i].symbol,
                                  style: GoogleFonts.inter(
                                    color: AppColors.primaryGreen,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${ipos[i].price.toStringAsFixed(2).replaceAll('.', ',')} TL',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 2. Satır: Tarih rozeti (Kapsül)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              ipos[i].ipoDates ?? ipos[i].ipoDate,
                              style: GoogleFonts.inter(
                                color: const Color(0xFF9E9E9E),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Konuşma balonu üçgen ok çizici (Yukarı bakan ok)
class _TooltipArrowPainter extends CustomPainter {
  final double arrowTipX;
  final Color tooltipColor;
  final double arrowSize;

  _TooltipArrowPainter({
    required this.arrowTipX,
    required this.tooltipColor,
    required this.arrowSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = tooltipColor
      ..style = PaintingStyle.fill;

    // Üçgenin tepe noktası (arrowTipX, 0) yukarıdaki günü gösterir
    // Üçgenin alt tabanı kutunun üst kenarına oturur
    final path = Path()
      ..moveTo(arrowTipX, 0)
      ..lineTo(arrowTipX - arrowSize, arrowSize)
      ..lineTo(arrowTipX + arrowSize, arrowSize)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TooltipArrowPainter oldDelegate) {
    return oldDelegate.arrowTipX != arrowTipX ||
        oldDelegate.tooltipColor != tooltipColor ||
        oldDelegate.arrowSize != arrowSize;
  }
}
