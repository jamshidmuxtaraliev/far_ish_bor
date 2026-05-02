import 'package:far_ish_bor/core/constants/colors.dart';
import 'package:far_ish_bor/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LanguageItem extends StatelessWidget {
  final String title;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const LanguageItem({super.key, required this.title, required this.flag, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? BUTTON_COLOR.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? BUTTON_COLOR : Colors.white, width: 2),
        ),
        child: Row(
          children: [
            Text(flag, style: lightTheme().textTheme.displayLarge),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: lightTheme().textTheme.displayLarge?.copyWith(fontSize: 20, fontWeight: FontWeight.w600)),
            ),
            if (isSelected) const Icon(Icons.check, color: Colors.green, size: 24),
          ],
        ),
      ),
    );
  }
}
