import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/utils.dart';
import 'employer_registration_screen.dart';
import 'job_seeker_registration_screen.dart';
import 'login_screen.dart';

class UserTypeScreen extends StatelessWidget {
  final String language;
  const UserTypeScreen({super.key, required this.language});

  bool get isUz => language == 'uz';

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
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF9FAFB), Color(0xFFEFF6FF)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: getScreenWidth(context), height: 120),
                  const SizedBox(height: 24),
                  Text(
                    isUz ? 'Kim siz?' : 'Кто вы?',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: DARK_NAVY,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isUz ? 'Rolingizni tanlang' : 'Выберите вашу роль',
                    style: const TextStyle(fontSize: 15, color: GRAY_TEXT),
                  ),
                  const SizedBox(height: 48),
                  _TypeCard(
                    icon: Icons.person_outline,
                    title: isUz ? 'Ish izlovchi' : 'Соискатель',
                    subtitle: isUz ? 'Ish qidiryapman' : 'Ищу работу',
                    gradientColors: const [PRIMARY_BLUE, SECONDARY_BLUE],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JobSeekerRegistrationScreen(language: language),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TypeCard(
                    icon: Icons.work_outline,
                    title: isUz ? 'Ish beruvchi' : 'Работодатель',
                    subtitle: isUz ? 'Xodim qidiryapman' : 'Ищу сотрудника',
                    gradientColors: const [DARK_NAVY, Color(0xFF334155)],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EmployerRegistrationScreen(language: language),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => LoginScreen(language: language)),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(fontSize: 14, color: GRAY_TEXT),
                        children: [
                          TextSpan(text: isUz ? 'Hisobingiz bormi? ' : 'Уже есть аккаунт? '),
                          TextSpan(
                            text: isUz ? 'Kirish' : 'Войти',
                            style: const TextStyle(color: PRIMARY_BLUE, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
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

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradientColors),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: DARK_NAVY,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: GRAY_TEXT),
          ],
        ),
      ),
    );
  }
}
