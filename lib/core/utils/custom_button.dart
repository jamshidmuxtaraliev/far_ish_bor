import 'package:jobUp24/core/utils/utils.dart';

import 'package:flutter/material.dart';

import '../theme/jb_palette.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Widget? child;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double height;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  final EdgeInsetsGeometry? margin;
  final bool? isInProgress;
  final bool isDisabled;

  const CustomButton({
    super.key,
    required this.title,
    this.child,
    required this.onPressed,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.borderRadius = 14.0,
    this.height = 52.0,
    this.fontSize = 16,
    this.isInProgress,
    this.margin,
    this.padding,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () {
                if (isInProgress == true) return;
                clearFocus(context);
                onPressed();
              },
        style: ElevatedButton.styleFrom(
          padding: padding,
          backgroundColor: isDisabled ? context.jb.border : (backgroundColor ?? context.jb.green),
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          textStyle: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: isDisabled ? context.jb.grayLight : textColor,
            fontSize: fontSize,
          ),
        ),
        child: isInProgress == true ? CircularProgressIndicator(color: Colors.white) : child ?? Text(title, textAlign: TextAlign.center),
      ),
    );
  }
}
