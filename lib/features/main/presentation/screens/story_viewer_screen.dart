import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/custom_cached_network_image.dart';
import '../../../../core/utils/utils.dart';
import '../../data/models/story_model.dart';
import '../logic/vacancy_bloc.dart';
import 'job_detail_screen.dart';

/// To'liq ekranli story ko'ruvchi.
///
/// Boshqaruv: o'ng tomonga bosish — keyingisi, chapga — oldingisi, bosib
/// turish — pauza, pastga sudrash — yopish. Oxirgi story tugagach ekran
/// o'zi yopiladi.
class StoryViewerScreen extends StatefulWidget {
  final List<StoryModel> stories;
  final int initialIndex;
  final ValueChanged<int>? onSelectTab;

  const StoryViewerScreen({
    super.key,
    required this.stories,
    this.initialIndex = 0,
    this.onSelectTab,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> with SingleTickerProviderStateMixin {
  static const _duration = Duration(seconds: 6);

  late final AnimationController _progress;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.stories.length - 1);
    _progress = AnimationController(vsync: this, duration: _duration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) _next();
      });
    _start();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  void _start() {
    _progress
      ..reset()
      ..forward();
    // Ko'rishlar hisoblagichi — har bir ochilgan story uchun bir marta.
    context.read<VacancyBloc>().add(MarkStoryViewedEvent(widget.stories[_index].id));
  }

  void _next() {
    if (_index >= widget.stories.length - 1) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() => _index++);
    _start();
  }

  void _prev() {
    if (_index == 0) {
      // Birinchi storyda chapga bosilsa boshidan qayta boshlanadi.
      _start();
      return;
    }
    setState(() => _index--);
    _start();
  }

  /// Story ichidagi tugma. Vakansiya joriy ro'yxatda bo'lsa to'g'ridan-to'g'ri
  /// ochiladi, aks holda "Ishlar" tabiga o'tkazamiz — id bo'yicha bitta
  /// vakansiyani oladigan endpoint hozircha yo'q.
  void _onAction(StoryModel story) {
    if (story.linkType == 'url' && (story.linkUrl?.isNotEmpty ?? false)) {
      launchInBrowser(story.linkUrl!);
      return;
    }
    if (story.linkType != 'vacancy' || story.vacancyId == null) return;

    final list = context.read<VacancyBloc>().state.seekerVacancies;
    for (final v in list) {
      if (v.id == story.vacancyId) {
        Navigator.of(context).pop();
        startScreen(context, screen: JobDetailScreen(vacancy: v));
        return;
      }
    }
    Navigator.of(context).pop();
    widget.onSelectTab?.call(1);
  }

  @override
  Widget build(BuildContext context) {
    final story = widget.stories[_index];
    final width = MediaQuery.sizeOf(context).width;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          // Bosib turilganda pauza — matnni o'qishga ulguradi.
          onLongPressStart: (_) => _progress.stop(),
          onLongPressEnd: (_) => _progress.forward(),
          onTapUp: (details) {
            if (details.localPosition.dx < width * 0.32) {
              _prev();
            } else {
              _next();
            }
          },
          // Pastga sudrab yopish
          onVerticalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 200) Navigator.of(context).maybePop();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomCachedNetworkImage(url: story.imageUrl, fit: BoxFit.contain),

              // Tepadagi progress chiziqlari + yopish
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Row(
                        children: [
                          for (var i = 0; i < widget.stories.length; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2),
                                child: _ProgressBar(
                                  controller: _progress,
                                  state: i < _index
                                      ? _BarState.done
                                      : (i == _index ? _BarState.active : _BarState.pending),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 8, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              story.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                shadows: [Shadow(color: Colors.black54, blurRadius: 6)],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Pastdagi matn + tugma
              if (story.text != null || story.hasAction)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black87],
                      ),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (story.text != null)
                            Text(
                              story.text!,
                              style: const TextStyle(color: Colors.white, fontSize: 15, height: 1.4),
                            ),
                          if (story.hasAction) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => _onAction(story),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: Text(
                                  story.actionLabel,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _BarState { done, active, pending }

class _ProgressBar extends StatelessWidget {
  final AnimationController controller;
  final _BarState state;

  const _ProgressBar({required this.controller, required this.state});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 3,
        child: state == _BarState.active
            ? AnimatedBuilder(
                animation: controller,
                builder: (context, _) => LinearProgressIndicator(
                  value: controller.value,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : Container(color: state == _BarState.done ? Colors.white : Colors.white24),
      ),
    );
  }
}
