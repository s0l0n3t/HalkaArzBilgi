import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:halkaarzbilgi/features/home/models/ipo_model.dart';
import 'package:halkaarzbilgi/core/widgets/percentage_badge.dart';

class AllIposListItem extends StatelessWidget {
  final IpoModel ipo;

  const AllIposListItem({super.key, required this.ipo});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Navigate to stock detail
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            // Logo placeholder
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF00B856)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(Icons.close, color: Color(0xFF00B856)),
              ),
            ),
            const SizedBox(width: 12),
            // Company info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ipo.symbol,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    ipo.companyName,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    ipo.ipoDate,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Price & badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${ipo.price.toStringAsFixed(2).replaceAll('.', ',')} TL',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (ipo.changePercent != null) ...[
                  const SizedBox(height: 4),
                  PercentageBadge(
                    percent: ipo.changePercent!,
                    isGain: ipo.isGain,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
