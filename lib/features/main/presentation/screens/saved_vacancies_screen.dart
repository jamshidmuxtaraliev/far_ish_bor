import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_ui.dart';
import '../../../auth/presentation/logic/auth_bloc.dart';
import '../../data/models/saved_vacancy_model.dart';
import '../logic/vacancy_bloc.dart';
import '../../../../core/theme/jb_palette.dart';

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
                bottom: 22,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saqlangan', style: TextStyle(color: context.jb.ink, fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text("Saqlab qo'yilgan vakansiyalar", style: TextStyle(color: context.jb.gray, fontSize: 14)),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<VacancyBloc, VacancyState>(
                buildWhen: (p, c) => p.savedVacancies != c.savedVacancies || p.savedStatus != c.savedStatus,
                builder: (context, state) {
                  if (state.savedStatus.isInProgress) {
                    return Center(child: CircularProgressIndicator(color: context.jb.blue, strokeWidth: 2));
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
                              decoration: BoxDecoration(color: context.jb.cardAlt, borderRadius: BorderRadius.circular(20)),
                              child: Icon(Icons.bookmark_border_outlined, color: context.jb.gray, size: 36),
                            ),
                            const SizedBox(height: 16),
                            Text('Saqlangan vakansiya yo\'q', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: context.jb.ink)),
                            const SizedBox(height: 6),
                            Text(
                              'Vakansiyalar ro\'yxatida ★ tugmasini bosib saqlang',
                              style: TextStyle(fontSize: 13, color: context.jb.gray),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                    color: context.jb.blue,
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
      padding: const EdgeInsets.all(18),
      decoration: jbCardDecoration(),
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
                  color: context.jb.chipBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(Icons.work_outline_rounded, size: 26, color: context.jb.blue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vakansiya #${item.vacancyId}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.jb.ink),
                    ),
                    const SizedBox(height: 3),
                    if (item.status != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? context.jb.greenBg : context.jb.cardAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isActive ? 'Faol' : 'Nofaol',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? context.jb.green : context.jb.gray,
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
                    color: context.jb.redBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.bookmark_remove_rounded, color: context.jb.red, size: 20),
                ),
              ),
            ],
          ),
          if (item.comment != null) ...[
            const SizedBox(height: 10),
            Text(
              item.comment!,
              style: TextStyle(fontSize: 13, color: context.jb.gray, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: 12),
          Divider(height: 1, color: context.jb.cardAlt),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.attach_money_rounded, size: 16, color: context.jb.green),
              const SizedBox(width: 3),
              Text(
                item.salaryDisplay,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.jb.green),
              ),
              if (item.ageDisplay.isNotEmpty) ...[
                const SizedBox(width: 14),
                Icon(Icons.person_outline_rounded, size: 15, color: context.jb.gray),
                const SizedBox(width: 3),
                Text(item.ageDisplay, style: TextStyle(fontSize: 13, color: context.jb.gray)),
              ],
            ],
          ),
          if (item.deadline != null || item.savedAt != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (item.deadline != null) ...[
                  Icon(Icons.schedule_outlined, size: 15, color: context.jb.amber),
                  const SizedBox(width: 3),
                  Text(
                    'Muddat: ${item.deadline}',
                    style: TextStyle(fontSize: 12, color: context.jb.amber),
                  ),
                ],
                if (item.deadline != null && item.savedAt != null) const Spacer(),
                if (item.savedAt != null) ...[
                  Icon(Icons.bookmark_added_outlined, size: 15, color: context.jb.gray),
                  const SizedBox(width: 3),
                  Text(
                    item.savedAtDisplay,
                    style: TextStyle(fontSize: 12, color: context.jb.gray),
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
