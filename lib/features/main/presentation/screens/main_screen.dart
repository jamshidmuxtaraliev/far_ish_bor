import 'package:flutter/material.dart';

import '../../../../core/services/push_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/get_it.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../../chat/presentation/logic/chat_bloc.dart';
import 'candidates_screen.dart';
import 'employer_home_screen.dart';
import 'home_screen.dart';
import 'jobs_screen.dart';
import 'messages_screen.dart';
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

  /// ⚠ TABLAR DANGASA QURILADI. `IndexedStack` odatda BARCHA bolalarni darhol
  /// quradi — u holda ilova ochilishida beshta ekranning `initState` i birdan
  /// so'rov yuboradi (bir xil ro'yxat ikki-uch marta). Shuning uchun faqat
  /// ochilgan tab quriladi; bir marta ochilgach `IndexedStack` uni tirik
  /// saqlaydi, ya'ni holat (skroll, filtr) yo'qolmaydi.
  final Set<int> _built = {0};

  void _selectTab(int index) {
    // Tab ALLAQACHON qurilgan bo'lsa `initState` qayta ishlamaydi (IndexedStack
    // uni tirik saqlaydi) — shuning uchun "Nomzodlar"ga qaytilganini alohida
    // signal bilan bildiramiz, aks holda ro'yxat ilova ochilgandagi holida
    // qotib qolardi (masalan yangi vakansiya boshqa qurilmada yaratilganda).
    final revisit = index == 2 && _built.contains(2);
    setState(() {
      _selectedIndex = index;
      _built.add(index);
    });
    if (revisit) _candidatesRevisit.value++;
  }

  /// "Nomzodlar" tabini MA'LUM ichki bo'lim bilan ochish uchun kanal —
  /// bosh sahifadagi KPI karta/banner "otkliklar"ga, tezkor amal esa "mos
  /// nomzodlar"ga tushishi kerak, ikkalasi ham ayni 2-tab.
  final ValueNotifier<CandidatesTabRequest?> _candidatesTab =
      ValueNotifier(null);

  /// "Nomzodlar" tabiga QAYTA kirilgani — har safar qiymati oshadi.
  /// [CandidatesScreen] buni eshitib ro'yxatlarni yangilaydi (ichida throttle
  /// bor, ketma-ket bosishda so'rov takrorlanmaydi).
  final ValueNotifier<int> _candidatesRevisit = ValueNotifier(0);

  void _openCandidates(CandidatesTab tab) {
    _candidatesTab.value = CandidatesTabRequest(tab);
    _selectTab(2);
  }

  @override
  void dispose() {
    _candidatesTab.dispose();
    _candidatesRevisit.dispose();
    super.dispose();
  }

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

    // Push tokenini serverga bog'lash uchun YAGONA nuqta: login, ro'yxatdan
    // o'tish va splash (allaqachon kirgan) — uchalasi ham shu ekranga keladi.
    // Kirish ekranlarining har biriga alohida chaqiruv qo'shilsa, bittasi
    // esdan chiqib qurilma jimgina push'siz qolardi.
    PushService.instance.syncToken();

    if (widget.isEmployer) {
      // ⚠ TARTIB: 0=Asosiy · 1=E'lonlar · 2=Nomzodlar · 3=Xabarlar · 4=Profil.
      //
      // Alohida "Arizalar" tabi OLIB TASHLANDI — u [CandidatesScreen] ning
      // birinchi ichki tabi ("Ishga topshirgan") bilan ayni ro'yxatni
      // ko'rsatardi, ya'ni pastki menyuda bir manba ikki marta turardi.
      // Bo'shagan o'rinni chat egalladi: support-socket ilova ochilishidayoq
      // ulanadi, shuning uchun operator javobi menyuda badge bilan ko'rinsin.
      //
      // Tab indekslariga tayangan joylar: [ProfileScreen] menyusi va
      // [EmployerHomeScreen] — o'zgartirsangiz ikkalasini ham yangilang.
      _pages = [
        EmployerHomeScreen(
          onSelectTab: _selectTab,
          onOpenCandidates: _openCandidates,
        ),
        JobsScreen(isEmployer: widget.isEmployer),
        CandidatesScreen(
          tabRequest: _candidatesTab,
          revisit: _candidatesRevisit,
        ),
        const MessagesScreen(),
        ProfileScreen(isEmployer: widget.isEmployer, onSelectTab: _selectTab),
      ];
      _navItems = const [
        _NavItem(
          icon: Icons.dashboard_outlined,
          activeIcon: Icons.dashboard_rounded,
          label: 'Asosiy',
        ),
        _NavItem(
          icon: Icons.work_outline_rounded,
          activeIcon: Icons.work_rounded,
          label: "E'lonlar",
        ),
        _NavItem(
          icon: Icons.people_outline_rounded,
          activeIcon: Icons.people_rounded,
          label: 'Nomzodlar',
        ),
        _NavItem(
          icon: Icons.chat_bubble_outline_rounded,
          activeIcon: Icons.chat_bubble_rounded,
          label: 'Xabarlar',
          showChatBadge: true,
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
          label: 'Asosiy',
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
          body: IndexedStack(
            index: _selectedIndex,
            children: List.generate(
              _pages.length,
              (i) => _built.contains(i) ? _pages[i] : const SizedBox.shrink(),
            ),
          ),
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
                    final color = isActive ? context.jb.blue : context.jb.gray;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _selectTab(index),
                        behavior: HitTestBehavior.opaque,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            item.showChatBadge
                                ? _chatBadge(
                                    child: Icon(
                                      isActive ? item.activeIcon : item.icon,
                                      color: color,
                                      size: 23,
                                    ),
                                  )
                                : Icon(
                                    isActive ? item.activeIcon : item.icon,
                                    color: color,
                                    size: 23,
                                  ),
                            const SizedBox(height: 3),
                            // ⚠ `maxLines: 1` SHART: uzun nom ikki qatorga
                            // tushsa 64px balandlikdagi menyu toshib ketadi.
                            // Shrift masshtabi ham cheklanadi — tizim shriftini
                            // kattalashtirgan foydalanuvchida aynan shu sodir
                            // bo'lardi.
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textScaler: MediaQuery.textScalerOf(context)
                                  .clamp(maxScaleFactor: 1.1),
                              style: TextStyle(
                                fontSize: 10.5,
                                height: 1.1,
                                letterSpacing: -0.1,
                                fontWeight: FontWeight.w600,
                                color: color,
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

  /// Ikonka ustidagi o'qilmagan xabar sanog'i.
  ///
  /// ⚠ Manba — `ChatState.unreadCount`, ya'ni faqat OPERATOR (support) suhbati.
  /// Nomzod bilan to'g'ridan-to'g'ri yozishma ([DirectChatBloc]) alohida
  /// hisoblanadi va bu yerga kirmaydi.
  Widget _chatBadge({required Widget child}) {
    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (p, c) => p.unreadCount != c.unreadCount,
      builder: (context, state) {
        final n = state.unreadCount;
        if (n <= 0) return child;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            Positioned(
              right: -6,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                constraints: const BoxConstraints(minWidth: 15),
                height: 15,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.jb.red,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: context.jb.card, width: 1.5),
                ),
                child: Text(
                  n > 9 ? '9+' : '$n',
                  textScaler: TextScaler.noScaling,
                  style: TextStyle(
                    color: context.jb.onBrand,
                    fontSize: 9,
                    height: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  /// Ikonka ustida o'qilmagan xabar nuqtasi ko'rsatilsinmi.
  final bool showChatBadge;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.showChatBadge = false,
  });
}
