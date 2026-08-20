import 'package:flutter/material.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../data/models/vacancy_model.dart';
import '../../../../core/theme/jb_palette.dart';

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
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: context.jb.ink),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      vacancy.companyName ?? '',
                      style: TextStyle(fontSize: 13.5, color: context.jb.gray),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(color: context.jb.chipBg, borderRadius: BorderRadius.circular(11)),
                alignment: Alignment.center,
                child: Icon(Icons.grid_view_rounded, color: context.jb.gray, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.payments_outlined, size: 15, color: context.jb.grayLight),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  vacancy.salaryDisplay,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: context.jb.ink),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (vacancy.companyAddress != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 15, color: context.jb.grayLight),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    vacancy.companyAddress!,
                    style: TextStyle(fontSize: 13, color: context.jb.gray),
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
