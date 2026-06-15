import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/vacancy_model.dart';

class VacancyJobCard extends StatelessWidget {
  final VacancyModel vacancy;
  final VoidCallback? onTap;

  const VacancyJobCard({super.key, required this.vacancy, this.onTap});

  @override
  Widget build(BuildContext context) {
    final match = vacancy.matchPercent;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
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
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                      ),
                      const SizedBox(height: 4),
                      Text(vacancy.companyName ?? '', style: const TextStyle(fontSize: 14, color: GRAY_TEXT)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: LIGHT_GRAY_BG, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.business_outlined, color: GRAY_TEXT, size: 24),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (vacancy.companyAddress != null) ...[
                  const Icon(Icons.location_on_outlined, size: 15, color: GRAY_TEXT),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      vacancy.companyAddress!,
                      style: const TextStyle(fontSize: 13, color: GRAY_TEXT),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 14),
                ],
                const Icon(Icons.attach_money, size: 15, color: GRAY_TEXT),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(vacancy.salaryDisplay, style: const TextStyle(fontSize: 13, color: GRAY_TEXT), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                if (match > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: match >= 80 ? GREEN_COLOR.withValues(alpha: 0.12) : PRIMARY_BLUE.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome_rounded, size: 12, color: match >= 80 ? GREEN_COLOR : PRIMARY_BLUE),
                        const SizedBox(width: 4),
                        Text(
                          '$match% mos',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: match >= 80 ? GREEN_COLOR : PRIMARY_BLUE),
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Ariza berish', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
