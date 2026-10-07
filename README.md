# Stylper

*We help people find their style.* A community-driven fashion platform for
Uzbekistan and Central Asia: real people, real outfits, local brands.

Flutter app · clean architecture · BLoC/Cubit · go_router · get_it ·
localized in English, Russian and Uzbek.

## Running

```bash
flutter pub get
flutter run            # Android / iOS / web (Chrome)
```

There is no backend yet. The app runs against an in-memory **fake backend**
(`lib/core/fake_backend/fake_backend.dart`) with ~600 ms simulated latency.
Its data resets on every launch.

| Demo account | |
|---|---|
| Email | `developer@stylper.ai` |
| Password | `stylper123` |

The username `katty_miller` is already taken, so profile setup can show its
"username taken" error. Google and Apple sign-in show "not available yet"
until OAuth is configured.

## Architecture

```
lib/
  app/                  composition root: DI, router + redirects, session
  core/                 shared, feature-agnostic code
    theme/              color + typography tokens from Figma
    widgets/            shared UI (text field, buttons, glow…)
    validation/         input rules (email, password, username…)
    error/              Failure base type, ServerException + API error codes
    network/            AuthTokenStore
    fake_backend/       in-memory stand-in for the REST API
  features/
    auth/               welcome, sign in, sign up, forgot password
    onboarding/         profile setup, "Dress like you." style quiz
    home/               placeholder
  l10n/                 app_en.arb, app_ru.arb, app_uz.arb
```

Each feature has three layers, and dependencies only point inward:

- **domain/**: entities, repository interfaces, use cases. Pure Dart, no Flutter.
- **data/**: models (JSON), remote/local data sources, repository implementations.
  These map `ServerException` codes to domain failures.
- **presentation/**: cubits, pages, widgets. Failures become localized text here.

### User flow

`Welcome → Sign in / Sign up (→ Forgot password) → Profile setup → Style quiz → Home`

Routing is driven by `SessionCubit` (`lib/app/session`) and `redirectFor`
(`lib/app/router/app_router.dart`). Pages never navigate after sign-in. The
session changes and the router redirects:

- signed out → auth screens only
- signed in, onboarding not finished → profile setup / style quiz
- signed in and onboarded → home
- "Skip for now" on Welcome → guest home

### Connecting the real backend

Every remote call goes through `AuthRemoteDataSource` and
`OnboardingRemoteDataSource`. To switch to the API:

1. Implement both interfaces over HTTP. Throw `ServerException(statusCode, code)`
   using the codes in `ApiErrorCodes`, and `NetworkException` when offline.
2. Register them in `lib/app/di/injection.dart`, in the marked **Backend** block.
3. Replace `InMemoryAuthTokenStore` with secure storage.

Nothing in domain or presentation needs to change. `FakeBackend` documents the
endpoints and payloads the app currently expects.

## Design

Screens are implemented from the Figma file (page "Stylper Product"). Cached
design references live in `design/figma/`: screenshots, verbatim specs and
downloaded assets. Use them instead of re-fetching from Figma.

## Tests

```bash
flutter test                                   # everything
flutter test --exclude-tags golden             # logic + app flow only
flutter test --tags golden --update-goldens    # re-render screen goldens
python3 tool/compare_to_figma.py               # golden vs Figma diff sheets → build/figma_compare
```

- `test/app/app_flow_test.dart` drives the real app (DI, router, fake backend)
  through sign-up → onboarding → home, sign-in/out, and guest mode.
- `test/goldens/` renders each screen at the Figma frame size (390×844).
  Goldens depend on the platform's font rendering, so regenerate them on the
  machine that checks them.
