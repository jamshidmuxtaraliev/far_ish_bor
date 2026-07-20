import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:formz/formz.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../data/models/faq_model.dart';
import '../logic/faq_bloc.dart';

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
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: JB_BG,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: JB_INK,
          elevation: 0,
          scrolledUnderElevation: 0,
          title: Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: JB_INK)),
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
                  hintStyle: const TextStyle(color: JB_GRAY_LIGHT, fontSize: 14),
                  prefixIcon: const Icon(Icons.search_rounded, color: JB_GRAY_LIGHT, size: 20),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: JB_BORDER, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: JB_BORDER, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: JB_BLUE, width: 1.5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<FaqBloc, FaqState>(
                builder: (context, state) {
                  if (state.status == FormzSubmissionStatus.inProgress && state.faqList.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: PRIMARY_BLUE));
                  }
                  if (state.status == FormzSubmissionStatus.failure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          Text(
                            state.error?.errorMessage ?? 'Xatolik yuz berdi',
                            style: const TextStyle(color: GRAY_TEXT),
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
                    return const Center(
                      child: Text('Hozircha savollar yo\'q', style: TextStyle(color: GRAY_TEXT)),
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
                    return const Center(
                      child: Text('Hech narsa topilmadi', style: TextStyle(color: GRAY_TEXT)),
                    );
                  }

                  return RefreshIndicator(
                    color: PRIMARY_BLUE,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: JB_BORDER, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedAlignment: Alignment.centerLeft,
          iconColor: JB_BLUE,
          collapsedIconColor: JB_GRAY_LIGHT,
          title: Text(
            faq.questionFor(lang),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: JB_INK),
          ),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Html(
                data: faq.answerFor(lang),
                style: {
                  'body': Style(margin: Margins.zero, fontSize: FontSize(13), color: GRAY_TEXT),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
