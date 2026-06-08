import 'dart:async';
import 'package:far_ish_bor/core/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/colors.dart';
import 'user_type_screen.dart';

class StatsScreen extends StatefulWidget {
  final String language;

  const StatsScreen({super.key, required this.language});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _totalUsers = 0;
  int _employers = 0;
  int _jobSeekers = 0;
  int _activeToday = 0;
  int _vacancies = 0;
  int _interviews = 0;
  int _hires = 0;

  static const _targets = {
    'totalUsers': 45280,
    'employers': 3420,
    'jobSeekers': 41860,
    'activeToday': 8540,
    'vacancies': 12450,
    'interviews': 2340,
    'hires': 8920,
  };

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    const steps = 60;
    const duration = Duration(milliseconds: 2000);
    int step = 0;
    _timer = Timer.periodic(Duration(milliseconds: duration.inMilliseconds ~/ steps), (t) {
      step++;
      final p = step / steps;
      setState(() {
        _totalUsers = (_targets['totalUsers']! * p).round();
        _employers = (_targets['employers']! * p).round();
        _jobSeekers = (_targets['jobSeekers']! * p).round();
        _activeToday = (_targets['activeToday']! * p).round();
        _vacancies = (_targets['vacancies']! * p).round();
        _interviews = (_targets['interviews']! * p).round();
        _hires = (_targets['hires']! * p).round();
      });
      if (step >= steps) {
        t.cancel();
        setState(() {
          _totalUsers = _targets['totalUsers']!;
          _employers = _targets['employers']!;
          _jobSeekers = _targets['jobSeekers']!;
          _activeToday = _targets['activeToday']!;
          _vacancies = _targets['vacancies']!;
          _interviews = _targets['interviews']!;
          _hires = _targets['hires']!;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get isUz => widget.language == 'uz';

  String _fmt(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    // Card height derived from GridView dimensions
    final cellWidth = (screenWidth - 96) / 2; // margins(40) + card padding(40) + spacing(16)
    final cellHeight = cellWidth / 1.25;
    final cardHeight = 2 * cellHeight + 0; // 2 rows + mainAxisSpacing + card padding
    const cardOverlap = 60.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // ── Scrollable content ──────────────────────────────────────
            SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomPad + 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header + overlapping stat card ───────────────────
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Blue gradient header — extra bottom padding creates the blue
                      // space that the card will overlap into
                      Container(
                        padding: EdgeInsets.only(top: topPad + 20, left: 24, right: 24, bottom: cardOverlap + 20),
                        width: getScreenWidth(context),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [PRIMARY_BLUE, SECONDARY_BLUE]),
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              isUz ? 'FARISHBOR Statistikasi' : 'Статистика FARISHBOR',
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isUz ? 'Ishonchli hamkorlik' : 'Надежное сотрудничество',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      // Stat card — anchored so its top sits cardOverlap px above
                      // the Stack's bottom edge (inside the blue area)
                      Positioned(
                        bottom: -cardHeight,
                        left: 20,
                        right: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8))],
                          ),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 0,
                            childAspectRatio: 1.5,
                            children: [
                              _StatCell(
                                icon: Icons.people_outline,
                                value: _fmt(_totalUsers),
                                label: isUz ? 'Jami foydalanuvchilar' : 'Всего пользователей',
                                gradientColors: const [PRIMARY_BLUE, SECONDARY_BLUE],
                              ),
                              _StatCell(
                                icon: Icons.business_outlined,
                                value: _fmt(_employers),
                                label: isUz ? 'Ish beruvchilar' : 'Работодателей',
                                gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                              ),
                              _StatCell(
                                icon: Icons.person_outline,
                                value: _fmt(_jobSeekers),
                                label: isUz ? 'Ish izlovchilar' : 'Соискателей',
                                gradientColors: const [GREEN_COLOR, Color(0xFF16A34A)],
                              ),
                              _StatCell(
                                icon: Icons.trending_up,
                                value: _fmt(_activeToday),
                                label: isUz ? 'Bugun faol' : 'Активны сегодня',
                                gradientColors: const [Color(0xFFF97316), Color(0xFFEA580C)],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Space for the card overflow below the Stack
                  SizedBox(height: cardHeight - cardOverlap + 80),

                  // ── Row stat cards ───────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _RowCard(
                          icon: Icons.work_outline,
                          label: isUz ? 'Vakansiyalar' : 'Вакансий',
                          value: _fmt(_vacancies),
                          gradientColors: const [PRIMARY_BLUE, SECONDARY_BLUE],
                        ),
                        const SizedBox(height: 12),
                        _RowCard(
                          icon: Icons.calendar_today_outlined,
                          label: isUz ? 'Suhbatlar belgilandi' : 'Интервью назначено',
                          value: _fmt(_interviews),
                          gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                        ),
                        const SizedBox(height: 12),
                        _RowCard(
                          icon: Icons.check_circle_outline,
                          label: isUz ? 'Muvaffaqiyatli ishga olindi' : 'Успешно приняты',
                          value: _fmt(_hires),
                          gradientColors: const [GREEN_COLOR, Color(0xFF16A34A)],
                        ),
                        const SizedBox(height: 12),
                        _RowCard(
                          icon: Icons.calendar_today_outlined,
                          label: isUz ? 'Suhbatlar belgilandi' : 'Интервью назначено',
                          value: _fmt(_interviews),
                          gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA78BFA)],
                        ),
                        const SizedBox(height: 12),
                        _RowCard(
                          icon: Icons.check_circle_outline,
                          label: isUz ? 'Muvaffaqiyatli ishga olindi' : 'Успешно приняты',
                          value: _fmt(_hires),
                          gradientColors: const [GREEN_COLOR, Color(0xFF16A34A)],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Fixed bottom button ──────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPad + 12),
                decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE5E7EB)))),
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => UserTypeScreen(language: widget.language)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_BLUE,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(isUz ? 'Davom etish' : 'Продолжить', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ─────────────────────────────────────────────────────────────────

class _StatCell extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final List<Color> gradientColors;

  const _StatCell({required this.icon, required this.value, required this.label, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(gradient: LinearGradient(colors: gradientColors), borderRadius: BorderRadius.circular(14)),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        const SizedBox(height: 10),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: DARK_NAVY)),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: GRAY_TEXT),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _RowCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final List<Color> gradientColors;

  const _RowCard({required this.icon, required this.label, required this.value, required this.gradientColors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(gradient: LinearGradient(colors: gradientColors), borderRadius: BorderRadius.circular(14)),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: DARK_NAVY)),
            ],
          ),
        ],
      ),
    );
  }
}
