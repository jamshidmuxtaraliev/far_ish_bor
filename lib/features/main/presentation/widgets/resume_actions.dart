import 'dart:io';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../../../core/utils/utils.dart';

/// Yuklab olingan rezyume bilan ishlash: ochish / ulashish / natija oynasi.
///
/// Fayl ilovaning o'z hujjatlar papkasida saqlanadi — Android/iOS'da hech qanday
/// ruxsat kerak emas. Foydalanuvchi "Ulashish" orqali xohlagan joyiga saqlaydi.
class ResumeActions {
  const ResumeActions._();

  static Future<void> open(BuildContext context, String path) async {
    if (!await File(path).exists()) {
      if (context.mounted) {
        await showError(context, "Fayl topilmadi, qaytadan yuklab oling");
      }
      return;
    }
    final result = await OpenFilex.open(path);
    if (result.type != ResultType.done && context.mounted) {
      await showError(
        context,
        result.type == ResultType.noAppToOpen
            ? "PDF ochadigan dastur topilmadi"
            : (result.message.isEmpty ? "Faylni ochib bo'lmadi" : result.message),
      );
    }
  }

  static Future<void> share(BuildContext context, String path) async {
    // iPad'da ulashish oynasi qaysi nuqtadan chiqishini bilishi kerak — hozir,
    // widget hali ekranda turganida o'lchab olamiz.
    final origin = originOf(context);
    if (!await File(path).exists()) {
      if (context.mounted) {
        await showError(context, "Fayl topilmadi, qaytadan yuklab oling");
      }
      return;
    }
    await Share.shareXFiles(
      [XFile(path, mimeType: 'application/pdf')],
      text: 'Mening rezyumem',
      sharePositionOrigin: origin,
    );
  }

  /// Ulashish oynasining iPad uchun boshlanish to'rtburchagi.
  static Rect? originOf(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  static Future<void> _shareAt(
    BuildContext context,
    String path,
    Rect? origin,
  ) async {
    if (!await File(path).exists()) {
      if (context.mounted) {
        await showError(context, "Fayl topilmadi, qaytadan yuklab oling");
      }
      return;
    }
    await Share.shareXFiles(
      [XFile(path, mimeType: 'application/pdf')],
      text: 'Mening rezyumem',
      sharePositionOrigin: origin,
    );
  }

  /// Yuklab olingandan keyingi bottom-sheet: Ochish / Ulashish.
  static void showReadySheet(BuildContext context, String path) {
    final filename = path.split('/').last;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: JB_BORDER,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                const SizedBox(height: 18),
                const JBIconTile(
                  icon: Icons.check_circle_outline,
                  bg: JB_GREEN_BG,
                  fg: JB_GREEN_FG,
                  size: 52,
                  radius: 18,
                  iconSize: 26,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Rezyume yuklab olindi',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: JB_INK,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  filename,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12.5, color: JB_GRAY),
                ),
                const SizedBox(height: 20),
                JBPillButton(
                  label: 'Ochish',
                  leadingIcon: Icons.open_in_new,
                  expand: true,
                  elevated: true,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    open(context, path);
                  },
                ),
                const SizedBox(height: 10),
                Builder(
                  builder: (buttonContext) => JBPillButton(
                    label: 'Ulashish',
                    leadingIcon: Icons.ios_share,
                    variant: JBBtnVariant.outline,
                    expand: true,
                    onTap: () {
                      // Origin'ni pop'dan oldin o'lchaymiz.
                      final origin = originOf(buttonContext);
                      Navigator.pop(sheetContext);
                      _shareAt(context, path, origin);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
