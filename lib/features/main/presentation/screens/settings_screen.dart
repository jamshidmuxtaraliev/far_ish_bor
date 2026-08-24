import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/jb_palette.dart';
import '../../../../core/theme/theme_cubit.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.card,
        body: Column(
          children: [
            // White header
            Container(
              width: double.infinity,
              color: context.jb.card,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 8,
                right: 20,
                bottom: 12,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.arrow_back_ios_new,
                        color: context.jb.ink, size: 20),
                  ),
                  Text(
                    'Sozlamalar',
                    style: TextStyle(
                      color: context.jb.ink,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            // Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _SectionTitle(title: 'Umumiy'),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.language_outlined,
                    label: 'Til',
                    trailing: Text("O'zbek",
                        style: TextStyle(color: context.jb.gray, fontSize: 14)),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _SettingTile(
                    icon: Icons.notifications_outlined,
                    label: 'Bildirishnomalar',
                    trailing: Switch(
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                      activeThumbColor: context.jb.blue,
                    ),
                    onTap: () => setState(() => _notifications = !_notifications),
                  ),
                  const SizedBox(height: 8),
                  const _ThemeModeTile(),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Xavfsizlik'),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.lock_outline,
                    label: "Parolni o'zgartirish",
                    onTap: () {},
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: Text(
                      'Jobup24 v1.0.0',
                      style: TextStyle(color: context.jb.gray, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: context.jb.ink,
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: context.jb.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.jb.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: context.jb.blue, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 15, color: context.jb.ink),
              ),
            ),
            trailing ?? Icon(Icons.chevron_right, color: context.jb.gray),
          ],
        ),
      ),
    );
  }
}


/// Mavzu tanlovi: Yorug' ⇄ Tungi. Tanlov `PREF_THEME`da saqlanadi.
/// Tizim rejimi qo'llanilmaydi — faqat ikki holatli zamonaviy switch.
class _ThemeModeTile extends StatelessWidget {
  const _ThemeModeTile();

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final dark = mode == ThemeMode.dark;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => context.read<ThemeCubit>().setDark(!dark),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: p.border),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: dark ? p.violetBg : p.amberBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: dark ? p.violet : p.amber,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tungi rejim',
                        style: TextStyle(fontSize: 15, color: p.ink),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dark ? 'Yoqilgan' : "O'chirilgan",
                        style: TextStyle(fontSize: 12.5, color: p.gray),
                      ),
                    ],
                  ),
                ),
                _JBSwitch(
                  value: dark,
                  onChanged: (v) => context.read<ThemeCubit>().setDark(v),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Palitra tokenlaridan quriladigan animatsiyali switch.
class _JBSwitch extends StatelessWidget {
  const _JBSwitch({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  static const _duration = Duration(milliseconds: 220);

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Semantics(
      toggled: value,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: _duration,
          curve: Curves.easeOut,
          width: 52,
          height: 30,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: value ? p.blue : p.chipBg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: value ? p.blue : p.border),
          ),
          child: AnimatedAlign(
            duration: _duration,
            curve: Curves.easeOut,
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? p.onBrand : p.card,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: p.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
