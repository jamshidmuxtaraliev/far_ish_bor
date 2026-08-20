import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../data/models/contact_unlock_model.dart';
import '../logic/vacancy_bloc.dart';
import '../../../../core/theme/jb_palette.dart';

class UnlockHistoryScreen extends StatefulWidget {
  const UnlockHistoryScreen({super.key});

  @override
  State<UnlockHistoryScreen> createState() => _UnlockHistoryScreenState();
}

class _UnlockHistoryScreenState extends State<UnlockHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VacancyBloc>().add(LoadUnlockHistoryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: context.jb.card,
              surfaceTintColor: context.jb.card,
              foregroundColor: context.jb.ink,
              elevation: 0,
              scrolledUnderElevation: 0.5,
              title: const Text('Otklik tarixi',
                  style:
                      TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            BlocBuilder<VacancyBloc, VacancyState>(
              builder: (context, state) {
                if (state.unlockHistoryStatus == FormzSubmissionStatus.inProgress) {
                  return SliverFillRemaining(
                    child: Center(
                        child:
                            CircularProgressIndicator(color: context.jb.blue)),
                  );
                }
                if (state.unlockHistory.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.lock_open_outlined,
                              size: 64, color: context.jb.gray),
                          SizedBox(height: 16),
                          Text("Ochilgan kontakt yo'q",
                              style: TextStyle(
                                  fontSize: 15, color: context.jb.gray)),
                          SizedBox(height: 8),
                          Text(
                            "Nomzod kontaktlarini ochgach bu yerda ko'rinadi",
                            style: TextStyle(
                                fontSize: 12, color: context.jb.gray),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final totalSpent = state.unlockHistory.fold<int>(
                    0, (sum, h) => sum + h.amount);

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _SummaryCard(
                        total: state.unlockHistory.length,
                        spent: totalSpent,
                      ),
                      const SizedBox(height: 16),
                      ...state.unlockHistory
                          .map((h) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 10),
                                child: _HistoryItem(item: h),
                              )),
                    ]),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final int spent;

  const _SummaryCard({required this.total, required this.spent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.jb.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
                label: 'Ochilgan',
                value: '$total ta',
                color: context.jb.blue),
          ),
          Container(width: 1, height: 40, color: context.jb.border),
          Expanded(
            child: _StatItem(
                label: "To'langan",
                value: _formatAmount(spent),
                color:
                    spent > 0 ? context.jb.red : context.jb.green),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(int amount) {
    if (amount == 0) return 'Bepul';
    final s = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(' ');
      buf.write(s[i]);
      count++;
    }
    return "${buf.toString().split('').reversed.join()} so'm";
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label,
            style: TextStyle(fontSize: 12, color: context.jb.gray)),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ContactUnlockHistoryModel item;

  const _HistoryItem({required this.item});

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}  ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.jb.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.jb.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: item.isFree
                  ? context.jb.green.withValues(alpha: 0.1)
                  : context.jb.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.isFree ? Icons.star_border : Icons.lock_open_outlined,
              color: item.isFree ? context.jb.green : context.jb.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Anketa #${item.anketaId}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: context.jb.ink)),
                const SizedBox(height: 2),
                Text(_formatDate(item.unlockedAt),
                    style: TextStyle(
                        fontSize: 12, color: context.jb.gray)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: item.isFree
                  ? context.jb.green.withValues(alpha: 0.1)
                  : context.jb.redBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.isFree
                  ? 'Bepul'
                  : '${_formatAmount(item.amount)} so\'m',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                    item.isFree ? context.jb.green : context.jb.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatAmount(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write(' ');
      buf.write(s[i]);
      count++;
    }
    return buf.toString().split('').reversed.join();
  }
}
