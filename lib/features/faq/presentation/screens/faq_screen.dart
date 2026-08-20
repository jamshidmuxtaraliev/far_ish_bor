import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:formz/formz.dart';

import '../../../../core/locale/locale_cubit.dart';
import '../../data/models/faq_model.dart';
import '../logic/faq_bloc.dart';
import '../../../../core/theme/jb_palette.dart';

class FaqScreen extends StatefulWidget {
  final bool isEmployer;

  const FaqScreen({super.key, this.isEmployer = false});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  String get _audience => widget.isEmployer ? 'employer' : 'seeker';

  @override
  void initState() {
    super.initState();
    context.read<FaqBloc>().add(LoadFaqEvent(audience: _audience));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), ' ');

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LocaleCubit>().state.languageCode;
    final title =
        lang == 'ru' ? 'Часто задаваемые вопросы' : "Ko'p beriladigan savollar";

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        appBar: AppBar(
          backgroundColor: context.jb.card,
          foregroundColor: context.jb.ink,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: context.jb.ink)),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: lang == 'ru' ? 'Поиск...' : 'Qidirish...',
                  hintStyle: TextStyle(color: context.jb.grayLight, fontSize: 14),
                  prefixIcon: Icon(Icons.search_rounded, color: context.jb.grayLight, size: 20),
                  filled: true,
                  fillColor: context.jb.card,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.jb.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.jb.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: context.jb.blue, width: 1.5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<FaqBloc, FaqState>(
                builder: (context, state) {
                  if (state.status == FormzSubmissionStatus.inProgress && state.faqList.isEmpty) {
                    return Center(child: CircularProgressIndicator(color: context.jb.blue));
                  }
                  if (state.status == FormzSubmissionStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: context.jb.borderStrong),
                          const SizedBox(height: 12),
                          Text(
                            state.error?.errorMessage ?? 'Xatolik yuz berdi',
                            style: TextStyle(color: context.jb.gray),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.read<FaqBloc>().add(LoadFaqEvent(audience: _audience)),
                            child: const Text('Qayta urinish'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state.faqList.isEmpty) {
                    return Center(
                      child: Text('Hozircha savollar yo\'q', style: TextStyle(color: context.jb.gray)),
                    );
                  }

                  final filtered =
                      _query.isEmpty
                          ? state.faqList
                          : state.faqList.where((f) {
                            final q = f.questionFor(lang).toLowerCase();
                            final a = _stripHtml(f.answerFor(lang)).toLowerCase();
                            return q.contains(_query) || a.contains(_query);
                          }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('Hech narsa topilmadi', style: TextStyle(color: context.jb.gray)),
                    );
                  }

                  return RefreshIndicator(
                    color: context.jb.blue,
                    onRefresh: () async => context.read<FaqBloc>().add(LoadFaqEvent(audience: _audience)),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (_, i) => _FaqTile(faq: filtered[i], lang: lang),
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

class _FaqTile extends StatelessWidget {
  final FaqModel faq;
  final String lang;

  const _FaqTile({required this.faq, required this.lang});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.jb.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.jb.border, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.centerLeft,
          iconColor: context.jb.blue,
          collapsedIconColor: context.jb.grayLight,
          title: Text(
            faq.questionFor(lang),
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: context.jb.ink),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Html(
                data: faq.answerFor(lang),
                style: {
                  'body': Style(margin: Margins.zero, fontSize: FontSize(13), color: context.jb.gray),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
