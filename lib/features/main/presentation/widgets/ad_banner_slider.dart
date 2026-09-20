import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/jb_palette.dart';
import '../../../../core/utils/ad_text.dart';
import '../../../../core/utils/custom_cached_network_image.dart';
import '../../../../core/utils/utils.dart';
import '../../data/models/ad_campaign_model.dart';
import '../logic/vacancy_bloc.dart';
import '../screens/job_detail_screen.dart';

/// Bosh ekrandagi reklama lentasi — `GET /ad-campaign/public`.
///
/// Ommaviy saytdagi `AdBannerSlider.vue` ning mobil ko'rinishi: rasm tepada,
/// aniq ma'lumotlar ostida, 6 soniyada avto-aylanish, svayp va to'liq matn
/// oynasi.
///
/// ⚠ Vakansiya bannerlari (`is_vacancy_banner`) — 1080×1080 kvadrat va kasb,
/// maosh, telefon RASM ICHIDA yozilgan. Shuning uchun ularda `BoxFit.cover`
/// ISHLATILMAYDI (matnli chekkasi qirqiladi) va pastda ma'lumot takrorlanmaydi.
class AdBannerSlider extends StatefulWidget {
  /// Reklamadagi vakansiya ochilmasa qaysi tabga o'tish (1 = Ishlar).
  final ValueChanged<int>? onSelectTab;

  const AdBannerSlider({super.key, this.onSelectTab});

  @override
  State<AdBannerSlider> createState() => _AdBannerSliderState();
}

class _AdBannerSliderState extends State<AdBannerSlider> {
  final PageController _controller = PageController(viewportFraction: 0.92);
  Timer? _autoTimer;
  int _page = 0;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    context.read<VacancyBloc>().add(LoadPublicAdsEvent());
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _syncAutoRotate(int count) {
    _count = count;
    // Bitta reklamada aylantirishning ma'nosi yo'q.
    if (count < 2) {
      _autoTimer?.cancel();
      _autoTimer = null;
      return;
    }
    _autoTimer ??= Timer.periodic(const Duration(seconds: 6), (_) {
      if (!mounted || !_controller.hasClients || _count < 2) return;
      _controller.animateToPage(
        (_page + 1) % _count,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  /// Reklamadagi vakansiyani ochadi. Vakansiya joriy ro'yxatda bo'lsa
  /// to'g'ridan-to'g'ri, aks holda "Ishlar" tabiga o'tkazamiz — id bo'yicha
  /// bitta vakansiyani oladigan endpoint hozircha yo'q.
  void _openVacancy(int vacancyId) {
    final list = context.read<VacancyBloc>().state.seekerVacancies;
    for (final v in list) {
      if (v.id == vacancyId) {
        startScreen(context, screen: JobDetailScreen(vacancy: v));
        return;
      }
    }
    widget.onSelectTab?.call(1);
  }

  void _openDetails(AdCampaignModel ad) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdDetailsSheet(
        ad: ad,
        onOpenVacancy: ad.vacancyId == null ? null : () => _openVacancy(ad.vacancyId!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VacancyBloc, VacancyState>(
      buildWhen: (a, b) => a.ads != b.ads,
      builder: (context, state) {
        final ads = state.ads;
        // Reklama yo'q yoki kelmadi — bo'sh joy ham qoldirilmaydi.
        if (ads.isEmpty) return const SizedBox.shrink();
        _syncAutoRotate(ads.length);

        final cardWidth = MediaQuery.sizeOf(context).width * 0.92 - 8;
        // Vakansiya bannerlari kvadrat; aralash lentada bitta balandlik
        // bo'lishi shart, shuning uchun eng talabchani bo'yicha olamiz.
        final height = (cardWidth * 0.86).clamp(190.0, 300.0);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
              child: Row(
                children: [
                  Text(
                    'Reklama',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.jb.ink),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: context.jb.chipBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'reklama',
                      style: TextStyle(fontSize: 10, color: context.jb.gray),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: height,
              child: PageView.builder(
                controller: _controller,
                itemCount: ads.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _AdCard(ad: ads[i], onTap: () => _openDetails(ads[i])),
                ),
              ),
            ),
            if (ads.length > 1)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < ads.length; i++)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _page ? context.jb.blue : context.jb.border,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

// ── Karta ───────────────────────────────────────────────────────────────────

class _AdCard extends StatelessWidget {
  final AdCampaignModel ad;
  final VoidCallback onTap;

  const _AdCard({required this.ad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final parsed = ad.parsed;
    final title = parsed.title.isNotEmpty ? parsed.title : ad.advertiserName;
    final url = ad.imageUrl;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.jb.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.jb.border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: url == null
            ? _TextOnlyBody(ad: ad, title: title, parsed: parsed)
            : Stack(
                fit: StackFit.expand,
                children: [
                  // Xira fon nusxasi — kvadrat banner keng ramkada yon
                  // tomonlarda bo'sh oq chiziq qoldirmasin.
                  CustomCachedNetworkImage(url: url, fit: BoxFit.cover),
                  Container(color: context.jb.scrim),
                  CustomCachedNetworkImage(url: url, fit: BoxFit.contain),
                  // Vakansiya bannerida ma'lumot rasm ichida — faqat manba
                  // yozuvini ko'rsatamiz.
                  if (!ad.isVacancyBanner)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(14, 22, 14, 12),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black87],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (parsed.facts.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                parsed.facts.take(2).map((f) => f.value).join(' · '),
                                style: const TextStyle(color: Colors.white70, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}

/// Rasmsiz e'lon — matn kartaga aylanadi.
class _TextOnlyBody extends StatelessWidget {
  final AdCampaignModel ad;
  final String title;
  final ParsedAd parsed;

  const _TextOnlyBody({required this.ad, required this.title, required this.parsed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (ad.advertiserName.isNotEmpty)
            Text(
              ad.advertiserName,
              style: TextStyle(fontSize: 12, color: context.jb.gray),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.jb.ink),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final f in parsed.facts.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        Icon(_iconData(f.icon), size: 15, color: context.jb.blue),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            f.value,
                            style: TextStyle(fontSize: 13, color: context.jb.ink),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// [ad_text.dart] dagi ikonka kaliti → Material ikonkasi.
IconData _iconData(String key) {
  switch (key) {
    case 'building':
      return Icons.business_outlined;
    case 'user':
      return Icons.person_outline;
    case 'users':
      return Icons.groups_outlined;
    case 'wallet':
      return Icons.payments_outlined;
    case 'pin':
      return Icons.location_on_outlined;
    case 'clock':
      return Icons.schedule_outlined;
    case 'phone':
      return Icons.phone_outlined;
    case 'age':
      return Icons.cake_outlined;
    case 'check':
      return Icons.check_circle_outline;
    default:
      return Icons.circle_outlined;
  }
}

// ── To'liq matn oynasi ──────────────────────────────────────────────────────

class _AdDetailsSheet extends StatelessWidget {
  final AdCampaignModel ad;
  final VoidCallback? onOpenVacancy;

  const _AdDetailsSheet({required this.ad, this.onOpenVacancy});

  @override
  Widget build(BuildContext context) {
    final parsed = ad.parsed;
    final title = parsed.title.isNotEmpty ? parsed.title : ad.advertiserName;
    final url = ad.imageUrl;
    final phone = ad.phone;

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Container(
        decoration: BoxDecoration(
          color: context.jb.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: context.jb.border, borderRadius: BorderRadius.circular(2)),
            ),
            Expanded(
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                children: [
                  if (url != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CustomCachedNetworkImage(url: url, fit: BoxFit.contain),
                    ),
                  if (url != null) const SizedBox(height: 14),
                  if (ad.advertiserName.isNotEmpty)
                    Text(ad.advertiserName, style: TextStyle(fontSize: 12, color: context.jb.gray)),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: context.jb.ink),
                  ),
                  const SizedBox(height: 14),
                  for (final f in parsed.facts)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_iconData(f.icon), size: 17, color: context.jb.blue),
                          const SizedBox(width: 9),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: TextStyle(fontSize: 14, color: context.jb.ink, height: 1.35),
                                children: [
                                  TextSpan(text: '${f.label}: ', style: TextStyle(color: context.jb.gray)),
                                  TextSpan(text: f.value, style: const TextStyle(fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (parsed.body.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      parsed.body.join('\n'),
                      style: TextStyle(fontSize: 14, color: context.jb.ink, height: 1.45),
                    ),
                  ],
                  if (ad.address != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on_outlined, size: 17, color: context.jb.blue),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(ad.address!, style: TextStyle(fontSize: 14, color: context.jb.ink)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    if (phone != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => launchPhoneDialer(phone),
                          icon: const Icon(Icons.phone, size: 18),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: context.jb.blue,
                            side: BorderSide(color: context.jb.blue),
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          label: const Text("Qo'ng'iroq"),
                        ),
                      ),
                    if (phone != null && onOpenVacancy != null) const SizedBox(width: 12),
                    if (onOpenVacancy != null)
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            onOpenVacancy!();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.jb.blue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size.fromHeight(48),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text('Vakansiyani ochish'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
