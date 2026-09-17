import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'employer_registration_screen.dart';
import 'job_seeker_registration_screen.dart';
import 'login_screen.dart';
import '../../../../core/theme/jb_palette.dart';
import '../../../../core/theme/jb_ui.dart';

class UserTypeScreen extends StatelessWidget {
  final String language;

  /// Kirish ekranidan o'tkazilganda raqam qayta yozilmasin.
  final String? initialPhone;

  /// Nega bu ekranga tushib qolgani haqida izoh.
  final String? notice;

  const UserTypeScreen({
    super.key,
    required this.language,
    this.initialPhone,
    this.notice,
  });

  bool get isUz => language == 'uz';

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [context.jb.cardAlt, context.jb.blueTint],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const JBLogo(size: 120),
                  const SizedBox(height: 24),
                  Text(
                    isUz ? 'Kim siz?' : 'Кто вы?',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: context.jb.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isUz ? 'Rolingizni tanlang' : 'Выберите вашу роль',
                    style: TextStyle(fontSize: 15, color: context.jb.gray),
                  ),
                  if (notice != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: context.jb.amberBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.jb.amberBg),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 18, color: context.jb.amber),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              notice!,
                              style: TextStyle(fontSize: 13, color: context.jb.amber, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                  _TypeCard(
                    icon: Icons.person_outline,
                    title: isUz ? 'Ish izlovchi' : 'Соискатель',
                    subtitle: isUz ? 'Ish qidiryapman' : 'Ищу работу',
                    gradientColors: [context.jb.blue, context.jb.blueLight],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => JobSeekerRegistrationScreen(
                          language: language,
                          initialPhone: initialPhone,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _TypeCard(
                    icon: Icons.work_outline,
                    title: isUz ? 'Ish beruvchi' : 'Работодатель',
                    subtitle: isUz ? 'Xodim qidiryapman' : 'Ищу сотрудника',
                    gradientColors: [context.jb.ink, context.jb.gray],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EmployerRegistrationScreen(
                          language: language,
                          initialPhone: initialPhone,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(
                          language: language,
                          initialPhone: initialPhone,
                        ),
                      ),
                    ),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14, color: context.jb.gray),
                        children: [
                          TextSpan(text: isUz ? 'Hisobingiz bormi? ' : 'Уже есть аккаунт? '),
                          TextSpan(
                            text: isUz ? 'Kirish' : 'Войти',
                            style: TextStyle(color: context.jb.blue, fontWeight: FontWeight.w600),
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
          color: context.jb.card,
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.jb.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: context.jb.gray)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: context.jb.gray),
          ],
        ),
      ),
    );
  }
}
