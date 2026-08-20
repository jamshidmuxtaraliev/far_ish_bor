import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/get_it.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../../chat/presentation/logic/chat_bloc.dart';
import 'candidates_screen.dart';
import 'employer_applications_screen.dart';
import 'employer_interviews_screen.dart';
import 'home_screen.dart';
import 'jobs_screen.dart';
import 'my_applications_screen.dart';
import 'profile_screen.dart';
import 'saved_vacancies_screen.dart';
import '../../../../core/theme/jb_palette.dart';

class MainScreen extends StatefulWidget {
  /// Pass true for employer flow, false for job seeker.
  final bool isEmployer;

  const MainScreen({super.key, this.isEmployer = false});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;
  late final List<_NavItem> _navItems;

  void _selectTab(int index) => setState(() => _selectedIndex = index);

  bool _chatConnected = false;

  void _connectSupportChat() {
    if (_chatConnected) return;
    final sessionKey = buildSupportSessionKey();
    if (sessionKey == null) return; // user hali keshda yo'q — GetMe kutiladi
    _chatConnected = true;
    getIt<ChatBloc>().add(ConnectChatEvent(sessionKey));
  }

  @override
  void initState() {
    super.initState();

    // Support-chat socket ulanadi (MOBILE_CHAT_PROMPT §3): chat ekrani
    // ochilishini kutmaymiz — operator javobi kelganda badge ko'rsatiladi.
    _connectSupportChat();

    if (widget.isEmployer) {
      _pages = [
        JobsScreen(isEmployer: widget.isEmployer),
        const CandidatesScreen(),
        const EmployerApplicationsScreen(),
        const EmployerInterviewsScreen(),
        ProfileScreen(isEmployer: widget.isEmployer, onSelectTab: _selectTab),
      ];
      _navItems = const [
        _NavItem(
          icon: Icons.work_outline_rounded,
          activeIcon: Icons.work_rounded,
          label: 'Vakansiyalar',
        ),
        _NavItem(
          icon: Icons.people_outline_rounded,
          activeIcon: Icons.people_rounded,
          label: 'Nomzodlar',
        ),
        _NavItem(
          icon: Icons.inbox_outlined,
          activeIcon: Icons.inbox_rounded,
          label: 'Arizalar',
        ),
        _NavItem(
          icon: Icons.event_note_outlined,
          activeIcon: Icons.event_note_rounded,
          label: 'Suhbatlar',
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Profil',
        ),
      ];
    } else {
      _pages = [
        HomeScreen(isEmployer: widget.isEmployer, onSelectTab: _selectTab),
        JobsScreen(isEmployer: widget.isEmployer),
        MyApplicationsScreen(),
        const SavedVacanciesScreen(),
        ProfileScreen(isEmployer: widget.isEmployer),
      ];
      _navItems = const [
        _NavItem(
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded,
          label: 'Bosh sahifa',
        ),
        _NavItem(
          icon: Icons.work_outline_rounded,
          activeIcon: Icons.work_rounded,
          label: 'Ishlar',
        ),
        _NavItem(
          icon: Icons.description_outlined,
          activeIcon: Icons.description_rounded,
          label: 'Arizalarim',
        ),
        _NavItem(
          icon: Icons.bookmark_border_rounded,
          activeIcon: Icons.bookmark_rounded,
          label: 'Saqlangan',
        ),
        _NavItem(
          icon: Icons.person_outline_rounded,
          activeIcon: Icons.person_rounded,
          label: 'Profil',
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: BlocListener<AuthBloc, AuthState>(
        // Eski o'rnatishlarda user GetMe qaytgachgina keshga tushadi —
        // shunda support-chat socketni kechikib bo'lsa ham ulaymiz.
        listenWhen: (p, c) => p.user?.id != c.user?.id && c.user != null,
        listener: (context, state) => _connectSupportChat(),
        child: Scaffold(
          backgroundColor: context.jb.bg,
          body: IndexedStack(index: _selectedIndex, children: _pages),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: context.jb.card,
              border: Border(top: BorderSide(color: context.jb.border)),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 64,
                child: Row(
                  children: List.generate(_navItems.length, (index) {
                    final item = _navItems[index];
                    final isActive = _selectedIndex == index;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTab(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isActive ? item.activeIcon : item.icon,
                              color: isActive ? context.jb.blue : context.jb.gray,
                              size: 23,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isActive ? context.jb.blue : context.jb.gray,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
