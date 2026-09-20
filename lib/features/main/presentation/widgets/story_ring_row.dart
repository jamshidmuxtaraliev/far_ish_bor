import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/jb_palette.dart';
import '../../../../core/utils/custom_cached_network_image.dart';
import '../../data/models/story_model.dart';
import '../logic/vacancy_bloc.dart';
import '../screens/story_viewer_screen.dart';

/// Bosh ekran tepasidagi story lentasi (`GET /story/public`).
///
/// Story bo'lmasa — hech narsa chizilmaydi (bo'sh joy ham qolmaydi).
class StoryRingRow extends StatefulWidget {
  /// Story ichidagi vakansiya ochilmasa qaysi tabga o'tish (1 = Ishlar).
  final ValueChanged<int>? onSelectTab;

  const StoryRingRow({super.key, this.onSelectTab});

  @override
  State<StoryRingRow> createState() => _StoryRingRowState();
}

class _StoryRingRowState extends State<StoryRingRow> {
  @override
  void initState() {
    super.initState();
    context.read<VacancyBloc>().add(LoadStoriesEvent());
  }

  void _open(List<StoryModel> stories, int index) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, __, ___) => StoryViewerScreen(
          stories: stories,
          initialIndex: index,
          onSelectTab: widget.onSelectTab,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacancyBloc, VacancyState>(
      buildWhen: (a, b) => a.stories != b.stories || a.viewedStoryIds != b.viewedStoryIds,
      builder: (context, state) {
        final stories = state.stories;
        if (stories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 104,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: stories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) => _StoryRing(
              story: stories[i],
              seen: state.viewedStoryIds.contains(stories[i].id),
              onTap: () => _open(stories, i),
            ),
          ),
        );
      },
    );
  }
}

class _StoryRing extends StatelessWidget {
  final StoryModel story;
  final bool seen;
  final VoidCallback onTap;

  const _StoryRing({required this.story, required this.seen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 66,
              height: 66,
              padding: const EdgeInsets.all(2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Ko'rilgani so'nadi — Instagram/Telegram naqshi.
                gradient: seen
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [context.jb.blue, context.jb.violet],
                      ),
                color: seen ? context.jb.border : null,
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(shape: BoxShape.circle, color: context.jb.bg),
                child: ClipOval(
                  child: CustomCachedNetworkImage(url: story.coverUrl, fit: BoxFit.cover),
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              story.title,
              style: TextStyle(
                fontSize: 11,
                color: seen ? context.jb.gray : context.jb.ink,
                fontWeight: seen ? FontWeight.w400 : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
