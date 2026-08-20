import 'package:flutter/material.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../../../core/theme/jb_palette.dart';

class EmptyView extends StatelessWidget {
  final String message;
  final String? subtitle;
  final IconData icon;
  final Widget? action;

  const EmptyView({
    super.key,
    required this.message,
    this.subtitle,
    this.icon = Icons.people_outline,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: context.jb.blueTint,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 34, color: context.jb.blue),
            ),
            const SizedBox(height: 18),
            Text(message,
                style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: context.jb.ink),
                textAlign: TextAlign.center),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  style: TextStyle(
                      fontSize: 13, color: context.jb.gray, height: 1.4),
                  textAlign: TextAlign.center),
            ],
            if (action != null) ...[
              const SizedBox(height: 16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: context.jb.redBg,
                borderRadius: BorderRadius.circular(24),
              ),
              alignment: Alignment.center,
              child: Icon(Icons.cloud_off_rounded,
                  size: 34, color: context.jb.red),
            ),
            const SizedBox(height: 18),
            Text(message,
                style: TextStyle(
                    fontSize: 14, color: context.jb.gray, height: 1.4),
                textAlign: TextAlign.center),
            const SizedBox(height: 18),
            JBPillButton(
              label: 'Qayta urinish',
              leadingIcon: Icons.refresh_rounded,
              onTap: onRetry,
              vPadding: 12,
            ),
          ],
        ),
      ),
    );
  }
}
