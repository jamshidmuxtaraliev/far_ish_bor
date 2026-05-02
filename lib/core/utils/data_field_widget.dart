import 'package:far_ish_bor/core/extensions/extensions.dart';
import 'package:far_ish_bor/core/utils/utils.dart';

import 'package:flutter/material.dart';

class DataFieldWidget extends StatelessWidget {
  final String title;
  final String hint;
  final String value;

  const DataFieldWidget({super.key, required this.title, required this.hint, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != '') Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (title != '') 8.height,
        Container(
          width: getScreenWidth(context),
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF161616),
            border: Border.all(color: const Color(0xFF8A6C3A)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: title != '' ? Colors.white : Colors.grey),
          ),
        ),
      ],
    );
  }
}
