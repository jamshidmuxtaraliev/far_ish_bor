import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

import '../../../../core/theme/jb_palette.dart';
import '../../data/models/application_history_model.dart';
import '../logic/application_status.dart';
import '../logic/vacancy_bloc.dart';

/// Ekran 3 — «Otklik tarixi» (PROMPT_VAKANSIYA_OTKLIKLARI_MOBILE.md §5).
///
/// Ikkala rol uchun bitta ekran: `asEmployer` faqat endpoint yo'lini tanlaydi,
/// javob tuzilmasi bir xil. Tarix hech qachon bo'sh emas — ariza yaratilgan
/// payt (`null → pending`) ham yozuv sifatida keladi.
class ApplicationHistoryScreen extends StatefulWidget {
  final int applicationId;
  final bool asEmployer;

  /// Sarlavha ostidagi izoh: nomzod ismi (ish beruvchida) yoki kasb nomi.
  final String? subtitle;

  const ApplicationHistoryScreen({
    super.key,
    required this.applicationId,
    this.asEmployer = true,
    this.subtitle,
  });

  @override
  State<ApplicationHistoryScreen> createState() =>
      _ApplicationHistoryScreenState();
}

class _ApplicationHistoryScreenState extends State<ApplicationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() => context.read<VacancyBloc>().add(
        LoadApplicationHistoryEvent(
          widget.applicationId,
          asEmployer: widget.asEmployer,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: p.overlay,
      child: Scaffold(
        backgroundColor: p.bg,
        appBar: AppBar(
          backgroundColor: p.card,
          surfaceTintColor: p.card,
          foregroundColor: p.ink,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Otklik tarixi',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              if ((widget.subtitle ?? '').isNotEmpty)
                Text(
                  widget.subtitle!,
                  style: TextStyle(fontSize: 12.5, color: p.gray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        body: BlocBuilder<VacancyBloc, VacancyState>(
          buildWhen: (prev, curr) =>
              prev.applicationHistory != curr.applicationHistory ||
              prev.applicationHistoryStatus != curr.applicationHistoryStatus,
          builder: (context, state) {
            final history = state.applicationHistory;
            // Bloc app-scoped: eski arizaning tarixi qolib ketmasin.
            final isMine = history?.application?.id == widget.applicationId;

            if (!isMine || history == null) {
              if (state.applicationHistoryStatus.isFailure) {
                return _ErrorBox(
                  message: state.error?.errorMessage ?? 'Tarixni olib bo\'lmadi',
                  onRetry: _load,
                );
              }
              return Center(child: CircularProgressIndicator(color: p.blue));
            }

            return RefreshIndicator(
              color: p.blue,
              onRefresh: () async => _load(),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  if (history.application != null)
                    _ApplicationHeader(application: history.application!),
                  const SizedBox(height: 16),
                  if (history.timeline.isEmpty)
                    Text(
                      'Tarix topilmadi',
                      style: TextStyle(fontSize: 13.5, color: p.gray),
                    )
                  else
                    _Timeline(entries: history.timeline),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ApplicationHeader extends StatelessWidget {
  final ApplicationHistoryRefModel application;
  const _ApplicationHeader({required this.application});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final a = application;
    final tone = applicationStatusTone(a.status);
    final title = a.candidateName ?? a.vacancyTitle ?? 'Ariza #${a.id}';
    final subtitle = a.candidateName != null
        ? (a.vacancyTitle ?? '')
        : (a.employerName ?? '');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: p.ink),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: tone.bg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  a.statusLabel ?? applicationStatusFallbackLabel(a.status),
                  style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: tone.color),
                ),
              ),
            ],
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(fontSize: 13.5, color: p.gray)),
          ],
          if (a.appliedDisplay.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.schedule, size: 15, color: p.gray),
                const SizedBox(width: 6),
                Text(
                  'Yuborilgan: ${a.appliedDisplay}',
                  style: TextStyle(fontSize: 12.5, color: p.gray),
                ),
              ],
            ),
          ],
          if ((a.coverMessage ?? '').isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              a.coverMessage!,
              style: TextStyle(
                fontSize: 13,
                color: p.ink,
                height: 1.45,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Vertikal timeline: oxirgi nuqta — joriy holat (rangli), qolganlari kul rang.
class _Timeline extends StatelessWidget {
  final List<ApplicationTimelineEntryModel> entries;
  const _Timeline({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++)
          _TimelineRow(
            entry: entries[i],
            isLast: i == entries.length - 1,
            isCurrent: i == entries.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final ApplicationTimelineEntryModel entry;
  final bool isLast;
  final bool isCurrent;

  const _TimelineRow({
    required this.entry,
    required this.isLast,
    required this.isCurrent,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final color =
        isCurrent ? applicationStatusColor(entry.toStatus) : p.grayLight;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chap ustun: nuqta + chiziq
          Column(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: isCurrent ? 0.18 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: isCurrent ? 2 : 1),
                ),
                child: Icon(
                  applicationStatusIcon(entry.toStatus),
                  size: 13,
                  color: color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 2, color: p.border),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          entry.toLabel ??
                              applicationStatusFallbackLabel(entry.toStatus),
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink,
                          ),
                        ),
                      ),
                      if (entry.atDisplay.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          entry.atDisplay,
                          style: TextStyle(fontSize: 11.5, color: p.gray),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.transitionDisplay,
                    style: TextStyle(fontSize: 12.5, color: p.gray),
                  ),
                  if ((entry.comment ?? '').isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      entry.comment!,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: p.ink,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 13, color: p.grayLight),
                      const SizedBox(width: 4),
                      Text(
                        entry.actorDisplay,
                        style: TextStyle(fontSize: 12, color: p.grayLight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorBox({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 44, color: p.gray),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: p.gray),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onRetry,
              child: Text('Qayta urinish', style: TextStyle(color: p.blue)),
            ),
          ],
        ),
      ),
    );
  }
}
