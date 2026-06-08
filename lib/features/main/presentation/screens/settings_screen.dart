import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Column(
          children: [
            // Dark header
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 8,
                right: 20,
                bottom: 16,
              ),
              color: Colors.black,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white, size: 20),
                  ),
                  const Text(
                    'Sozlamalar',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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
                    trailing: const Text("O'zbek",
                        style: TextStyle(color: GRAY_TEXT, fontSize: 14)),
                    onTap: () {},
                  ),
                  const SizedBox(height: 8),
                  _SettingTile(
                    icon: Icons.notifications_outlined,
                    label: 'Bildirishnomalar',
                    trailing: Switch(
                      value: _notifications,
                      onChanged: (v) => setState(() => _notifications = v),
                      activeThumbColor: PRIMARY_BLUE,
                    ),
                    onTap: () => setState(() => _notifications = !_notifications),
                  ),
                  const SizedBox(height: 8),
                  _SettingTile(
                    icon: Icons.dark_mode_outlined,
                    label: 'Tungi rejim',
                    trailing: Switch(
                      value: _darkMode,
                      onChanged: (v) => setState(() => _darkMode = v),
                      activeThumbColor: PRIMARY_BLUE,
                    ),
                    onTap: () => setState(() => _darkMode = !_darkMode),
                  ),
                  const SizedBox(height: 24),
                  _SectionTitle(title: 'Xavfsizlik'),
                  const SizedBox(height: 12),
                  _SettingTile(
                    icon: Icons.lock_outline,
                    label: "Parolni o'zgartirish",
                    onTap: () {},
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'FARISHBOR v1.0.0',
                      style: TextStyle(color: GRAY_TEXT, fontSize: 13),
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
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: DARK_NAVY,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Icon(icon, color: PRIMARY_BLUE, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: DARK_NAVY),
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: GRAY_TEXT),
          ],
        ),
      ),
    );
  }
}
