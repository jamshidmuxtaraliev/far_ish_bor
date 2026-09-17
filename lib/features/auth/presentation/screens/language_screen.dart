import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'stats_screen.dart';
import '../../../../core/theme/jb_palette.dart';
import '../../../../core/theme/jb_ui.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  void _select(BuildContext context, String lang) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => StatsScreen(language: lang)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.card,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Tungi rejimda qora "JOB" grafit kartada yo'qolmasin —
                  // `JBLogo` o'zi oq plashka qo'yadi.
                  const JBLogo(size: 180),
                  const SizedBox(height: 24),
                  Text('Choose Language / Tilni tanlang', style: TextStyle(fontSize: 14, color: context.jb.gray), textAlign: TextAlign.center),
                  const SizedBox(height: 48),
                  _LangCard(flag: '🇺🇿', title: "O'zbekcha", subtitle: 'Uzbek', onTap: () => _select(context, 'uz')),
                  const SizedBox(height: 16),
                  _LangCard(flag: '🇷🇺', title: 'Русский', subtitle: 'Russian', onTap: () => _select(context, 'ru')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LangCard extends StatelessWidget {
  final String flag;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _LangCard({required this.flag, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.jb.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.jb.border, width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.jb.ink)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 13, color: context.jb.gray)),
              ],
            ),
            const Spacer(),
            Icon(Icons.chevron_right, color: context.jb.gray),
          ],
        ),
      ),
    );
  }
}
