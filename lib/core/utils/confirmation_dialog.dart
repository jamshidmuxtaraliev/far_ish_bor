import 'dart:ui';

import 'package:jobUp24/core/extensions/extensions.dart';
import 'package:jobUp24/core/utils/utils.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String description;
  final String cancelText;
  final String okText;
  Function onTapCancel;
  Function onTapConfirm;
  Widget? additionalWidget;
  Color? oktextColor;

  ConfirmationDialog({
    super.key,
    required this.title,
    required this.description,
    required this.cancelText,
    required this.okText,
    required this.onTapCancel,
    required this.onTapConfirm,
    this.additionalWidget,
    this.oktextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 8, sigmaX: 8),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(color: context.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  24.height,
                  Text(title, style: context.textTheme.headlineLarge?.copyWith(fontSize: 20, height: 1)),
                  12.height,
                  Text(description, style: context.textTheme.bodyLarge?.copyWith(fontSize: 14)),
                  if (additionalWidget != null) 16.height,
                  if (additionalWidget != null) additionalWidget!,
                  50.height,
                  Row(
                    children: [
                      Spacer(),
                      TextButton(onPressed: () => onTapCancel(), child: Text(cancelText, style: context.textTheme.labelLarge)),
                      TextButton(
                        onPressed: () => onTapConfirm(),
                        child: Text(okText, style: context.textTheme.labelLarge?.copyWith(color: oktextColor ?? BUTTON_COLOR)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
