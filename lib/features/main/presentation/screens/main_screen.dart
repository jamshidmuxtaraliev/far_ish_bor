import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/colors.dart';
import 'candidates_screen.dart';
import 'employer_applications_screen.dart';
import 'employer_interviews_screen.dart';
import 'home_screen.dart';
import 'jobs_screen.dart';
import 'my_applications_screen.dart';
import 'profile_screen.dart';
import 'saved_vacancies_screen.dart';

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

  @override
  void initState() {
    super.initState();

    if (widget.isEmployer) {
      _pages = [
        JobsScreen(isEmployer: widget.isEmployer),
        const CandidatesScreen(),
        const EmployerApplicationsScreen(),
        const EmployerInterviewsScreen(),
        ProfileScreen(isEmployer: widget.isEmployer),
      ];
      _navItems = const [
        _NavItem(icon: Icons.work_outline_rounded, activeIcon: Icons.work_rounded, label: 'Vakansiyalar'),
        _NavItem(icon: Icons.people_outline_rounded, activeIcon: Icons.people_rounded, label: 'Nomzodlar'),
        _NavItem(icon: Icons.inbox_outlined, activeIcon: Icons.inbox_rounded, label: 'Arizalar'),
        _NavItem(icon: Icons.event_note_outlined, activeIcon: Icons.event_note_rounded, label: 'Suhbatlar'),
        _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
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
        _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Bosh sahifa'),
        _NavItem(icon: Icons.work_outline_rounded, activeIcon: Icons.work_rounded, label: 'Ishlar'),
        _NavItem(icon: Icons.description_outlined, activeIcon: Icons.description_rounded, label: 'Arizalarim'),
        _NavItem(icon: Icons.bookmark_border_rounded, activeIcon: Icons.bookmark_rounded, label: 'Saqlangan'),
        _NavItem(icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Profil'),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: JB_BG,
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: JB_BORDER)),
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
                          Icon(isActive ? item.activeIcon : item.icon, color: isActive ? JB_BLUE : JB_GRAY, size: 23),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isActive ? JB_BLUE : JB_GRAY,
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
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
