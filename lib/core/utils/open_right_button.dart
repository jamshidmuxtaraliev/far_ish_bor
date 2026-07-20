import 'package:jobUp24/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class OpenRightButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Widget? suffix;
  final double borderRadius;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;

  const OpenRightButton({
    super.key,
    required this.text,
    required this.onTap,
    this.suffix,
    this.borderRadius = 12,
    this.textStyle,
    this.padding,
    this.margin,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: margin,
          decoration: BoxDecoration(color: backgroundColor ?? context.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
          padding: padding ?? const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(text, style: textStyle ?? Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 14)),
              suffix ?? const Icon(Icons.chevron_right, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
