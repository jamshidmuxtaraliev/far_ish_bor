import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../data/models/application_access.dart';
import '../../data/models/employer_application_model.dart';
import '../logic/vacancy_bloc.dart';
import 'applicant_profile_screen.dart';
import 'messages_screen.dart';
import '../../../../core/theme/jb_palette.dart';

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
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: Column(
          children: [
            Container(
              width: double.infinity,
              color: context.jb.card,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 18,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nomzodlar',
                    style: TextStyle(
                      color: context.jb.ink,
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
                            color: context.jb.chipBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: TextField(
                            onChanged:
                                (v) => setState(
                                  () => _searchQuery = v.trim().toLowerCase(),
                                ),
                            style: TextStyle(
                              color: context.jb.ink,
                              fontSize: 14,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Qidirish...',
                              hintStyle: TextStyle(color: context.jb.gray),
                              prefixIcon: Icon(
                                Icons.search,
                                color: context.jb.gray,
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
                            color: context.jb.blue,
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
                    return Center(
                      child: CircularProgressIndicator(
                        color: context.jb.blue,
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
                              color: context.jb.cardAlt,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.inbox_outlined,
                              color: context.jb.gray,
                              size: 36,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hali ariza kelmagan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: context.jb.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Vakansiyalaringizga nomzodlar ariza yuborishini kuting',
                            style: TextStyle(fontSize: 13, color: context.jb.gray),
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
                    color: context.jb.blue,
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
                                style: TextStyle(
                                  fontSize: 13,
                                  color: context.jb.gray,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () => _comingSoon(context),
                                child: Text(
                                  'Saralash',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: context.jb.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child:
                              apps.isEmpty
                                  ? Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(24),
                                      child: Text(
                                        'Qidiruv natijasi topilmadi',
                                        style: TextStyle(color: context.jb.gray),
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
      return (color: jb.green, bg: jb.green.withValues(alpha: 0.12));
    case 'rejected':
      return (color: jb.red, bg: jb.red.withValues(alpha: 0.1));
    case 'missed':
      return (color: jb.amber, bg: jb.amber.withValues(alpha: 0.14));
    case 'invited':
    case 'scheduled':
    case 'confirmed':
    case 'on_way':
    case 'arrived':
      return (color: jb.amber, bg: jb.amber.withValues(alpha: 0.14));
    case 'viewed':
      return (color: jb.blue, bg: jb.blue.withValues(alpha: 0.1));
    default: // pending
      return (color: jb.gray, bg: jb.bg);
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

Widget _metaChip(IconData icon, String text, {Color? iconColor}) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 15, color: iconColor ?? jb.gray),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 13, color: jb.gray)),
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
    final chatUnlocked = isApplicationAccepted(app.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.jb.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.jb.border),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [context.jb.borderStrong, context.jb.grayLight],
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: context.jb.ink,
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
                      style: TextStyle(fontSize: 14, color: context.jb.gray),
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
                            iconColor: context.jb.blue),
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
                      backgroundColor: context.jb.blue,
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
                    // Chat faqat ariza qabul qilingandan keyin ochiladi.
                    onPressed: chatUnlocked ? onMessage : null,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.jb.ink,
                      disabledForegroundColor: context.jb.gray,
                      side: BorderSide(color: context.jb.borderStrong),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!chatUnlocked) ...[
                          const Icon(Icons.lock_outline_rounded, size: 15),
                          const SizedBox(width: 6),
                        ],
                        const Text(
                          'Xabar yuborish',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
