import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'employer_registration_screen.dart';
import 'job_seeker_registration_screen.dart';
import 'login_screen.dart';
import '../logic/auth_bloc.dart';
import '../../../../core/theme/jb_palette.dart';
import '../../../../core/theme/jb_ui.dart';

class UserTypeScreen extends StatefulWidget {
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

  @override
  State<UserTypeScreen> createState() => _UserTypeScreenState();
}

class _UserTypeScreenState extends State<UserTypeScreen> {
  @override
  void initState() {
    super.initState();
    // Ishonch raqamlari — ekran chizilgach fonda keladi. Kelmasa blok
    // ko'rsatilmaydi, ya'ni rol tanlash hech qachon shu so'rovni kutmaydi.
    context.read<AuthBloc>().add(LoadPublicStatsEvent());
  }

  bool get isUz => widget.language == 'uz';

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
            // Kartalarga foyda qatorlari qo'shilgach kontent past ekranlarga
            // sig'may qolishi mumkin — shuning uchun markazlashtirilgan,
            // lekin kerak bo'lsa scroll bo'ladigan tuzilma.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const JBLogo(size: 104),
                      const SizedBox(height: 20),
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
                      if (widget.notice != null) ...[
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
                                  widget.notice!,
                                  style: TextStyle(fontSize: 13, color: context.jb.amber, height: 1.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 28),
                      _TypeCard(
                        icon: Icons.person_outline,
                        title: isUz ? 'Ish izlovchi' : 'Соискатель',
                        subtitle: isUz ? 'Ish qidiryapman' : 'Ищу работу',
                        benefits: isUz
                            ? const ["Bepul ro'yxatdan o'tish", 'Anketa — 2 daqiqada']
                            : const ['Бесплатная регистрация', 'Анкета — за 2 минуты'],
                        gradientColors: [context.jb.blue, context.jb.blueLight],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => JobSeekerRegistrationScreen(
                              language: widget.language,
                              initialPhone: widget.initialPhone,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _TypeCard(
                        icon: Icons.work_outline,
                        title: isUz ? 'Ish beruvchi' : 'Работодатель',
                        subtitle: isUz ? 'Xodim qidiryapman' : 'Ищу сотрудника',
                        benefits: isUz
                            ? const ['Vakansiya joylash', 'Nomzodlar bazasi']
                            : const ['Разместить вакансию', 'База кандидатов'],
                        gradientColors: [context.jb.ink, context.jb.gray],
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EmployerRegistrationScreen(
                              language: widget.language,
                              initialPhone: widget.initialPhone,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _TrustBar(isUz: isUz),
                      const SizedBox(height: 22),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(
                              language: widget.language,
                              initialPhone: widget.initialPhone,
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
        ),
      ),
    );
  }
}

// ── Ishonch qatori ──────────────────────────────────────────────────────────

/// `GET /stats/public` dan kelgan UCHTA haqiqiy raqam.
///
/// ⚠ Bu yerga hech qachon qotirilgan raqam yozilmasin — ilgari alohida
/// "Statistika" ekrani bor edi va undagi 45 280 / 8 920 kabi sonlar kodda
/// konstanta bo'lib turardi (bazaga umuman qaramasdi). Ma'lumot kelmasa
/// blok ko'rsatilmaydi.
class _TrustBar extends StatelessWidget {
  final bool isUz;

  const _TrustBar({required this.isUz});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (a, b) => a.publicStats != b.publicStats,
      builder: (context, state) {
        final stats = state.publicStats;
        // Yuklanmadi yoki baza bo'sh — jim o'tamiz.
        final show = stats != null && !stats.isEmpty;
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: !show
              ? const SizedBox(width: double.infinity)
              : Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: context.jb.card.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: context.jb.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _TrustItem(
                          value: stats.seekers,
                          label: isUz ? 'Ish izlovchi' : 'Соискателей',
                        ),
                      ),
                      _divider(context),
                      Expanded(
                        child: _TrustItem(
                          value: stats.employers,
                          label: isUz ? 'Kompaniya' : 'Компаний',
                        ),
                      ),
                      _divider(context),
                      Expanded(
                        child: _TrustItem(
                          value: stats.hired,
                          label: isUz ? 'Ishga joylashdi' : 'Трудоустроено',
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _divider(BuildContext context) =>
      Container(width: 1, height: 30, color: context.jb.divider);
}

class _TrustItem extends StatelessWidget {
  final int value;
  final String label;

  const _TrustItem({required this.value, required this.label});

  /// Aniq son o'rniga yaxlitlangan "45 000+" ko'rsatiladi: baza har kuni
  /// o'zgaradi, aniq raqam esa ilovani qayta ochgan odamga "kamayib qoldi"
  /// bo'lib ko'rinishi mumkin.
  static String _rounded(int n) {
    if (n < 100) return '$n';
    final step = n < 1000 ? 10 : (n < 10000 ? 100 : 1000);
    return '${_grouped((n ~/ step) * step)}+';
  }

  static String _grouped(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (context, t, _) => Text(
            _rounded((value * t).round()),
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: context.jb.ink),
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: context.jb.gray),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ── Rol kartasi ─────────────────────────────────────────────────────────────

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> benefits;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.benefits,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
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
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  const SizedBox(height: 3),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: context.jb.gray)),
                  const SizedBox(height: 10),
                  for (final b in benefits)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 14, color: context.jb.green),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              b,
                              style: TextStyle(fontSize: 12, color: context.jb.gray, height: 1.2),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Icon(Icons.chevron_right, color: context.jb.gray),
            ),
          ],
        ),
      ),
    );
  }
}
