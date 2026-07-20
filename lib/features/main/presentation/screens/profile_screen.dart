import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/services/get_it.dart';
import '../../../../core/utils/utils.dart';
import '../../../auth/data/datasource/local/user_local_data_source.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../../auth/presentation/screens/anketa_screen.dart';
import '../../../auth/presentation/screens/language_screen.dart';
import '../../../billing/presentation/screens/premium_screen.dart';
import '../../../billing/presentation/screens/topup_screen.dart';
import '../../../chat/presentation/screens/support_chat_screen.dart';
import '../../../faq/presentation/screens/faq_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import 'edit_employer_screen.dart';
import 'my_applications_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final bool isEmployer;

  const ProfileScreen({super.key, this.isEmployer = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    final bloc = context.read<AuthBloc>();
    bloc.add(GetMeEvent());
    if (widget.isEmployer) {
      bloc.add(LoadEmployerEvent());
    } else {
      bloc.add(LoadAnketaEvent());
    }
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
            title: const Text(
              'Chiqish',
              style: TextStyle(fontWeight: FontWeight.bold, color: DARK_NAVY),
            ),
            content: const Text(
              'Hisobingizdan chiqmoqchimisiz?',
              style: TextStyle(color: GRAY_TEXT),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'Bekor qilish',
                  style: TextStyle(color: GRAY_TEXT),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await getIt<UserLocalDatasource>().clearCache();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LanguageScreen()),
                      (route) => false,
                    );
                  }
                },
                child: const Text(
                  'Chiqish',
                  style: TextStyle(
                    color: Color(0xFFDC2626),
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
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarContrastEnforced: false,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: JB_BG,
        body: BlocBuilder<AuthBloc, AuthState>(
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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [JB_BLUE, JB_BLUE_LIGHT],
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
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: JB_BLUE,
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified, color: Colors.white, size: 12),
                    SizedBox(width: 3),
                    Text(
                      'Tasdiqlangan',
                      style: TextStyle(
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
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.add_a_photo_outlined,
              color: Color(0xFFD97706),
              size: 20,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Profilingizga rasm yuklang',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFD97706),
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
        color: Colors.white,
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
              const Divider(height: 20, color: Color(0xFFF3F4F6)),
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

  Widget _buildMenuSection(BuildContext context) {
    final List<_MenuItem> jobSeekerItems = [
      _MenuItem(
        icon: Icons.person_outline,
        label: "Anketa to'ldirish",
        color: PRIMARY_BLUE,
        onTap:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const AnketaScreen())),
      ),
      _MenuItem(
        icon: Icons.folder_open_outlined,
        label: 'Mening arizalarim',
        color: const Color(0xFF7C3AED),
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MyApplicationsScreen()),
            ),
      ),
      // _MenuItem(
      //   icon: Icons.workspace_premium_outlined,
      //   label: 'Premium',
      //   color: const Color(0xFFD97706),
      //   onTap:
      //       () => Navigator.of(
      //         context,
      //       ).push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
      // ),
    ];

    final List<_MenuItem> employerItems = [
      _MenuItem(
        icon: Icons.business_outlined,
        label: 'Kompaniyani tahrirlash',
        color: PRIMARY_BLUE,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const EditEmployerScreen()),
        ),
      ),
      _MenuItem(
        icon: Icons.work_outline,
        label: 'Vakansiyalar',
        color: const Color(0xFF0891B2),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.people_outline,
        label: 'Nomzodlarni kuzatish',
        color: const Color(0xFF7C3AED),
        onTap: () {},
      ),
      _MenuItem(
        icon: Icons.workspace_premium_outlined,
        label: 'Premium',
        color: const Color(0xFFD97706),
        onTap:
            () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const PremiumScreen())),
      ),
    ];

    final List<_MenuItem> commonItems = [
      _MenuItem(
        icon: Icons.account_balance_wallet_outlined,
        label: 'Balans va to\'lov',
        color: const Color(0xFF16A34A),
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TopUpScreen(isEmployer: widget.isEmployer),
              ),
            ),
      ),
      _MenuItem(
        icon: Icons.notifications_outlined,
        label: 'Bildirishnomalar',
        color: const Color(0xFFEA580C),
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
      ),
      _MenuItem(
        icon: Icons.support_agent_outlined,
        label: 'Qo\'llab-quvvatlash',
        color: PRIMARY_BLUE,
        onTap:
            () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SupportChatScreen()),
            ),
      ),
      _MenuItem(
        icon: Icons.help_outline,
        label: 'Yordam',
        color: GRAY_TEXT,
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
        color: Colors.white,
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
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF3F4F6),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          ...List.generate(
            commonItems.length,
            (i) => Column(
              children: [
                _MenuItemTile(item: commonItems[i]),
                if (i < commonItems.length - 1)
                  const Divider(
                    height: 1,
                    indent: 56,
                    color: Color(0xFFF3F4F6),
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDC2626), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, color: Color(0xFFDC2626), size: 20),
            SizedBox(width: 8),
            Text(
              'Chiqish',
              style: TextStyle(
                color: Color(0xFFDC2626),
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
            color: PRIMARY_BLUE.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, color: PRIMARY_BLUE, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: GRAY_TEXT)),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: DARK_NAVY,
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
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: DARK_NAVY,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: GRAY_TEXT, size: 20),
          ],
        ),
      ),
    );
  }
}
