import 'dart:ui';

import 'package:far_ish_bor/core/extensions/extensions.dart';
import 'package:far_ish_bor/core/utils/custom_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cherry_toast/cherry_toast.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../features/auth/data/datasource/local/user_local_data_source.dart';
import '../../generated/assets.dart';
import '../constants/colors.dart';
import '../constants/constants.dart';
import '../services/get_it.dart';
import 'gradient_gold_button.dart';

// calculate User years old from birthdate
int calculateAge(String isoDateString) {
  final birthDate = DateTime.parse(isoDateString);
  final today = DateTime.now();
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month || (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age;
}

int roleId() {
  return -1;
}

String keywordByRole(String keyword) {
  int rId = roleId();
  if (rId == 1) {
    return "/$keyword";
  } else if (rId == 2) {
    return "/${keyword}Teacher";
  } else if (rId == 3) {
    return "/${keyword}Student";
  } else if (rId == 4) {
    return "/${keyword}Parent";
  } else {
    return keyword;
  }
}

String roleById({int? inititalRoleId}) {
  int rId = inititalRoleId ?? roleId();
  if (rId == 1) {
    return "Администратор";
  } else if (rId == 2) {
    return "Учитель";
  } else if (rId == 3) {
    return "Ученик";
  } else if (rId == 4) {
    return "Родитель";
  } else {
    return '';
  }
}

Color getBallColor(double score) {
  if (score >= 4.5) {
    return Colors.green;
  } else if (score < 4.5 && score >= 4) {
    return Colors.orange;
  } else {
    return Colors.red;
  }
}

String getDayName(int raqam) {
  return switch (raqam) {
    1 => "Понедельник",
    2 => "Вторник",
    3 => "Среда",
    4 => "Четверг",
    5 => "Пятница",
    6 => "Суббота",
    7 => "Воскресенье",
    _ => "", // Default holat
  };
}

String getDayTime(int raqam) {
  if (raqam < 1 || raqam > 7) {
    return "Xato! 1 dan 7 gacha raqam kiriting.";
  }

  // Hafta kunlari ro'yxati
  List<String> kunNomlari = ["Понедельник", "Вторник", "Среда", "Четверг", "Пятница", "Суббота"];

  // Hozirgi vaqtni olamiz
  DateTime hozir = DateTime.now();

  // Joriy haftaning dushanba kunini topamiz
  // weekday: 1 (Dushanba) dan 7 (Yakshanba) gacha qaytaradi
  DateTime dushanba = hozir.subtract(Duration(days: hozir.weekday - 1));

  // Tanlangan kunga mos sanani hisoblaymiz
  DateTime tanlanganKun = dushanba.add(Duration(days: raqam - 1));

  // Sanani formatlaymiz (masalan: 26.01.2026)
  String sana =
      "${tanlanganKun.day.toString().padLeft(2, '0')}."
      "${tanlanganKun.month.toString().padLeft(2, '0')}."
      "${tanlanganKun.year}";

  return sana;
}

void copyClippBoard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Скопировано в буфер обмена'), duration: Duration(seconds: 2)));
}

void clearFocus(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode()); //remove focus
}

String getCurrentDateTime() {
  var now = DateTime.now();
  var formatter = DateFormat('yyyy.MM.dd');
  String formattedDate = formatter.format(now);
  print(formattedDate); // 2016-01-25
  return formattedDate;
}

double getScreenHeight(context) {
  return MediaQuery.of(context).size.height;
}

double getScreenWidth(context) {
  return MediaQuery.of(context).size.width;
}

Future startScreen(BuildContext context, {required StatefulWidget screen}) {
  return Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

Future startScreenSS(BuildContext context, {required StatelessWidget screen}) {
  return Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
}

/// push and remove all previous screens
Future startScreenPR(BuildContext context, {required Widget screen}) {
  return Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => screen), (route) => false);
}

@optionalTypeArgs
void finish<T extends Object?>(BuildContext context, [T? result]) {
  return Navigator.of(context).pop<T>(result);
}

String getFileName(String filePath) {
  return filePath.substring(filePath.lastIndexOf('/') + 1, filePath.length);
}

TextStyle customTextStyle({
  String? fontFamily,
  Color? color,
  double? size,
  double? spacing,
  FontWeight? fontWeight,
  List<Shadow>? shadow,
  TextOverflow? overflow,
}) {
  color = color ?? WHITE;
  fontWeight = fontWeight ?? FontWeight.normal;
  return TextStyle(
    color: color,
    fontSize: size ?? 14,
    letterSpacing: spacing,
    fontFamily: fontFamily ?? SFPRODISPLAY,
    shadows: shadow,
    overflow: overflow,
    fontWeight: fontWeight,
  );
}

Future<void> showError(BuildContext context, String message, {Function? pressOk, String? okButtonTitle}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: BUTTON_COLOR.withAlpha(10), //this works
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.center,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
                      const SizedBox(width: 24),
                      Text("Ошибка !", style: customTextStyle(color: Colors.white, size: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: customTextStyle(color: Colors.white, fontFamily: SFPRODISPLAY),
                        maxLines: 10,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      20.height,
                      CustomButton(
                        title: okButtonTitle ?? "OK",
                        onPressed: () {
                          if (pressOk != null) {
                            pressOk();
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        // textSize: 14,
                        // borderRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Future<void> showWarning(BuildContext context, String message, {Function? pressOk}) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: BUTTON_COLOR.withAlpha(10), //this works
    builder: (BuildContext context) {
      return Align(
        alignment: Alignment.center,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaY: 10, sigmaX: 10),
          child: Scaffold(
            backgroundColor: Colors.black.withOpacity(0.5),
            body: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 16),
                      const Icon(Icons.warning_rounded, size: 50, color: Colors.orange),
                      const SizedBox(width: 24),
                      Text(context.l10n.warning, style: customTextStyle(color: Colors.white, size: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        message,
                        style: customTextStyle(color: Colors.white, fontFamily: SFPRODISPLAY),
                        maxLines: 10,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      20.height,
                      CustomButton(
                        title: "OK",
                        onPressed: () {
                          if (pressOk != null) {
                            pressOk();
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);
                          }
                        },
                        // textSize: 14,
                        // borderRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

void showSuccess(BuildContext context, String message) {
  CherryToast.success(
    animationDuration: const Duration(milliseconds: 500),
    title: Text(message, style: TextStyle(color: Colors.black)),
  ).show(context);
}

Future<void> launchPhoneDialer(String phoneNumber) async {
  final Uri url = Uri.parse('tel:$phoneNumber');
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Telefon raqamni ochib bo‘lmadi: $phoneNumber';
  }
}

Future<void> launchInBrowser(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
    throw 'Havolani ochib bo‘lmadi: $url';
  }
}

/// Kamera/Galereya tanlash bottom-sheeti. Rasm tanlangach `XFile` qaytaradi,
/// bekor qilinsa `null`.
Future<XFile?> pickImageWithSourceSheet(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined, color: PRIMARY_BLUE),
            title: const Text('Kamera'),
            onTap: () => Navigator.pop(ctx, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined, color: PRIMARY_BLUE),
            title: const Text('Galereya'),
            onTap: () => Navigator.pop(ctx, ImageSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
  if (source == null) return null;
  return ImagePicker().pickImage(source: source, imageQuality: 85, maxWidth: 1080);
}

Future<void> checkCameraPermissionAndStartScanner(BuildContext context, Function func) async {
  var status = await Permission.camera.status;

  if (status.isGranted) {
    func();
  } else if (status.isDenied) {
    if (await Permission.camera.request().isGranted) {
      func();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kameraga ruxsat berilmadi. Iltimos, ruxsatni yoqing.')));
    }
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  }
}
