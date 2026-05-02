
import 'package:far_ish_bor/core/utils/utils.dart';
import 'package:flutter/material.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';

class GoldenGradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool? isInProgress;
  final double? width;
  final double? height;
  final double? textSize;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? bgColor;

  const GoldenGradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isInProgress,
    this.width,
    this.height,
    this.textSize,
    this.margin,
    this.padding,
    this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? const EdgeInsets.all(0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (isInProgress != true) {
              onPressed();
            }
          },
          child: Container(
            height: height,
            padding: padding ?? const EdgeInsets.all(10),
            width: width ?? getScreenWidth(context),
            decoration: BoxDecoration(
              color: bgColor,
              gradient:
                  bgColor == null
                      ? const LinearGradient(
                        colors: [
                          Color(0xFFB57C32), // gold left
                          Color(0xFFE8C46C), // gold center
                          Color(0xFFB57C32), // gold right
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      )
                      : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child:
                  isInProgress == true
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                        text,
                        style: TextStyle(
                          fontSize: textSize ?? 24,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontFamily: SourceSerifPro,
                        ),
                      ),
            ),
          ),
        ),
      ),
    );
  }
}

//======================================================================================================================

class OutlinedGoldenButton extends StatelessWidget {
  final String text;
  final bool? isInProgress;
  final VoidCallback onPressed;

  const OutlinedGoldenButton({super.key, required this.text, required this.onPressed,  this.isInProgress});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (isInProgress != true) {
          onPressed();
        }
      },
      child: Container(
        width: getScreenWidth(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 2,
            color: Colors.transparent, // kerak emas, gradient uchun
          ),
          gradient: const LinearGradient(
            colors: [Color(0xFFB57C32), Color(0xFFE8C46C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Container(
          width: getScreenWidth(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF004C66), // tugma ichi (orqa fon)
          ),
          padding: const EdgeInsets.all(10),
          child: Center(
            child:
                isInProgress==true
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                      text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFF3C85C),
                        fontFamily: SourceSerifPro,
                      ),
                    ),
          ),
        ),
      ),
    );
  }
}
