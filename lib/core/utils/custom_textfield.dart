import 'package:jobUp24/core/extensions/extensions.dart';
import 'package:jobUp24/core/theme/app_theme.dart';
import 'package:jobUp24/core/utils/thousands_formatter.dart';
import 'package:jobUp24/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/colors.dart';
import '../constants/constants.dart';

class CustomTextField extends StatelessWidget {
  final String title;
  final String hint;
  final String? subTitle;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final TextEditingController? controller;
  final TextInputType? inputType;
  final Color? cursorColor;
  final Color? fillColor;
  final double? textFieldHeight;
  final double? textSize;
  final double? borderWidth;
  final int? maxLine;
  final int? minLine;
  final TextInputAction? textInputAction;
  final TextCapitalization? textCapitalization;
  final bool thousandFormat;
  final bool obscureText;
  final bool enabled;
  final bool? readOnly;
  final Function(String)? onChanged;
  final Function()? onClick;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final Widget? suffixIcon;
  final TextStyle? hintStyle;
  final TextInputFormatter? textInputFormatter;
  final bool autoFocus;

  const CustomTextField({
    super.key,
    required this.title,
    required this.hint,
    this.subTitle,
    this.padding,
    this.contentPadding,
    this.controller,
    this.inputType,
    this.cursorColor,
    this.fillColor,
    this.textFieldHeight,
    this.textSize,
    this.borderWidth,
    this.maxLine,
    this.minLine,
    this.textInputAction,
    this.textCapitalization,
    this.thousandFormat = false,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly,
    this.onChanged,
    this.onClick,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.suffixIcon,
    this.hintStyle,
    this.textInputFormatter,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? const EdgeInsets.all(0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title.isNotEmpty)
            Row(
              children: [
                8.width,
                Expanded(child: Text(title, style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, fontWeight: FontWeight.w400))),
                if (subTitle != null)
                  Text(
                    subTitle!,
                    style: const TextStyle(fontFamily: 'Montserrat', fontSize: 12, color: Color(0xFF7A7A83), fontWeight: FontWeight.w400),
                  ),
              ],
            ),
          if (title.isNotEmpty) const SizedBox(height: 4),
          SizedBox(
            child: TextFormField(
              readOnly: readOnly ?? false,
              cursorColor: cursorColor ?? Theme.of(context).iconTheme.color,
              autofocus: autoFocus,
              textCapitalization: textCapitalization ?? TextCapitalization.sentences,
              controller: controller,
              onTapOutside: (event) => clearFocus(context),
              onTap: () {
                onClick?.call();
                if (controller != null && controller!.text == "0.0") {
                  controller!.selection = TextSelection(baseOffset: 0, extentOffset: controller!.text.length);
                }
              },
              onChanged: onChanged,
              style: TextStyle(fontFamily: SFPRODISPLAY, fontSize: textSize ?? 14, fontWeight: FontWeight.w400),
              textInputAction: textInputAction ?? TextInputAction.next,
              keyboardType: inputType,
              obscureText: obscureText,
              maxLines: maxLine,
              minLines: minLine,
              enabled: enabled,
              inputFormatters:
                  textInputFormatter != null
                      ? [textInputFormatter!]
                      : thousandFormat
                      ? [FilteringTextInputFormatter.deny(RegExp('[^0-9. ]')), ThousandsSeparatorInputFormatter()]
                      : [],

              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                isDense: true,
                // vertical paddingni kamaytiradi
                filled: true,
                enabledBorder: border(context, borderWidth: borderWidth),
                disabledBorder: border(context, borderWidth: borderWidth),
                focusedBorder: border(context, borderWidth: borderWidth),

                prefixIcon: prefixIcon,
                prefix: prefix,
                suffixIcon: suffixIcon,
                suffix: suffix,
                fillColor: fillColor ?? context.colorScheme.primaryContainer,
                hintStyle: hintStyle ?? lightTheme().textTheme.bodyLarge?.copyWith(fontSize: 14, color: GREY_TEXT_9696),
                hintText: hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

OutlineInputBorder border(BuildContext context, {double? borderWidth}) => OutlineInputBorder(
  borderRadius: BorderRadius.circular(14),
  borderSide: BorderSide(width: borderWidth ?? 1, color: context.colorScheme.primaryContainer),
);
