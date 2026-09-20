import 'package:flutter/material.dart';

import '../../../../core/services/push_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/services/get_it.dart';
import '../../../../core/utils/utils.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../../../auth/data/models/employer_model.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../../auth/presentation/screens/anketa_screen.dart';
import '../../../auth/presentation/screens/language_screen.dart';
import '../../../billing/presentation/screens/otklik_shop_screen.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../../../chat/presentation/logic/chat_bloc.dart';
import '../../../chat/presentation/screens/support_chat_screen.dart';
import '../../../faq/presentation/screens/faq_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../widgets/resume_actions.dart';
import '../widgets/resume_card.dart';
import 'edit_employer_screen.dart';
import 'employer_interviews_screen.dart';
import 'my_applications_screen.dart';
import 'settings_screen.dart';
import '../../../../core/theme/jb_palette.dart';

class ProfileScreen extends StatefulWidget {
  final bool isEmployer;
  final ValueChanged<int>? onSelectTab;

  const ProfileScreen({super.key, this.isEmployer = false, this.onSelectTab});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  /// Rezyume holati birinchi marta tekshirilmoqda. Bloc'dagi status
  /// muvaffaqiyatdan keyin darhol `initial`ga qaytariladi, shuning uchun
  /// "tekshirilmoqda / xato" ko'rinishini shu yerda ushlab turamiz.
  bool _resumeChecking = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<AuthBloc>();
    bloc.add(GetMeEvent());
    if (widget.isEmployer) {
      bloc.add(LoadEmployerEvent());
    } else {
      bloc.add(LoadAnketaEvent());
      _resumeChecking = true;
      bloc.add(LoadResumeInfoEvent());
    }
  }

  void _loadResumeInfo() {
    setState(() => _resumeChecking = true);
    context.read<AuthBloc>().add(LoadResumeInfoEvent());
  }

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state.resumeInfoStatus.isSuccess || state.resumeInfoStatus.isFailure) {
      if (_resumeChecking) setState(() => _resumeChecking = false);
    }
    if (state.downloadResumeStatus.isSuccess && state.resumeFilePath != null) {
      ResumeActions.showReadySheet(context, state.resumeFilePath!);
    } else if (state.downloadResumeStatus.isFailure) {
      showError(
        context,
        state.error?.errorMessage ?? "Rezyumeni yuklab bo'lmadi",
      );
    }
  }

  Widget _buildResumeCard(AuthState state) {
    return ResumeCard(
      resume: state.resume,
      loading: _resumeChecking,
      downloading: state.downloadResumeStatus.isInProgress,
      progress: state.resumeProgress,
      savedFilePath: state.resumeFilePath,
      anketaMissing: state.anketaMissing,
      onDownload: () => context.read<AuthBloc>().add(DownloadResumeEvent()),
      onUploadPhoto: _pickAndUploadAvatar,
      onRetry: _loadResumeInfo,
      onFillAnketa: _openAnketa,
      onOpenSaved: () => ResumeActions.open(context, state.resumeFilePath!),
      onShareSaved: () => ResumeActions.share(context, state.resumeFilePath!),
    );
  }

  void _openAnketa() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const AnketaScreen()))
        // Anketa tahrirlansa submission_status "yangi"ga qaytadi — qaytgach
        // rezyume holatini qayta so'raymiz.
        .then((_) {
          if (mounted) _loadResumeInfo();
        });
  }

  Future<void> _pickAndUploadAvatar() async {
    final picked = await pickImageWithSourceSheet(context);
    if (picked == null) return;
    if (!mounted) return;
    if (widget.isEmployer) {
      context.read<AuthBloc>().add(UploadLogoEvent(picked.path));
    } else {
      context.read<AuthBloc>().add(UploadPhotoEvent(picked.path));
    }
  }

  void _logout() {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Chiqish',
              style: TextStyle(fontWeight: FontWeight.bold, color: jb.ink),
            ),
            content: Text(
              'Hisobingizdan chiqmoqchimisiz?',
              style: TextStyle(color: jb.gray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Bekor qilish',
                  style: TextStyle(color: jb.gray),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  getIt<ChatBloc>().add(const DisconnectChatEvent());
                  // Push tokenini avval uzamiz — keyin auth token o'chadi va
                  // `/push/unregister` 401 bo'lib qolardi.
                  await PushService.instance.clear();
                  await getIt<UserLocalDatasource>().clearCache();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LanguageScreen()),
                      (route) => false,
                    );
                  }
                },
                child: Text(
                  'Chiqish',
                  style: TextStyle(
                    color: jb.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlayOnBrand,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: BlocConsumer<AuthBloc, AuthState>(
          listenWhen:
              (prev, curr) =>
                  prev.resumeInfoStatus != curr.resumeInfoStatus ||
                  prev.downloadResumeStatus != curr.downloadResumeStatus,
          listener: _onAuthStateChanged,
          builder: (context, state) {
            final user = state.user;
            final isLoading = state.getMeStatus.isInProgress && user == null;
            final avatarUrl =
                widget.isEmployer
                    ? state.employer?.logoUrl
                    : state.anketa?.photoUrl;
            final isAvatarUploading =
                widget.isEmployer
                    ? state.uploadLogoStatus.isInProgress
                    : state.uploadPhotoStatus.isInProgress;
            final showPhotoBanner =
                !widget.isEmployer &&
                state.anketa != null &&
                state.anketa!.photo == null;
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    context,
                    user,
                    isLoading,
                    avatarUrl,
                    isAvatarUploading,
                    state.employer,
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 16),
                      if (showPhotoBanner) ...[
                        _buildPhotoBanner(),
                        const SizedBox(height: 16),
                      ],
                      if (!widget.isEmployer) ...[
                        _buildResumeCard(state),
                        const SizedBox(height: 16),
                      ],
                      if (!widget.isEmployer &&
                          user != null &&
                          (user.jobTypeName != null ||
                              user.workStatus != null)) ...[
                        _buildInfoSection(user),
                        const SizedBox(height: 16),
                      ],
                      _buildMenuSection(context),
                      const SizedBox(height: 16),
                      _buildLogoutButton(),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    UserModel? user,
    bool isLoading,
    String? avatarUrl,
    bool isAvatarUploading,
    EmployerModel? employer,
  ) {
    final displayName =
        user?.displayName ??
        (widget.isEmployer ? 'Kompaniya' : 'Foydalanuvchi');
    final subtitle =
        widget.isEmployer
            ? (user?.contactPerson ?? 'Ish beruvchi')
            : (user?.jobTypeName ?? 'Ish izlovchi');

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 30,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [context.jb.blue, context.jb.blueLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap:
                    () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    ),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Avatar
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  image:
                      avatarUrl != null
                          ? DecorationImage(
                            image: NetworkImage(avatarUrl),
                            fit: BoxFit.cover,
                          )
                          : null,
                ),
                child:
                    isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                        : avatarUrl != null
                        ? null
                        : Center(
                          child: Text(
                            user?.initials ?? '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              ),
              if (isAvatarUploading)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black38,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _pickAndUploadAvatar,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: context.jb.card,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: context.jb.blue,
                      size: 14,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              // ⚠ Ish beruvchida yorliq HAQIQIY holatdan olinadi
              // (`lifecycle_status`) — ilgari hammaga "Tasdiqlangan" deb
              // yozilardi va moderatsiyadagi kompaniya ham tasdiqlangandek
              // ko'rinardi. Bosh sahifadagi chip bilan bir manba.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Icon(
                      widget.isEmployer && employer?.isVerified != true
                          ? Icons.hourglass_bottom_rounded
                          : Icons.verified,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      widget.isEmployer
                          ? (employer?.lifecycleLabel ?? 'Yangi')
                          : 'Tasdiqlangan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            widget.isEmployer
                ? 'Ish beruvchi • $subtitle'
                : 'Ish qidiruvchi • $subtitle',
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          if (!widget.isEmployer && user != null) ...[
            const SizedBox(height: 12),
            _buildHeaderStats(user),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderStats(UserModel user) {
    final chips = <Widget>[
      if (user.phone != null)
        _HeaderStatChip(icon: Icons.phone_outlined, value: user.phone!),
      _HeaderStatChip(
        icon: Icons.history_outlined,
        value:
            user.experienceYear != null
                ? '${user.experienceYear} yil staj'
                : "Staj ko'rsatilmagan",
      ),
      if (user.expectedSalary != null)
        _HeaderStatChip(
          icon: Icons.attach_money,
          value: _formatSalary(user.expectedSalary!),
        ),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildPhotoBanner() {
    return GestureDetector(
      onTap: _pickAndUploadAvatar,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: jb.amberBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: jb.amberBg),
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_a_photo_outlined,
              color: jb.amber,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Profilingizga rasm yuklang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: jb.amber,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: jb.amber,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: jb.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (user.jobTypeName != null) ...[
            _InfoRow(
              icon: Icons.work_outline,
              label: 'Kasb',
              value: user.jobTypeName!,
            ),
          ],
          if (user.workStatus != null) ...[
            if (user.jobTypeName != null)
              Divider(height: 20, color: jb.cardAlt),
            _InfoRow(
              icon: Icons.circle_outlined,
              label: 'Holati',
              value: user.workStatus!,
            ),
          ],
        ],
      ),
    );
  }

  String _formatSalary(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(' ');
      buf.write(s[i]);
      count++;
    }
    return '${buf.toString().split('').reversed.join()} so\'m';
  }

  // ⚠ TARIF KARTASI OLIB TASHLANDI (2026-09-17).
  // Premium A/B/V / Mini paket — CRM tariflari, ularni FAQAT operator
  // biriktiradi va ilovada ko'rsatilmaydi. Ish beruvchi ilovada faqat
  // OTKLIK tarifini (obuna/paket) tanlaydi — "Otkliklar" ekrani.

  Widget _buildMenuSection(BuildContext context) {
    final List<_MenuItem> jobSeekerItems = [
      _MenuItem(
        icon: Icons.person_outline,
        label: "Anketa to'ldirish",
        color: context.jb.blue,
        onTap: _openAnketa,
      ),
      _MenuItem(
        icon: Icons.folder_open_outlined,
        label: 'Mening arizalarim',
        color: context.jb.violet,
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
            ),
      ),
    ];

    final List<_MenuItem> employerItems = [
      _MenuItem(
        icon: Icons.business_outlined,
        label: 'Kompaniyani tahrirlash',
        color: context.jb.blue,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditEmployerScreen()),
        ),
      ),
      // Tab indekslari [MainScreen] dagi ish beruvchi ro'yxatiga mos:
      // 0=Asosiy · 1=E'lonlar · 2=Nomzodlar · 3=Xabarlar · 4=Profil.
      _MenuItem(
        icon: Icons.work_outline,
        label: "E'lonlarim",
        color: context.jb.cyan,
        onTap: () => widget.onSelectTab?.call(1),
      ),
      _MenuItem(
        icon: Icons.people_outline,
        label: 'Nomzodlarni kuzatish',
        color: context.jb.violet,
        onTap: () => widget.onSelectTab?.call(2),
      ),
      _MenuItem(
        icon: Icons.event_note_outlined,
        label: 'Suhbatlar',
        color: context.jb.amber,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const EmployerInterviewsScreen(showBack: true),
          ),
        ),
      ),
    ];

    final List<_MenuItem> commonItems = [
      // Ish beruvchi balansni to'ldirmaydi — u KALIT (paket yoki obuna)
      // sotib oladi. Ish izlovchida balans oqimi o'z holicha qoladi.
      _MenuItem(
        icon: widget.isEmployer
            ? Icons.confirmation_number_outlined
            : Icons.account_balance_wallet_outlined,
        label: widget.isEmployer ? 'Kalit va tariflar' : 'Balans va to\'lov',
        color: context.jb.green,
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => widget.isEmployer
                    ? const OtklikShopScreen()
                    : TopUpScreen(isEmployer: widget.isEmployer),
              ),
            ),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Bildirishnomalar',
        color: context.jb.amber,
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
      ),
      _MenuItem(
        icon: Icons.support_agent_outlined,
        label: 'Qo\'llab-quvvatlash',
        color: context.jb.blue,
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SupportChatScreen()),
            ),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Yordam',
        color: context.jb.gray,
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => FaqScreen(isEmployer: widget.isEmployer),
              ),
            ),
      ),
    ];

    final roleItems = widget.isEmployer ? employerItems : jobSeekerItems;

    return Container(
      decoration: BoxDecoration(
        color: context.jb.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ...List.generate(
            roleItems.length,
            (i) => Column(
              children: [
                _MenuItemTile(item: roleItems[i]),
                if (i < roleItems.length - 1)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: context.jb.cardAlt,
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: context.jb.cardAlt),
          ...List.generate(
            commonItems.length,
            (i) => Column(
              children: [
                _MenuItemTile(item: commonItems[i]),
                if (i < commonItems.length - 1)
                  Divider(
                    height: 1,
                    indent: 56,
                    color: context.jb.cardAlt,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _logout,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: jb.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: jb.red, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: jb.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Chiqish',
              style: TextStyle(
                color: jb.red,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStatChip extends StatelessWidget {
  final IconData icon;
  final String value;

  const _HeaderStatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white70, size: 13),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.jb.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: context.jb.blue, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: context.jb.gray)),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.jb.ink,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _MenuItemTile extends StatelessWidget {
  final _MenuItem item;

  const _MenuItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(item.icon, color: item.color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: context.jb.ink,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: context.jb.gray, size: 20),
          ],
        ),
      ),
    );
  }
}
