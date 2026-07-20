import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jobUp24/core/utils/utils.dart';
import '../../../../core/constants/colors.dart';
import 'stats_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  void _select(BuildContext context, String lang) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => StatsScreen(language: lang)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: getScreenWidth(context), height: 180),
                  const SizedBox(height: 24),
                  const Text('Choose Language / Tilni tanlang', style: TextStyle(fontSize: 14, color: GRAY_TEXT), textAlign: TextAlign.center),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: DARK_NAVY)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: GRAY_TEXT),
          ],
        ),
      ),
    );
  }
}
