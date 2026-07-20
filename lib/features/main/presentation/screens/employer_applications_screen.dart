import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../data/models/employer_application_model.dart';
import '../logic/vacancy_bloc.dart';
import 'applicant_profile_screen.dart';
import 'messages_screen.dart';

class EmployerApplicationsScreen extends StatefulWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  State<EmployerApplicationsScreen> createState() =>
      _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState
    extends State<EmployerApplicationsScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    context.read<VacancyBloc>().add(LoadEmployerApplicationsEvent());
  }

  void _comingSoon(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tez orada qo\'shiladi')));
  }

  void _openChat(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const MessagesScreen()));
  }

  void _showProfile(BuildContext context, EmployerApplicationModel app) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ApplicantProfileScreen(app: app)));
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: JB_BG,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 18,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomzodlar',
                    style: TextStyle(
                      color: JB_INK,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: JB_CHIP_BG,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            onChanged:
                                (v) => setState(
                                  () => _searchQuery = v.trim().toLowerCase(),
                                ),
                            style: const TextStyle(
                              color: DARK_NAVY,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Qidirish...',
                              hintStyle: TextStyle(color: GRAY_TEXT),
                              prefixIcon: Icon(
                                Icons.search,
                                color: GRAY_TEXT,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _comingSoon(context),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: PRIMARY_BLUE,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.tune,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<VacancyBloc, VacancyState>(
                buildWhen:
                    (p, c) =>
                        p.employerApplications != c.employerApplications ||
                        p.employerAppsStatus != c.employerAppsStatus,
                builder: (context, state) {
                  if (state.employerAppsStatus.isInProgress) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: PRIMARY_BLUE,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (state.employerApplications.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.inbox_outlined,
                              color: GRAY_TEXT,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Hali ariza kelmagan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: DARK_NAVY,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Vakansiyalaringizga nomzodlar ariza yuborishini kuting',
                            style: TextStyle(fontSize: 13, color: GRAY_TEXT),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  }
                  final apps =
                      _searchQuery.isEmpty
                          ? state.employerApplications
                          : state.employerApplications.where((a) {
                            final name = (a.anketaFullname ?? '').toLowerCase();
                            final job =
                                (a.anketaJobType ??
                                        a.requirementJobTypeName ??
                                        '')
                                    .toLowerCase();
                            return name.contains(_searchQuery) ||
                                job.contains(_searchQuery);
                          }).toList();

                  return RefreshIndicator(
                    color: PRIMARY_BLUE,
                    onRefresh:
                        () async => context.read<VacancyBloc>().add(
                          LoadEmployerApplicationsEvent(),
                        ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                          child: Row(
                            children: [
                              Text(
                                '${apps.length} ta nomzod',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: GRAY_TEXT,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _comingSoon(context),
                                child: const Text(
                                  'Saralash',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: PRIMARY_BLUE,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child:
                              apps.isEmpty
                                  ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text(
                                        'Qidiruv natijasi topilmadi',
                                        style: TextStyle(color: GRAY_TEXT),
                                      ),
                                    ),
                                  )
                                  : ListView.separated(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      16,
                                    ),
                                    itemCount: apps.length,
                                    separatorBuilder:
                                        (_, __) => const SizedBox(height: 12),
                                    itemBuilder:
                                        (ctx, i) => _AppCard(
                                          app: apps[i],
                                          onViewProfile:
                                              () => _showProfile(
                                                context,
                                                apps[i],
                                              ),
                                          onMessage: () => _openChat(context),
                                        ),
                                  ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Deterministic placeholders until the backend exposes rating / experience.
// TODO: reyting va tajriba backenddan kelganda haqiqiy qiymatga almashtirilsin.
double _placeholderRating(int id) => 4.5 + (id % 5) * 0.1;
int _placeholderExperience(int id) => 1 + id % 7;

String _initialsOf(String? name) {
  final n = (name ?? '').trim();
  if (n.isEmpty) return '?';
  final parts = n.split(RegExp(r'\s+'));
  if (parts.length >= 2 && parts[1].isNotEmpty) {
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
  return n[0].toUpperCase();
}

/// Ariza statusiga mos rang (badge foni + matni).
({Color color, Color bg}) _statusTone(String status) {
  switch (status) {
    case 'hired':
    case 'accepted':
    case 'probation':
      return (color: const Color(0xFF15803D), bg: GREEN_COLOR.withValues(alpha: 0.12));
    case 'rejected':
      return (color: RED_COLOR, bg: RED_COLOR.withValues(alpha: 0.1));
    case 'missed':
      return (color: AMBER_COLOR, bg: AMBER_COLOR.withValues(alpha: 0.14));
    case 'invited':
    case 'scheduled':
    case 'confirmed':
    case 'on_way':
    case 'arrived':
      return (color: const Color(0xFFB45309), bg: AMBER_COLOR.withValues(alpha: 0.14));
    case 'viewed':
      return (color: PRIMARY_BLUE, bg: PRIMARY_BLUE.withValues(alpha: 0.1));
    default: // pending
      return (color: GRAY_TEXT, bg: LIGHT_GRAY_BG);
  }
}

Widget _statusBadge(String label, ({Color color, Color bg}) tone) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: tone.bg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(
          fontSize: 11.5, fontWeight: FontWeight.w600, color: tone.color),
    ),
  );
}

Widget _metaChip(IconData icon, String text, {Color iconColor = GRAY_TEXT}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: iconColor),
      const SizedBox(width: 4),
      Text(text, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
    ],
  );
}

class _AppCard extends StatelessWidget {
  final EmployerApplicationModel app;
  final VoidCallback onViewProfile;
  final VoidCallback onMessage;

  const _AppCard({
    required this.app,
    required this.onViewProfile,
    required this.onMessage,
  });

  @override
  Widget build(BuildContext context) {
    final tone = _statusTone(app.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CARD_BORDER),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFD1D5DB), Color(0xFF9CA3AF)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initialsOf(app.anketaFullname),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            app.anketaFullname ?? 'Nomzod',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: DARK_NAVY,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusBadge(app.statusLabel, tone),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      app.anketaJobType ?? app.requirementJobTypeName ?? 'Kasb',
                      style: const TextStyle(fontSize: 14, color: GRAY_TEXT),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 14,
                      runSpacing: 6,
                      children: [
                        if (app.anketaRegion != null)
                          _metaChip(
                              Icons.location_on_outlined, app.anketaRegion!),
                        _metaChip(Icons.work_outline,
                            '${_placeholderExperience(app.id)} yil tajriba'),
                        _metaChip(Icons.star_rounded,
                            _placeholderRating(app.id).toStringAsFixed(1),
                            iconColor: PRIMARY_BLUE),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    onPressed: onViewProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PRIMARY_BLUE,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Profil ko'rish",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: OutlinedButton(
                    onPressed: onMessage,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: DARK_NAVY,
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Xabar yuborish',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
