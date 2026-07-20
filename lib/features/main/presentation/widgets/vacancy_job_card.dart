import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../data/models/vacancy_model.dart';

/// Job card used across Home (Tavsiya etilgan), Jobs list and Saved.
/// Matches the Jobup24 design: white soft-shadow card, green match badge and a
/// blue "Ariza berish" pill.
class VacancyJobCard extends StatelessWidget {
  final VacancyModel vacancy;
  final VoidCallback? onTap;
  final VoidCallback? onApply;

  const VacancyJobCard({super.key, required this.vacancy, this.onTap, this.onApply});

  @override
  Widget build(BuildContext context) {
    final match = vacancy.matchPercent;
    return JBCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vacancy.jobTypeName ?? "Kasb ko'rsatilmagan",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: JB_INK),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vacancy.companyName ?? '',
                      style: const TextStyle(fontSize: 13.5, color: JB_GRAY),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: JB_CHIP_BG, borderRadius: BorderRadius.circular(11)),
                alignment: Alignment.center,
                child: const Icon(Icons.grid_view_rounded, color: JB_GRAY, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 15, color: JB_GRAY_LIGHT),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  vacancy.salaryDisplay,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: JB_INK),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (vacancy.companyAddress != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 15, color: JB_GRAY_LIGHT),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    vacancy.companyAddress!,
                    style: const TextStyle(fontSize: 13, color: JB_GRAY),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (match > 0) JBMatchBadge(percent: match) else const SizedBox.shrink(),
              JBPillButton(
                label: 'Ariza berish',
                onTap: onApply ?? onTap,
                vPadding: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
