import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../data/models/saved_vacancy_model.dart';
import '../logic/vacancy_bloc.dart';

class SavedVacanciesScreen extends StatefulWidget {
  const SavedVacanciesScreen({super.key});

  @override
  State<SavedVacanciesScreen> createState() => _SavedVacanciesScreenState();
}

class _SavedVacanciesScreenState extends State<SavedVacanciesScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId != null) {
      context.read<VacancyBloc>().add(LoadSavedVacanciesEvent(userId));
    }
  }

  void _unsave(int vacancyId) {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId == null) return;
    context.read<VacancyBloc>().add(UnsaveVacancyEvent(userId, vacancyId));
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
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<VacancyBloc, VacancyState>(
                    buildWhen: (p, c) => p.savedVacancies != c.savedVacancies,
                    builder: (context, state) => Text(
                      'Saqlangan vakansiyalar (${state.savedVacancies.length})',
                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Keyinroq ko\'rib chiqish uchun saqlangan', style: TextStyle(color: Colors.white60, fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<VacancyBloc, VacancyState>(
                buildWhen: (p, c) => p.savedVacancies != c.savedVacancies || p.savedStatus != c.savedStatus,
                builder: (context, state) {
                  if (state.savedStatus.isInProgress) {
                    return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE, strokeWidth: 2));
                  }
                  if (state.savedVacancies.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                              child: const Icon(Icons.bookmark_border_outlined, color: GRAY_TEXT, size: 36),
                            ),
                            const SizedBox(height: 16),
                            const Text('Saqlangan vakansiya yo\'q', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: DARK_NAVY)),
                            const SizedBox(height: 6),
                            const Text(
                              'Vakansiyalar ro\'yxatida ★ tugmasini bosib saqlang',
                              style: TextStyle(fontSize: 13, color: GRAY_TEXT),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: PRIMARY_BLUE,
                    onRefresh: () async => _load(),
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.savedVacancies.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (ctx, i) => _SavedCard(
                        item: state.savedVacancies[i],
                        onUnsave: () => _unsave(state.savedVacancies[i].vacancyId),
                      ),
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

class _SavedCard extends StatelessWidget {
  final SavedVacancyModel item;
  final VoidCallback onUnsave;

  const _SavedCard({required this.item, required this.onUnsave});

  @override
  Widget build(BuildContext context) {
    final isActive = item.status == 'active';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.work_outline_rounded, size: 26, color: DARK_NAVY),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vakansiya #${item.vacancyId}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: DARK_NAVY),
                    ),
                    const SizedBox(height: 3),
                    if (item.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFF0FDF4) : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isActive ? 'Faol' : 'Nofaol',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? const Color(0xFF16A34A) : GRAY_TEXT,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onUnsave,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.bookmark_remove_rounded, color: Color(0xFFF43F5E), size: 20),
                ),
              ),
            ],
          ),
          if (item.comment != null) ...[
            const SizedBox(height: 10),
            Text(
              item.comment!,
              style: const TextStyle(fontSize: 13, color: GRAY_TEXT, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.attach_money_rounded, size: 16, color: Color(0xFF10B981)),
              const SizedBox(width: 3),
              Text(
                item.salaryDisplay,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
              ),
              if (item.ageDisplay.isNotEmpty) ...[
                const SizedBox(width: 14),
                const Icon(Icons.person_outline_rounded, size: 15, color: GRAY_TEXT),
                const SizedBox(width: 3),
                Text(item.ageDisplay, style: const TextStyle(fontSize: 13, color: GRAY_TEXT)),
              ],
            ],
          ),
          if (item.deadline != null || item.savedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (item.deadline != null) ...[
                  const Icon(Icons.schedule_outlined, size: 15, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 3),
                  Text(
                    'Muddat: ${item.deadline}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFF59E0B)),
                  ),
                ],
                if (item.deadline != null && item.savedAt != null) const Spacer(),
                if (item.savedAt != null) ...[
                  const Icon(Icons.bookmark_added_outlined, size: 15, color: GRAY_TEXT),
                  const SizedBox(width: 3),
                  Text(
                    item.savedAtDisplay,
                    style: const TextStyle(fontSize: 12, color: GRAY_TEXT),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
