import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:halkaarzbilgi/core/theme/app_colors.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';

class IpoResultsSection extends StatelessWidget {
  final List<IpoDistributionResult>? distributionResults;
  final List<IpoDistributionResult>? demandResults;
  final String? perPersonLot;

  const IpoResultsSection({
    super.key,
    this.distributionResults,
    this.demandResults,
    this.perPersonLot,
  });

  @override
  Widget build(BuildContext context) {
    final hasDistribution =
        distributionResults != null && distributionResults!.isNotEmpty;
    final hasDemand = demandResults != null && demandResults!.isNotEmpty;

    if (!hasDistribution && !hasDemand) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halka Arz Sonuçları',
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        // ── 1. Talep Tablosu ────────────────────────────────────────
        if (hasDemand) ...[
          _buildTable(
            headerTitle: 'Talep',
            col1Title: 'Yatırımcı Sayısı',
            col2Title: 'Nominal Değer (TL)',
            col3Title: 'Oran',
            results: demandResults!,
          ),
        ],
        // ── 2. Dağıtım Tablosu ──────────────────────────────────────
        if (hasDistribution) ...[
          if (hasDemand) const SizedBox(height: 20),
          _buildTable(
            headerTitle: 'Dağıtım',
            col1Title: 'Kişi',
            col2Title: 'Lot',
            col3Title: 'Oran',
            results: distributionResults!,
          ),
          if (perPersonLot != null && perPersonLot!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '* Kişi Başına Düşen: $perPersonLot',
                style: GoogleFonts.inter(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildTable({
    required String headerTitle,
    required String col1Title,
    required String col2Title,
    required String col3Title,
    required List<IpoDistributionResult> results,
  }) {
    final borderSide = BorderSide(color: AppColors.border, width: 0.5);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // ── Header Row: Unified Left Cell + Stacked Right Top/Bottom ──
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left cell: "Yatırımcı Grubu"
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(right: borderSide, bottom: borderSide),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Yatırımcı Grubu',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                // Right column: Top title ("Dağıtım" / "Talep") + Subheaders
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border(bottom: borderSide),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        alignment: Alignment.center,
                        child: Text(
                          headerTitle,
                          style: GoogleFonts.inter(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(bottom: borderSide),
                        ),
                        child: Row(
                          children: [
                            _buildSubHeaderCell(col1Title, 2, borderSide, false),
                            _buildSubHeaderCell(col2Title, 3, borderSide, false),
                            _buildSubHeaderCell(col3Title, 2, borderSide, true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Data Rows ──────────────────────────────────────────────
          ...results.asMap().entries.map((entry) {
            final index = entry.key;
            final result = entry.value;
            final isLast = index == results.length - 1;

            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Investor Group name (flex: 3)
                  Expanded(
                    flex: 3,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: borderSide,
                          bottom: isLast ? BorderSide.none : borderSide,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        result.investorGroup,
                        style: GoogleFonts.inter(
                          color: result.isTotal
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: result.isTotal
                              ? FontWeight.bold
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  // Col 1 (flex: 2)
                  _buildDataCell(
                    result.personCount,
                    result.isTotal,
                    borderSide,
                    flex: 2,
                    showBottomBorder: !isLast,
                    showRightBorder: true,
                  ),
                  // Col 2 (flex: 3)
                  _buildDataCell(
                    result.lotCount,
                    result.isTotal,
                    borderSide,
                    flex: 3,
                    showBottomBorder: !isLast,
                    showRightBorder: true,
                  ),
                  // Col 3 (flex: 2)
                  _buildDataCell(
                    result.ratio,
                    result.isTotal,
                    borderSide,
                    flex: 2,
                    showBottomBorder: !isLast,
                    showRightBorder: false,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSubHeaderCell(
    String label,
    int flex,
    BorderSide borderSide,
    bool isLast,
  ) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: isLast ? BorderSide.none : borderSide,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(
    String value,
    bool isBold,
    BorderSide borderSide, {
    required int flex,
    required bool showBottomBorder,
    required bool showRightBorder,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            right: showRightBorder ? borderSide : BorderSide.none,
            bottom: showBottomBorder ? borderSide : BorderSide.none,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        alignment: Alignment.center,
        child: Text(
          value,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
