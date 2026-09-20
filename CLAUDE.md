# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`far_ish_bor` ("Far Ish Bor" / FARISHBOR) — a Flutter job-board mobile app with two user roles: **employer** and **job seeker**. Backend is a REST API at `https://api.jobup24.uz/api/v1/` plus a Socket.IO support chat.

## Toolchain & Commands

This project is pinned to a Flutter version via **FVM** (`.fvmrc` → Flutter `3.44.0`). Prefix Flutter/Dart commands with `fvm` to use the pinned SDK:

```bash
fvm flutter pub get                                            # install deps
./tool/run.ps1                                                 # telefonda ishga tushirish - DEV (sinov serveri)
./tool/run.ps1 prod                                            # PROD (real server)
./tool/run.ps1 local                                           # LOCAL (shu kompyuter, Wi-Fi orqali)
fvm flutter run --dart-define-from-file=env/dev.json            # skriptsiz, xuddi shu narsa
./tool/build.ps1 dev                                           # tarqatish uchun APK (sinovchilarga)
./tool/build.ps1 prod -Split                                   # PROD APK, ABI bo'yicha bo'lingan (kichikroq)
./tool/build.ps1 prod -Aab                                     # Play Store uchun .aab
fvm flutter analyze                                            # lint (flutter_lints, see analysis_options.yaml)
fvm flutter test                                               # run all tests
fvm flutter test test/widget_test.dart                         # run a single test file
fvm flutter test --plain-name "test name"                      # run a single test by name

# Code generation — REQUIRED after editing any *_model.dart with @JsonSerializable
fvm dart run build_runner build --delete-conflicting-outputs
```

**Uchta muhit — `client/env/*.json`** ([env/README.md](env/README.md)): `prod.json` (real server `api.jobup24.uz`), `dev.json` (sinov serveri `api-dev.jobup24.uz`), `local.json` (shu kompyuterdagi backend, git'da yo'q — [tool/run.ps1](tool/run.ps1) uni har safar joriy Wi-Fi IP bilan qayta yozadi). Qiymat kodga `--dart-define-from-file` orqali kiradi va [constants.dart](lib/core/constants/constants.dart) dagi `DOMAIN` ni to'ldiradi; **kodda manzil qotirilmaydi**. Yangi server manzili kerak bo'lsa faqat mos `env/*.json` tahrirlanadi.

Ikkita tuzoq: (a) lokal muhitda `localhost` YARAMAYDI — telefon uchun u telefonning o'zi, shuning uchun kompyuterning Wi-Fi IP si kerak va ikkalasi bir tarmoqda bo'lishi shart; (b) ochiq HTTP faqat **debug** build'da ruxsat etilgan ([android/app/src/debug/AndroidManifest.xml](android/app/src/debug/AndroidManifest.xml) → `usesCleartextTraffic`) — Android 9+ aks holda so'rovni jimgina bloklaydi, xato "server ishlamayapti" kabi ko'rinmaydi.

⚠ **DEV serveri prod bilan bir mashinada, lekin bazasi ham, kaliti ham alohida**
(`job_up_dev` — prod nusxasi). U yerda SMS, FCM push, Telegram bot va OnlinePBX
**ataylab o'chirilgan**, OTP kodi har doim **123456**, to'lov esa **avtomatik**
(tugma bosilsa darhol to'lanadi, pul kerak emas). Ya'ni dev'da "push kelmadi /
SMS kelmadi" — xato emas, shunday sozlangan. To'liq jadval: [env/README.md](env/README.md).

VS Code'da uchala muhit Run panelida tayyor turadi (workspace ildizidagi `.vscode/launch.json`); LOCAL tanlansa `preLaunchTask` IP ni avtomatik yangilaydi.

**APK/AAB yig'ish — [tool/build.ps1](tool/build.ps1)**. Tayyor fayl `build/out/` ga muhit va versiya ko'rsatilgan nom bilan tushadi (`jobup24-dev-1.0.0+1-20260917-1430.apk`) — Flutter'ning standart `app-release.apk` nomi bilan uch muhitning fayli aralashib ketadi. `-Install` ulangan telefonga darhol o'rnatadi, `-DebugBuild` esa debug APK yig'adi (`local` muhiti uchun YAGONA yo'l — release build'da ochiq HTTP bloklangan). VS Code: Terminal > Run Task.

⚠ **Release imzo kaliti** — [android/key.properties](android/key.properties.example) bo'lmasa release build **debug kalit** bilan imzolanadi (Flutter shablonining standart holati). Telefonga o'rnatiladi, lekin: Play Store qabul qilmaydi; har bir kompyuterning debug kaliti boshqacha, shuning uchun bir mashinada yig'ilgan APK boshqasinikining ustiga yangilanmaydi; keyinroq haqiqiy kalitga o'tilganda foydalanuvchi ilovani **o'chirib qayta o'rnatishga** majbur bo'ladi. Kalit bir marta yasaladi va YO'QOTILMAYDI — yo'qolsa Play Store'dagi ilova boshqa yangilanmaydi. `key.properties` va `.jks` git'da yo'q.

Localization (`lib/l10n/intl_*.arb`) is generated into `lib/generated/l10n` by `intl_utils` (configured under `flutter_intl:` in pubspec). It regenerates on build; if strings are stale, run `fvm flutter pub get`. Access strings via `S.of(context)`.

## Architecture

Feature-first clean-ish architecture. Each feature lives in `lib/features/<feature>/` with:

- `data/datasource/remote/` — `*RemoteDataSource` abstract + `Impl`, talks to `DioClient`
- `data/datasource/local/` — SharedPreferences-backed (only `auth` has one: `UserLocalDatasource`)
- `data/models/` — DTOs; many use `@JsonSerializable` with generated `*.g.dart`
- `domain/` — repository interface + impl (only `auth` has a domain layer; other features call the remote data source directly from the bloc)
- `presentation/logic/` — `*Bloc` + `part '*_event.dart'` + `part '*_state.dart'`
- `presentation/screens/`, `presentation/widgets/`

Features: `auth`, `main` (vacancies/candidates/applications — the largest), `billing`, `chat`, `notifications`.

Shared code lives in `lib/core/`: `network/` (DioClient + response wrapper), `error/`, `services/` (DI, connectivity, audio, file picker, local notifications), `constants/` (`constants.dart` for URLs/pref keys), `theme/` (`jb_palette.dart`, `app_theme.dart`, `jb_ui.dart`, `theme_cubit.dart`), `locale/`, `utils/` (reusable widgets like `custom_button`, `custom_textfield`, `search_field`).

### Dependency injection

A single `get_it` container in `lib/core/services/get_it.dart`. `setupDI()` is awaited in `main()` and registers **everything as lazy singletons** — including all Blocs/Cubits. Blocs are then injected at the app root in `main.dart` via `BlocProvider.value(value: getIt<XBloc>())`, so they are app-scoped singletons, not per-screen. When adding a feature, register its data source + bloc in `setupDI` and add the provider to `MyApp`.

### Networking & the response envelope

`DioClient` (`lib/core/network/dio_client.dart`) configures the base URL and an interceptor that injects the auth token (from `UserLocalDatasource.getToken()`) as both `Authorization: Bearer …` and a `token` header, plus `Accept-Language`. In debug builds an **Alice** interceptor logs traffic; a red bug FAB in `main.dart` opens the inspector (shake also works).

All API responses use a standard envelope `{ success, message, error_code, data }` modeled by `BaseData<T>` (`lib/core/error/base_model.dart`). Data sources call the `dio.wrapResponse<T>(request, fromJsonT)` extension (`lib/core/network/dio_response_extension.dart`), which:

- returns `Either<ErrorModel, T>` (dartz) — `Left` on failure, `Right` on success
- when `success` is true but `data` is null, returns `Right(true as T)` — so `bool`-returning endpoints just signal success
- maps `DioException`/parse errors to `ErrorModel(message, errorCode)`

Follow this pattern for new endpoints: define the method on the abstract data source returning `Future<Either<ErrorModel, T>>`, implement via `wrapResponse`.

### State management convention

Blocs use `flutter_bloc` + `equatable` + **formz**. A single state class holds one `FormzSubmissionStatus` field **per action** (e.g. `sendCodeStatus`, `loginStatus`) and is updated with `copyWith`. The common handler shape is:

```dart
emit(state.copyWith(xStatus: FormzSubmissionStatus.inProgress));
final result = await repository.x(...);
result.fold(
  (failure) => emit(state.copyWith(xStatus: FormzSubmissionStatus.failure, error: failure)),
  (data)    => emit(state.copyWith(xStatus: FormzSubmissionStatus.success, ...)),
);
emit(state.copyWith(xStatus: FormzSubmissionStatus.initial)); // reset so it can re-fire
```

The trailing reset-to-`initial` makes status changes behave like one-shot events for `BlocListener`. Persisting auth (token/role) happens in the bloc via `getIt<UserLocalDatasource>()` after a successful login/register.

## Conventions

- **Navigation:** plain `Navigator` (`MaterialPageRoute`). GoRouter is intentionally not used.
- **Theme:** light **and** dark ship (`ThemeCubit` → `PREF_THEME`, `light`/`dark`/`system`; toggle lives in Sozlamalar). Both `ThemeData`s are built from one source: the `JbPalette` token set in `lib/core/theme/jb_palette.dart`.
  - Read colors as **`context.jb.<token>`** (a `ThemeExtension`, so widgets rebuild on theme change). Where no `BuildContext` is in scope (model getters, top-level helpers), use the global mirror `jb.<token>`, which `ThemeCubit`/`MyApp` keep in sync.
  - Never hard-code a color literal or `Colors.white` for a surface. `Colors.white` is only for foregrounds on brand-colored backgrounds (or `context.jb.onBrand`).
  - Status/navigation bar: use `jb.overlay` (or `jb.overlayOnBrand` above a blue header) in `AnnotatedRegion<SystemUiOverlayStyle>`.
  - Because palette tokens are runtime values, colored widgets can't be `const` — that's expected.
- **Localization:** primary locales are Uzbek (`uz`) and Russian (`ru`). The persisted default is `uz` (`DEFAULT_LANG_KEY`). User-facing error strings are often hardcoded Uzbek in data sources.
- **Constants:** API base/domain, SharedPreferences keys, and language keys are centralized in `lib/core/constants/constants.dart`. Colors live **only** in `lib/core/theme/jb_palette.dart` (the old `core/constants/colors.dart` with `SCREAMING_CASE` consts is gone); add a semantic token there with both a light and a dark value instead of introducing a literal.
- **Models:** prefer `@JsonSerializable` + build_runner for new DTOs; regenerate `.g.dart` after edits.
- Roles are stored under `PREF_ROLE` and gate employer vs. seeker screens.

## Ish beruvchi oqimi (2026-09-17 redizayn)

### Pastki menyu — tab indekslari

`MainScreen` da ish beruvchi uchun **5 ta tab**:

`0` Bosh sahifa (`EmployerHomeScreen`) · `1` Vakansiyalar (`JobsScreen`) · `2` Nomzodlar · `3` Arizalar · `4` Profil

⚠ **"Suhbatlar" pastki menyudan olindi** (o'rin 5 ta). U endi bosh sahifadagi
"Suhbat" KPI kartasi, "Suhbatlar" tezkor amali va Profil menyusidan alohida
marshrut sifatida ochiladi — shuning uchun `EmployerInterviewsScreen` da
`showBack` parametri bor (tab bo'lib turganda orqaga tugmasi kerak emas edi).

Indekslarga tayangan joylar: `EmployerHomeScreen._goTab`,
`ProfileScreen._buildMenuSection`. Tab qo'shsangiz **ikkalasini ham** yangilang.

### Tablar dangasa quriladi

`MainScreen` `IndexedStack` ga faqat **ochilgan** tabni beradi (`_built` to'plami).
Ilgari beshta ekranning `initState` i ilova ochilishi bilan birdan so'rov
yuborardi (bir xil ro'yxat 2-3 marta). Bir marta ochilgan tab tirik qoladi —
skroll/filtr yo'qolmaydi. Yangi tab qo'shsangiz uning ma'lumotini **o'zi**
yuklashini tekshiring: endi u boshqa tab yuklab qo'yishiga tayana olmaydi.

### Bosh sahifadagi statistika

Serverda ish beruvchi uchun **dashboard endpointi YO'Q** — barcha sonlar mavjud
endpointlardan mijoz tomonda yig'iladi (`_EmployerStats` in
[employer_home_screen.dart](lib/features/main/presentation/screens/employer_home_screen.dart)):

| Ko'rsatkich | Manba |
|---|---|
| Faol/to'xtatilgan vakansiya, otklik varonkasi, "kerakli xodim" | `GET /mobile/employer/vacancies` → har bir yozuvdagi `applications` (`by_status`) va `anketa_count` |
| So'nggi otkliklar | `GET /mobile/employer/applications` |
| Suhbatlar | `GET /mobile/employer/interviews` (`cancelled`/`done` sanalmaydi) |
| Joriy tarif, muddati, qolgan kun | `GET /mobile/employer/contact-access` → `plan` |
| Kalit (otklik) kvotasi va kontakt narxi | `GET /mobile/employer/contact-access` |
| Ochilgan kontaktlar | `GET /mobile/employer/contact-unlock` |

### ⚠ "KALIT" — UI atamasi (kod/API'da hamon `otklik`)

Ish beruvchiga ko'rinadigan matnda kontakt ochish krediti **"kalit"** deyiladi:
"Kalit olish", "Kalit qoldig'i 60/60", "1 kalit sarflanadi". Sabab — "otklik"
so'zi ilovada IKKI xil narsani anglatardi: (a) nomzod yuborgan **ariza**
(`mobile_applications`, bepul) va (b) ish beruvchi sarflaydigan **kredit**
(`contact_unlocks`). Endi ariza — "otklik", kredit — "kalit".

**Qamrov:** faqat `client/` dagi MATN. API maydonlari (`otklik_available`,
`otklik_quota`, …), klass/funksiya nomlari (`OtklikShopScreen`,
`openOtklikShop`) va public sayt/CRM **o'zgarmagan** — shartnoma buzilmasin.
Yangi matn yozganda: kredit → "kalit", ariza → "otklik".

### ⚠ Ish beruvchiga BALANS KO'RSATILMAYDI

Bosh sahifadagi karta (`_PlanCard`) pul qoldig'ini emas, **sotib olingan
tarifni** ko'rsatadi: nom · amal qilish muddati · qolgan kun · kalit qoldig'i.
Manba — `contact-access` javobidagi `plan` bloki (`has_plan`, `kind`, `name`,
`expires_at`, `days_left`, `cycle_ends_at`). "Nomzodlar" sarlavhasidagi chip
ham pul emas, **qolgan kalit** sonini beradi.

⚠ `LoadBalanceEvent(true)` ish beruvchi ekranlarida **chaqirilmaydi** — yangi
joyga qo'shmang. Do'kondagi "Balansdan to'lash" tugmasi qoldi: u faqat ESKI
qoldiq narxni qoplasa chiqadi, aks holda o'sha pul behuda qolib ketardi.

Yangi son kerak bo'lsa **avval shu javoblarda bor-yo'qligini** tekshiring —
qo'shimcha so'rov qo'shishdan oldin. `by_status` bo'lmagan eski backendda
varonka qisqa yorliqlarga (`new/in_progress/hired/closed`) tushadi.

### ⚠ Kontakt ochish: kvota BALANSDAN OLDIN

Backend tartibi (`contactUnlock.service`): **1) bepul → 2) 30 kunlik otklik
kvotasi → 3) balansdan `contact_view` narxi**. `GET /contact-access` shuni
`next_charge` (`free|quota|balance`) + `otklik_available/total/used/expires_at`
bilan qaytaradi; `ContactAccessModel` ularni o'qiydi (`paysFromQuota`).

Shuning uchun `startUnlock` ([otklik_actions.dart](lib/features/main/presentation/widgets/otklik_actions.dart))
kvotasi bor ish beruvchida **balansni umuman tekshirmaydi** — aks holda otkligi
bor, hisobi bo'sh kompaniya to'lov ekraniga uloqtirilardi. Ochilgach javobdagi
`quota_charged`/`otklik_remaining` bilan qoldiq darhol yangilanadi.

### Kompaniya holati yorlig'i

"Tasdiqlangan" yozuvi **faqat** `employers.lifecycle_status == 'faol'` da
chiziladi — yagona manba `EmployerModel.isVerified` / `lifecycleLabel`
(bosh sahifa header'i va Profil header'i ikkalasi ham shundan oladi).
