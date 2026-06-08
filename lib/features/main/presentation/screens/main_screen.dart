import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/colors.dart';
import 'candidates_screen.dart';
import 'employer_applications_screen.dart';
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

  @override
  void initState() {
    super.initState();

    if (widget.isEmployer) {
      _pages = [
        HomeScreen(isEmployer: widget.isEmployer),
        JobsScreen(isEmployer: widget.isEmployer),
        const CandidatesScreen(),
        const EmployerApplicationsScreen(),
        ProfileScreen(isEmployer: widget.isEmployer),
      ];
      _navItems = const [
        _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Bosh sahifa'),
        _NavItem(icon: Icons.work_outline, activeIcon: Icons.work, label: 'Vakansiyalar'),
        _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, label: 'Nomzodlar'),
        _NavItem(icon: Icons.inbox_outlined, activeIcon: Icons.inbox, label: 'Arizalar'),
        _NavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Profil'),
      ];
    } else {
      _pages = [
        HomeScreen(isEmployer: widget.isEmployer),
        JobsScreen(isEmployer: widget.isEmployer),
        MyApplicationsScreen(),
        const SavedVacanciesScreen(),
        ProfileScreen(isEmployer: widget.isEmployer),
      ];
      _navItems = const [
        _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Bosh sahifa'),
        _NavItem(icon: Icons.work_outline, activeIcon: Icons.work, label: 'Ishlar'),
        _NavItem(icon: Icons.description_outlined, activeIcon: Icons.description, label: 'Arizalarim'),
        _NavItem(icon: Icons.bookmark_border_outlined, activeIcon: Icons.bookmark, label: 'Saqlangan'),
        _NavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle, label: 'Profil'),
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
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 16, offset: const Offset(0, -2))],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(_navItems.length, (index) {
                  final item = _navItems[index];
                  final isActive = _selectedIndex == index;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(isActive ? item.activeIcon : item.icon, color: isActive ? PRIMARY_BLUE : GRAY_TEXT, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                              color: isActive ? PRIMARY_BLUE : GRAY_TEXT,
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
