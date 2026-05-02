import 'package:far_ish_bor/core/extensions/extensions.dart';
import 'package:far_ish_bor/generated/assets.dart';
import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  final String? hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;

  const SearchField({super.key, this.hintText, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: context.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Image.asset(Assets.iconsSearch, color: Colors.grey, scale: 4),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hintText ?? context.l10n.searchShort,
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
