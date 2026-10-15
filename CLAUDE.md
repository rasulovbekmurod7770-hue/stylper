# Stylper

*We help people find their style.* Read `README.md` for setup, the folder
layout and the backend contract; this file holds the product context and the
working rules that aren't obvious from the code.

## Product

A community-driven fashion platform for Uzbekistan and Central Asia: Pinterest
+ Instagram + fashion discovery, not just a shop and not just a social network.

- **Problem:** inspiration is scattered across Instagram pages and Telegram
  channels; clothes are shown only on professional models, so buyers can't
  picture them on their own body; small stores use misleading photos and
  overprice; trust in local online fashion is low.
- **Users** post outfit photos and tag the brand and the *exact item*; others
  browse a personalized feed, like, save, share, and find where to buy.
- **Brands** get an official showroom (products, store info, analytics) and
  can feature the best tagged user photos.
- **The loop:** real people → real style → real trust → real sales.
- **Core path through the app:** Home (discover styles) → Outfit (what people
  wear) → Product (the exact item) → See it on people (how it looks in real
  life, on different body types) → Profile (someone's personal style).
- **Business model:** brand subscriptions, sponsored placements,
  affiliate/commission, premium AI styling.
- **Later, not now:** AI body-type / height-weight / skin-tone / face-style
  analysis, outfit suggestions, smart wardrobe. Profile setup already
  collects gender, age, height and weight with this in mind.

When a design or feature choice is open, favour what serves these principles:
real people over models, every look leads to "what is it and where do I get
it", local brands first, and trust (nothing that misleads).

## Code rules

- Clean architecture per feature (`domain` / `data` / `presentation`),
  flutter_bloc Cubits, go_router, get_it, fpdart `Either`, equatable. Follow
  `features/onboarding` and `features/home` as the reference patterns.
- **No backend yet, and no Firebase.** The real API will be a custom REST
  backend (likely Node.js). Every remote call goes through a
  `*RemoteDataSource` interface; until the API exists, a `Fake…` data source
  calls `lib/core/fake_backend/fake_backend.dart`. A new endpoint gets a
  `FakeBackend` method documenting its route and JSON, and is registered in
  the **Backend** block of `lib/app/di/injection.dart`.
- Content image fields are asset paths now and URLs later; render them with
  `imageFromPath` (`lib/core/presentation/image_source.dart`).
- Every user-facing string goes into all three of `lib/l10n/app_{en,ru,uz}.arb`
  (Uzbek is Latin script, with `ʻ`), then `flutter gen-l10n`. Content from the
  backend (names, captions, tags) isn't localized.
- Main tabs are a `StatefulShellRoute` (`lib/app/router/app_router.dart`);
  `MainTab` order equals branch order. Guests may open any main tab
  (`AppRoutes.isMainRoute`); routing is driven by `SessionCubit` + `redirectFor`.
- Colors and text styles live in `lib/core/theme` (`AppColors`,
  `AppTypography`); add tokens there rather than repeating values.

## Design (Figma)

- File `Z6aHsxkD41lT8lZ8JiBsQv`, page "Stylper Product" (`1991:310`).
- **Figma MCP calls are scarce** (the user's seat allows only a few, sometimes
  about one a day). Before calling Figma, look up node IDs in
  `design/figma/metadata_1991-310.xml` and check `design/figma/specs/`
  (verbatim design context), `screens/` and `raw/`. Save every new fetch
  there. When many assets are needed, ask the user to export them instead.
- Implemented: welcome `2775:2369`, sign in `2775:2318`, sign up `2775:2441`,
  forgot password `2775:2408`, profile setup `2775:2501`, style quiz
  `2775:2389`, home `2775:2563`. Next in the flow: outfit post
  "home-feed-2" `2775:2840`, product detail `2775:3077`, profile `2775:3285`,
  brand profile `2856:1809`, brand showroom `2856:1919`.
- Fonts: Poppins on most screens (it has no Cyrillic, so styles fall back to
  Inter); Inter on the auth forms; Figma's unlicensed "Canela Trial" is
  replaced by Playfair Display Black Italic. Figma's "normal" Poppins line
  height is 1.5 × size rounded to whole pixels (11→17, 12→18, 13→20); set it
  explicitly with `TextLeadingDistribution.even`.
- Assets: photos are pre-cropped to their Figma frame at 3× and saved as WebP
  (Pillow) in `assets/images/<feature>/`, with originals in
  `design/figma/raw/<feature>/`. Icons are SVGs in `assets/icons/` with the
  web-only root attributes (`preserveAspectRatio`, `overflow`, `style`)
  removed. Paths go in `lib/core/constants/app_assets.dart`. A new asset
  folder needs a `pubspec.yaml` entry and a full app restart.
- Google / Apple sign-in use the official logos, not the Figma placeholders.

## Checks

```bash
flutter analyze
flutter test                                   # all, incl. goldens
flutter test --tags golden --update-goldens    # only after an intended visual change
python3 tool/compare_to_figma.py               # golden vs Figma screenshot
```

- Each designed screen has a `ScreenFixture` in
  `test/helpers/screen_fixtures.dart`: one golden at its Figma frame size,
  plus an overflow check in en/ru/uz at 390×844 and 360×640. Add one for
  every new screen, and its screenshot to `PAIRS` in the compare tool.
- `test/app/app_flow_test.dart` drives the real app through the main flows;
  keep it passing when UI moves.
- Look at a regenerated golden before accepting it.
