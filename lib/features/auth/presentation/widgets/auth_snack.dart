import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/auth_flow_models.dart';
import '../../../../core/theme/jb_palette.dart';

/// Auth oqimidagi xabarlar uchun yagona snackbar.
///
/// [actionLabel] berilsa yonida tugma chiqadi — SMS ketmagan holatda
/// "Telegram orqali" muqobilini taklif qilish uchun.
void showAuthSnack(
  BuildContext context,
  String message, {
  bool isError = true,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade600 : context.jb.ink,
        duration: const Duration(seconds: 5),
        action: (actionLabel != null && onAction != null)
            ? SnackBarAction(label: actionLabel, textColor: Colors.white, onPressed: onAction)
            : null,
      ),
    );
}

/// `via: "none"` — kod hech qayerga ketmadi. Bot bilan bog'lanmagan bo'lsa
/// deep-link taklif qilinadi.
void showSendCodeChannelHint(BuildContext context, SendCodeModel info, {required bool isUz}) {
  if (info.via != 'none') return;

  final link = info.botLink;
  final message = switch (info.reason) {
    'not_linked' => isUz
        ? 'Raqamingiz Telegram botga bog\'lanmagan'
        : 'Ваш номер не привязан к Telegram-боту',
    'bot_blocked' => isUz
        ? 'Telegram bot bloklangan — blokdan chiqaring'
        : 'Telegram-бот заблокирован — разблокируйте его',
    _ => isUz ? 'Kod yuborilmadi — qayta urinib ko\'ring' : 'Код не отправлен — попробуйте снова',
  };

  showAuthSnack(
    context,
    message,
    actionLabel: link == null ? null : (isUz ? 'Botni ochish' : 'Открыть бота'),
    onAction: link == null
        ? null
        : () => launchUrl(Uri.parse(link), mode: LaunchMode.externalApplication),
  );
}
