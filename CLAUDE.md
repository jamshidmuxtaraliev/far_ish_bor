# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

`far_ish_bor` ("Far Ish Bor" / FARISHBOR) — a Flutter job-board mobile app with two user roles: **employer** and **job seeker**. Backend is a REST API at `https://api.jobup24.uz/api/v1/` plus a Socket.IO support chat.

## Toolchain & Commands

This project is pinned to a Flutter version via **FVM** (`.fvmrc` → Flutter `3.44.0`). Prefix Flutter/Dart commands with `fvm` to use the pinned SDK:

```bash
fvm flutter pub get                                            # install deps
fvm flutter run                                                # run on device/emulator
fvm flutter analyze                                            # lint (flutter_lints, see analysis_options.yaml)
fvm flutter test                                               # run all tests
fvm flutter test test/widget_test.dart                         # run a single test file
fvm flutter test --plain-name "test name"                      # run a single test by name

# Code generation — REQUIRED after editing any *_model.dart with @JsonSerializable
fvm dart run build_runner build --delete-conflicting-outputs
```

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

Shared code lives in `lib/core/`: `network/` (DioClient + response wrapper), `error/`, `services/` (DI, connectivity, audio, file picker, local notifications), `constants/` (`constants.dart` for URLs/pref keys, `colors.dart`), `theme/`, `locale/`, `utils/` (reusable widgets like `custom_button`, `custom_textfield`, `search_field`).

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
- **Theme:** light and dark themes exist (`ThemeCubit`), but the app currently ships **light-only**. Design reference screenshots may be dark/web — copy structure, not the dark theme.
- **Localization:** primary locales are Uzbek (`uz`) and Russian (`ru`). The persisted default is `uz` (`DEFAULT_LANG_KEY`). User-facing error strings are often hardcoded Uzbek in data sources.
- **Constants:** API base/domain, SharedPreferences keys, and language keys are centralized in `lib/core/constants/constants.dart`; colors in `lib/core/constants/colors.dart` (uppercase `snake_case` color consts).
- **Models:** prefer `@JsonSerializable` + build_runner for new DTOs; regenerate `.g.dart` after edits.
- Roles are stored under `PREF_ROLE` and gate employer vs. seeker screens.
