import 'package:far_ish_bor/core/services/get_it.dart';
import 'package:far_ish_bor/core/theme/theme_cubit.dart';
import 'package:far_ish_bor/generated/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// extension for get texttheme
/// example: context.textTheme.headlineMedium
extension BuildContextExtensions on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  bool get isDarkMode => getIt<ThemeCubit>().state == ThemeMode.dark;

  S get l10n => S.of(this);
}

extension SizedBoxExtensions on int {
  Widget get height => SizedBox(height: toDouble());

  Widget get width => SizedBox(width: toDouble());
}

extension StringDateFormat on String {
  /// ISO yoki "yyyy-MM-dd..." formatidagi stringni "dd.MM.yyyy" ga o'giradi.
  /// Misol: "2026-04-14T10:30:00" → "14.04.2026"
  String toFormattedDate() {
    try {
      final date = DateTime.parse(this);
      return DateFormat('dd.MM.yyyy').format(date);
    } catch (_) {
      return this;
    }
  }

  /// "dd.MM.yyyy HH:mm" formatida qaytaradi.
  /// Misol: "2026-04-14T10:30:00" → "14.04.2026 10:30"
  String toFormattedDateTime() {
    try {
      final date = DateTime.parse(this);
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (_) {
      return this;
    }
  }
}

extension CustomStringCapitalize on String {
  String getShortName() => isNotEmpty ? trim().split(' ').map((l) => l.characters.firstOrNull?.toUpperCase() ?? "").take(3).join() : '';
}

extension CustomDouble on double {
  String formattedAmountString() {
    return NumberFormat('#,##0.##', 'uz').format(this);
  }
}

extension StringParsing on String {
  double toDoubleOrZero() {
    try {
      return double.parse(this);
    } catch (_) {
      return 0.0;
    }
  }
}

extension CustomInt on int {
  String formattedAmount({bool? withSymbol}) {
    withSymbol = withSymbol ?? true;
    var summa = _thousandDecimalFormat(toDouble());
    if (withSymbol) {
      summa = summa;
    }
    return summa;
  }

  double fixed({int? fix}) {
    fix ??= 2;
    return double.parse(toStringAsFixed(fix));
  }
}

extension CustomStringAmount on String {
  String formattedAmount({bool? withSymbol}) {
    withSymbol ??= true;
    var summa = _thousandDecimalFormat(parseToDouble());
    if (withSymbol) {
      summa = summa + (" so‘m");
    }
    return summa;
  }

  double parseToDouble() {
    try {
      String cleaned = replaceAll(' ', '');
      cleaned = cleaned.replaceAll(',', '.');
      cleaned = cleaned.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(cleaned);
    } catch (e) {
      return 0.0;
    }
  }

  String phoneFormatter() {
    if (isEmpty) {
      return this;
    }
    var sb = StringBuffer();
    var temp = StringBuffer(toString());

    if (temp.length >= 9) {
      var phone = temp.toString().substring(temp.length - 9, temp.length);
      var chars = phone.replaceAll(RegExp(r'\D+'), '').split('');
      sb.write("+998 (");
      for (int i = 0; i < chars.length; i++) {
        switch (i) {
          case 2:
            sb.write(") ");
            break;
          case 5:
            sb.write(" ");
            break;
          case 7:
            sb.write(" ");
            break;
        }
        sb.write(chars[i]);
      }
      return sb.toString();
    } else {
      return toString();
    }
  }

  String phoneReplace() {
    return replaceAll(" ", "").replaceAll("(", "").replaceAll(")", "").replaceAll("-", "");
  }
}

String _thousandDecimalFormat(double? value) {
  var afterDot = 2;

  var num = value.toString();
  var numberDecimal = num.substring(num.indexOf('.') + 1);
  final numberInteger = List.from(num.substring(0, num.indexOf('.')).split(''));
  int index = numberInteger.length - 3;
  while (index > 0) {
    numberInteger.insert(index, ' ');
    index -= 3;
  }
  if (numberDecimal.length > afterDot) {
    numberDecimal = numberDecimal.substring(0, afterDot);
  }
  return int.parse(numberDecimal) > 0 ? "${numberInteger.join()}.$numberDecimal" : numberInteger.join();
}

enum DeviceType { Phone, Tablet }

DeviceType getDeviceType() {
  final data = MediaQueryData.fromView(WidgetsBinding.instance.window);
  return data.size.shortestSide < 550 ? DeviceType.Phone : DeviceType.Tablet;
}

extension FirstWhereOrNullExtension<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
