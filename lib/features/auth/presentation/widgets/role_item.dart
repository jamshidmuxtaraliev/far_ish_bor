import 'package:far_ish_bor/core/constants/colors.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class RoleItem extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleItem({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.green.withOpacity(0.1) : Colors.white,
              border: Border.all(color: isSelected ? BUTTON_COLOR : Colors.white, width: 2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const SizedBox(width: 90),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AutoSizeText(title, maxLines: 1, style: lightTheme().textTheme.displayLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
                      AutoSizeText(subtitle, maxLines: 1, style: lightTheme().textTheme.bodyLarge),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(bottom: 0, left: 16, child: Image.asset(emoji, scale: 4, width: 70, height: 70,)),
        ],
      ),
    );
  }
}
