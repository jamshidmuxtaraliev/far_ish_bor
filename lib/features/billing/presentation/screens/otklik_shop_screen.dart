import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/jb_palette.dart';
import '../../../../core/theme/jb_ui.dart';
import '../../data/models/balance_model.dart' show formatSom;
import '../../data/models/otklik_shop_model.dart';
import '../../data/models/subscription_tariff_model.dart';
import '../logic/billing_bloc.dart';

/// Otklik do'koni — ish beruvchi O'ZI sotib oladigan yagona narsa.
///
/// ⚠ Bu ekran BALANSNI TO'LDIRISH o'rniga turadi: ish beruvchiga pul emas,
/// **otklik** kerak (nomzod kontaktini ochish huquqi). Shuning uchun bosh
/// sahifadagi tugma ham, profil menyusi ham shu yerga olib keladi.
/// Premium A/B/V bu yerda YO'Q — uni faqat operator shartnoma bilan biriktiradi
/// (docs/PROMPT_PREMIUM_YOQ_MOBILE.md).
///
/// Ikki yo'l:
///   1. **Paket** — bir martalik, `qty` ta otklik, 30 (+bonus) kun.
///   2. **Obuna** — oylik tarif, har 30 kunda kvota yangilanadi.
///
/// To'lov: `checkout_url` bo'lsa Payme/Click ILOVASI darhol ochiladi (oraliq
/// sahifa yo'q — docs/PROMPT_OTKLIK_ONLY_MOBILE.md §5.1).
class OtklikShopScreen extends StatefulWidget {
  /// `1` — "Obuna tariflari" tabi bilan ochiladi (masalan vakansiya limiti
  /// 409 xatosidan kelinganda).
  final int initialTab;

  const OtklikShopScreen({super.key, this.initialTab = 0});

  @override
  State<OtklikShopScreen> createState() => _OtklikShopScreenState();
}

class _OtklikShopScreenState extends State<OtklikShopScreen> {
  late int _tab = widget.initialTab.clamp(0, 1);

  /// Obuna tabidagi tanlangan davr (oy). `periods` serverdan kelgach
  /// birinchisiga tushadi.
  int? _months;

  /// So'rov ketayotgan paket/tarif — faqat o'sha tugmada indikator aylansin.
  int? _busyId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    final bloc = context.read<BillingBloc>();
    bloc.add(const LoadOtklikShopEvent());
    bloc.add(const LoadSubscriptionTariffsEvent());
  }

  Future<void> _refresh() async {
    _load();
    await Future<void>.delayed(const Duration(milliseconds: 600));
  }

  void _snack(String message, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // ── Sotib olish ────────────────────────────────────────────────────────────

  void _buyPackage(OtklikPackage pkg, {required bool fromBalance}) {
    setState(() => _busyId = pkg.id);
    context.read<BillingBloc>().add(
          BuyOtklikPackageEvent(
            pkg.id,
            payMethod: fromBalance ? 'balance' : 'link',
          ),
        );
  }

  void _buyTariff(SubscriptionTariff tariff, int months,
      {required bool fromBalance}) {
    setState(() => _busyId = tariff.id);
    context.read<BillingBloc>().add(
          BuySubscriptionEvent(
            tariffId: tariff.id,
            months: months,
            payMethod: fromBalance ? 'balance' : 'link',
          ),
        );
  }

  /// Balansdan to'lash — pul yechilishi uchun aniq tasdiq so'raladi.
  Future<bool> _confirmBalance(String title, int price) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Balansdan to\'lash'),
        content: Text(
          '$title — ${formatSom(price)} hisobingizdan yechiladi.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Bekor'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("To'lash",
                style: TextStyle(color: context.jb.green)),
          ),
        ],
      ),
    );
    return ok == true;
  }

  /// To'lov natijasi. ⚠ Oraliq ekran chizilmaydi — havola darhol TASHQI
  /// ilovada ochiladi, aks holda WebView ichida Payme ochilmaydi.
  Future<void> _onPurchase(PurchaseResult purchase) async {
    setState(() => _busyId = null);

    if (purchase.activated) {
      _snack('Kalitlar faollashtirildi', color: Colors.green.shade600);
      _load();
      return;
    }

    final url = purchase.launchUrl;
    if (url == null) {
      _snack(
        "To'lov tizimi sozlanmagan. Iltimos, operatorga murojaat qiling.",
        color: Colors.red.shade600,
      );
      return;
    }

    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    ).catchError((_) => false);

    if (!mounted) return;
    if (!launched) {
      _snack("To'lov ilovasini ochib bo'lmadi", color: Colors.red.shade600);
      return;
    }
    _showPendingSheet(purchase);
  }

  /// To'lovdan qaytgach kvota WEBHOOK orqali tushadi — ilova hech narsa
  /// yubormaydi, faqat ekranni qayta o'qiydi.
  void _showPendingSheet(PurchaseResult purchase) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.jb.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) {
        final p = ctx.jb;
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 18, 20, 18 + MediaQuery.of(ctx).padding.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  JBIconTile(
                    icon: Icons.schedule_rounded,
                    bg: p.amberBg,
                    fg: p.amber,
                    size: 40,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "${purchase.systemLabel} orqali to'lov kutilmoqda",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: p.ink),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "To'lov tasdiqlangach kalitlar avtomatik tushadi. Bu oyna yopilgach ro'yxatni yangilang.",
                style: TextStyle(fontSize: 13, color: p.gray, height: 1.45),
              ),
              if (purchase.payCode != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.chipBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("To'lov ID (ilovaga qo'lda kiritish uchun)",
                                style:
                                    TextStyle(fontSize: 11.5, color: p.gray)),
                            const SizedBox(height: 3),
                            Text(
                              purchase.payCode!,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                                color: p.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Nusxalash',
                        icon: Icon(Icons.copy_rounded, size: 18, color: p.blue),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: purchase.payCode!));
                          _snack('Nusxalandi');
                        },
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: JBPillButton(
                      label: "To'lovni tekshirish",
                      expand: true,
                      onTap: () {
                        Navigator.pop(ctx);
                        _load();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── UI ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: context.jb.overlay,
      child: Scaffold(
        backgroundColor: context.jb.bg,
        appBar: AppBar(
          backgroundColor: context.jb.card,
          surfaceTintColor: context.jb.card,
          foregroundColor: context.jb.ink,
          elevation: 0,
          scrolledUnderElevation: 0.5,
          title: const Text(
            'Kalit va tariflar',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<BillingBloc, BillingState>(
          listenWhen: (a, b) =>
              a.purchaseStatus != b.purchaseStatus || a.purchase != b.purchase,
          listener: (context, state) {
            if (state.purchaseStatus == FormzSubmissionStatus.failure) {
              setState(() => _busyId = null);
              _snack(
                state.error?.errorMessage ?? "Sotib olishda xato",
                color: Colors.red.shade600,
              );
              return;
            }
            if (state.purchaseStatus == FormzSubmissionStatus.success &&
                state.purchase != null) {
              _onPurchase(state.purchase!);
              context.read<BillingBloc>().add(const ResetPurchaseEvent());
            }
          },
          builder: (context, state) {
            final shop = state.otklik;
            final loading = state.otklikStatus.isInProgress && shop == null;
            if (loading) {
              return Center(
                  child: CircularProgressIndicator(color: context.jb.blue));
            }

            final current = state.tariffs?.current;
            final periods = state.tariffs?.periods ?? const <TariffPeriod>[];
            if (_months == null && periods.isNotEmpty) {
              _months = periods.first.months;
            }

            return RefreshIndicator(
              color: context.jb.blue,
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                children: [
                  _QuotaCard(summary: shop?.summary, current: current),
                  const SizedBox(height: 14),
                  JBSegmented(
                    tabs: const ['Paketlar', 'Obuna tariflari'],
                    index: _tab,
                    onChanged: (i) => setState(() => _tab = i),
                  ),
                  const SizedBox(height: 14),
                  if (_tab == 0)
                    ..._packagesTab(state, shop)
                  else
                    ..._tariffsTab(state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> _packagesTab(BillingState state, OtklikShopModel? shop) {
    final packages = shop?.packages ?? const <OtklikPackage>[];
    if (packages.isEmpty) {
      return [
        _EmptyBox(
          icon: Icons.inventory_2_outlined,
          text: state.otklikStatus == FormzSubmissionStatus.failure
              ? (state.error?.errorMessage ?? 'Paketlarni yuklab bo\'lmadi')
              : "Hozircha paket yo'q",
          onRetry: _load,
        ),
      ];
    }

    final balance = shop?.balance ?? 0;
    final fee = shop?.fallbackUnitFee ?? 0;

    return [
      if (fee > 0)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            // Kvota tugagach zaxira yo'l — shuning uchun paket har doim arzonroq.
            "Paketsiz bitta kontakt ${formatSom(fee)} turadi",
            style: TextStyle(fontSize: 12.5, color: context.jb.gray),
          ),
        ),
      ...packages.map(
        (pkg) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _PackageCard(
            pkg: pkg,
            balance: balance,
            busy: _busyId == pkg.id,
            onBuy: () => _buyPackage(pkg, fromBalance: false),
            onBuyFromBalance: () async {
              if (await _confirmBalance(pkg.name, pkg.price)) {
                _buyPackage(pkg, fromBalance: true);
              }
            },
          ),
        ),
      ),
    ];
  }

  List<Widget> _tariffsTab(BillingState state) {
    final data = state.tariffs;
    final tariffs = data?.tariffs ?? const <SubscriptionTariff>[];
    if (tariffs.isEmpty) {
      return [
        _EmptyBox(
          icon: Icons.workspace_premium_outlined,
          text: state.tariffsStatus == FormzSubmissionStatus.failure
              ? (state.error?.errorMessage ?? "Tariflarni yuklab bo'lmadi")
              : "Hozircha tarif yo'q",
          onRetry: _load,
        ),
      ];
    }

    final periods = data?.periods ?? const <TariffPeriod>[];
    final months = _months ?? (periods.isNotEmpty ? periods.first.months : 1);
    final balance = state.otklik?.balance ?? 0;

    return [
      if (periods.length > 1) ...[
        _PeriodPicker(
          periods: periods,
          selected: months,
          onChanged: (m) => setState(() => _months = m),
        ),
        const SizedBox(height: 14),
      ],
      ...tariffs.map(
        (t) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _TariffCard(
            tariff: t,
            months: months,
            balance: balance,
            busy: _busyId == t.id,
            isCurrent: data?.current?.tariffCode == t.code,
            onBuy: () => _buyTariff(t, months, fromBalance: false),
            onBuyFromBalance: () async {
              final price = t.priceFor(months).price;
              if (await _confirmBalance(t.name, price)) {
                _buyTariff(t, months, fromBalance: true);
              }
            },
          ),
        ),
      ),
    ];
  }
}

// ── Joriy kvota ──────────────────────────────────────────────────────────────

/// ⚠ Ikki xil muddat: `expires_at` — kvota hamyonining muddati,
/// `cycle_days_left` — obunaning joriy 30 kunlik oynasi. Qoldiq keyingi oyga
/// O'TMAYDI, shuning uchun ikkalasi ham aytiladi.
class _QuotaCard extends StatelessWidget {
  final OtklikSummary? summary;
  final CurrentSubscription? current;

  const _QuotaCard({this.summary, this.current});

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final s = summary ?? const OtklikSummary();
    final hasPlan = s.total > 0;

    return JBCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              JBIconTile(
                icon: Icons.confirmation_number_outlined,
                bg: p.blueTint,
                fg: p.blue,
                size: 42,
                iconSize: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Qolgan kalit',
                        style: TextStyle(fontSize: 12.5, color: p.gray)),
                    const SizedBox(height: 2),
                    Text(
                      hasPlan ? '${s.available} / ${s.total}' : '${s.available}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: s.available > 0 ? p.ink : p.red,
                      ),
                    ),
                  ],
                ),
              ),
              if (current?.hasSubscription == true && current?.tariffName != null)
                JBChip(
                  text: current!.tariffName!,
                  bg: p.blueTint,
                  fg: p.blue,
                  fontSize: 11.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
            ],
          ),
          if (hasPlan) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: LinearProgressIndicator(
                value: s.fraction.clamp(0.0, 1.0),
                minHeight: 7,
                backgroundColor: p.blueTint,
                valueColor: AlwaysStoppedAnimation(
                    s.available > 0 ? p.blue : p.red),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Text(
            _note(s, current),
            style: TextStyle(fontSize: 12.5, color: p.gray, height: 1.4),
          ),
        ],
      ),
    );
  }

  String _note(OtklikSummary s, CurrentSubscription? c) {
    if (s.available <= 0) {
      return 'Nomzod kontaktini ochish uchun paket yoki obuna tanlang.';
    }
    final left = c?.cycleDaysLeft;
    if (c?.hasSubscription == true && left != null) {
      return "Joriy davr yakunigacha $left kun. Ishlatilmagan kalit keyingi oyga o'tmaydi.";
    }
    final expires = _fmtDate(s.expiresAt);
    if (expires != null) return '$expires gacha amal qiladi';
    return 'Har bir ochilgan kontakt 1 kalit sarflaydi';
  }
}

// ── Paket kartasi ────────────────────────────────────────────────────────────

class _PackageCard extends StatelessWidget {
  final OtklikPackage pkg;
  final int balance;
  final bool busy;
  final VoidCallback onBuy;
  final VoidCallback onBuyFromBalance;

  const _PackageCard({
    required this.pkg,
    required this.balance,
    required this.busy,
    required this.onBuy,
    required this.onBuyFromBalance,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final canPayFromBalance = balance >= pkg.price && pkg.price > 0;

    return JBCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pkg.name,
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: p.ink),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pkg.qty} ta kalit · ${pkg.totalDays} kun',
                      style: TextStyle(fontSize: 12.5, color: p.gray),
                    ),
                  ],
                ),
              ),
              if (pkg.bonusDays > 0)
                JBChip(
                  text: '+${pkg.bonusDays} kun',
                  bg: p.greenBg,
                  fg: p.green,
                  fontSize: 11.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatSom(pkg.price),
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800, color: p.ink),
              ),
              const SizedBox(width: 8),
              if (pkg.pricePerUnit > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    '1 ta ≈ ${formatSom(pkg.pricePerUnit)}',
                    style: TextStyle(fontSize: 12, color: p.gray),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          // ⚠ Paket aynan nima berishini tugma ustida aytamiz.
          _QuotaWarning([
            '${pkg.qty} ta nomzod kontaktini ochasiz · ${pkg.totalDays} kun amal qiladi',
            "Ishlatilmagan kalit muddat tugagach kuyadi — keyingi oyga o'tmaydi.",
          ]),
          const SizedBox(height: 14),
          _BuyButtons(
            busy: busy,
            canPayFromBalance: canPayFromBalance,
            onBuy: onBuy,
            onBuyFromBalance: onBuyFromBalance,
          ),
        ],
      ),
    );
  }
}

// ── Obuna tarifi kartasi ─────────────────────────────────────────────────────

class _TariffCard extends StatelessWidget {
  final SubscriptionTariff tariff;
  final int months;
  final int balance;
  final bool busy;
  final bool isCurrent;
  final VoidCallback onBuy;
  final VoidCallback onBuyFromBalance;

  const _TariffCard({
    required this.tariff,
    required this.months,
    required this.balance,
    required this.busy,
    required this.isCurrent,
    required this.onBuy,
    required this.onBuyFromBalance,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    final price = tariff.priceFor(months);
    final saved = price.priceWithoutDiscount - price.price;

    return JBCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      border: tariff.isPopular ? p.blue : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  tariff.name,
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w800, color: p.ink),
                ),
              ),
              if (isCurrent)
                JBChip(
                  text: 'Joriy',
                  bg: p.greenBg,
                  fg: p.green,
                  fontSize: 11.5,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                )
              else if (tariff.isPopular)
                JBChip(
                  text: 'OMMABOP',
                  bg: p.blueTint,
                  fg: p.blue,
                  fontSize: 11,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                ),
            ],
          ),
          const SizedBox(height: 10),
          // ⚠ Obuna tarifining YAGONA limiti — kalit (otklik) kvotasi.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: p.blueTint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(Icons.confirmation_number_outlined,
                    size: 18, color: p.blue),
                const SizedBox(width: 10),
                Text(
                  '${tariff.otklikQuota} ta',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800, color: p.blue),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'kalit / ${tariff.cycleDays} kun',
                    style: TextStyle(fontSize: 12.5, color: p.blue),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatSom(price.price),
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.w800, color: p.ink),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  '/ ${price.months} oy',
                  style: TextStyle(fontSize: 12.5, color: p.gray),
                ),
              ),
            ],
          ),
          if (saved > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${formatSom(saved)} tejaysiz (−${price.discountPct}%)',
              style: TextStyle(
                  fontSize: 12, color: p.green, fontWeight: FontWeight.w600),
            ),
          ],
          if (price.bonusDays > 0) ...[
            const SizedBox(height: 4),
            Text(
              '+${price.bonusDays} bonus kun',
              style: TextStyle(fontSize: 12, color: p.green),
            ),
          ],
          if (tariff.features.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Matnlar serverdan (admin tahrirlaydi) — o'zgartirilmaydi.
            ...tariff.features.take(4).map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_rounded, size: 15, color: p.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            f,
                            style: TextStyle(
                                fontSize: 12.5, color: p.gray, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
          const SizedBox(height: 12),
          // ⚠ Obuna aynan nima berishini tugma ustida aytamiz: kvota, muddat
          // va qoldiqning keyingi oyga O'TMASLIGI.
          _QuotaWarning([
            'Har ${tariff.cycleDays} kunda ${tariff.otklikQuota} ta nomzod kontaktini ochasiz',
            if (price.months > 1)
              'Obuna ${tariff.cycleDays * price.months + price.bonusDays} kun '
                  '(${price.months} oy) amal qiladi · jami '
                  '${tariff.otklikQuota * price.months} ta kontakt'
            else
              'Obuna ${tariff.cycleDays + price.bonusDays} kun amal qiladi',
            "Ishlatilmagan kalit har davr oxirida kuyadi — keyingi oyga o'tmaydi.",
          ]),
          const SizedBox(height: 12),
          _BuyButtons(
            busy: busy,
            canPayFromBalance: balance >= price.price && price.price > 0,
            onBuy: onBuy,
            onBuyFromBalance: onBuyFromBalance,
            label: isCurrent ? 'Uzaytirish' : 'Tanlash',
          ),
        ],
      ),
    );
  }
}

/// ⚠ SOTIB OLISHDAN OLDINGI OGOHLANTIRISH — paket va obuna kartalarida
/// bir xil ko'rinadi: birinchi qator (nechta kontakt ochiladi) qalin, qolgani
/// muddat va "qoldiq kuyadi" izohi.
///
/// Matn public saytdagi jumlalar bilan bir xil
/// (public-site/src/utils/quotaNote.js) — ikkalasini birga yangilang.
class _QuotaWarning extends StatelessWidget {
  final List<String> lines;

  const _QuotaWarning(this.lines);

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: p.amberBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < lines.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (i == 0)
                    Icon(Icons.info_outline_rounded, size: 15, color: p.amber)
                  else
                    const SizedBox(width: 15),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      lines[i],
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: p.amber,
                        fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500,
                      ),
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

// ── Umumiy bo'laklar ─────────────────────────────────────────────────────────

class _BuyButtons extends StatelessWidget {
  final bool busy;
  final bool canPayFromBalance;
  final VoidCallback onBuy;
  final VoidCallback onBuyFromBalance;
  final String label;

  const _BuyButtons({
    required this.busy,
    required this.canPayFromBalance,
    required this.onBuy,
    required this.onBuyFromBalance,
    this.label = 'Sotib olish',
  });

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return SizedBox(
        height: 46,
        child: Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
                strokeWidth: 2.4, color: context.jb.blue),
          ),
        ),
      );
    }
    return Column(
      children: [
        JBPillButton(label: label, expand: true, onTap: onBuy),
        // Balansdan to'lash — faqat mablag' yetsa. Ish beruvchi balansni
        // to'ldira olmaydi (to'ldirish yopilgan), lekin eski qoldig'i bo'lishi
        // mumkin — o'sha behuda qolmasin.
        if (canPayFromBalance) ...[
          const SizedBox(height: 8),
          JBPillButton(
            label: 'Balansdan to\'lash',
            expand: true,
            variant: JBBtnVariant.outline,
            onTap: onBuyFromBalance,
          ),
        ],
      ],
    );
  }
}

class _PeriodPicker extends StatelessWidget {
  final List<TariffPeriod> periods;
  final int selected;
  final ValueChanged<int> onChanged;

  const _PeriodPicker({
    required this.periods,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.jb;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final period = periods[i];
          final active = period.months == selected;
          return GestureDetector(
            onTap: () => onChanged(period.months),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? p.blue : p.chipBg,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    period.name.isEmpty ? '${period.months} oy' : period.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: active ? p.onBrand : p.gray,
                    ),
                  ),
                  if (period.discountPct > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      '−${period.discountPct}%',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: active ? p.onBrand : p.green,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onRetry;

  const _EmptyBox({
    required this.icon,
    required this.text,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(icon, size: 56, color: context.jb.gray),
          const SizedBox(height: 14),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: context.jb.gray),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: onRetry,
            child: Text('Yangilash', style: TextStyle(color: context.jb.blue)),
          ),
        ],
      ),
    );
  }
}

/// ISO sanadan `dd.MM.yyyy`. ⚠ `toIso8601String()` bilan qayta yozmang —
/// UTC siljishi bir kunlik xatoga olib keladi.
String? _fmtDate(String? iso) {
  if (iso == null || iso.isEmpty) return null;
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return null;
  final d = parsed.isUtc ? parsed.toLocal() : parsed;
  return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
