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
  `features/onboarding`, `features/home` and `features/post` as the
  reference patterns.
- Posts are shared across features: `features/post` owns `Post`,
  `PostPreview`, `PostAuthor`, `PostGrid`. Likes and saves go through the
  app-wide `PostEngagementCubit`, and "save to wardrobe" through the app-wide
  `WardrobeMembershipCubit` — both optimistic, rolled back on failure, reset
  when the user changes — so every screen agrees; guests get the sign-in
  prompt (`runSignedIn`) instead.
- Detail screens (post, product, product looks, user profile) open **inside
  the current tab** with `context.openPost / openProduct / openUser`
  (`lib/core/router/tab_navigation.dart`), so each tab keeps its own back
  stack. Wardrobe lives in the Profile tab (`context.openWardrobe`).
- The bottom navigation is one widget, `AppTabBar`
  (`lib/app/shell/app_tab_bar.dart`), mounted once by `AppShell` under
  **every in-app screen** (the user's decision — including the post screen,
  which Figma draws without it). Screens never add their own; they keep
  `MediaQuery.paddingOf(context).bottom` free so content clears it.
  Full-screen flows that must hide it — **posting** (Figma `2849:1017`,
  started by the bar's "+") — are top-level routes next to the
  `StatefulShellRoute`, not inside it, so they cover the bar.
- **Posting** (`features/posting`, routes `/create`, `/create/tag`,
  `/create/details`, `/create/publish`) is one plain `ShellRoute` whose
  builder provides the single `PostDraftCubit` for all four steps and the
  `DiscardGuard` (back from step 1 asks before throwing a started post
  away). Signed-in users only. The device's photo library and camera go
  through `MediaRepository` (photo_manager / image_picker) and
  `GalleryThumbnails`; tests swap both through `configureDependencies`
  (`test/helpers/fake_media.dart`). Photo access is asked **once** (the
  user's requirement, iOS-style): a shared_preferences flag stops Android
  from re-prompting after a denial; afterwards it's Settings or "Manage".
  Tagged items come from the brands' catalogs via the backend search, never
  free text. There is **no audience setting** ("Share to followers" was
  removed on purpose): every post is public. After publishing,
  `PublishedPostsCubit` (app-wide) tells screens that list your posts to
  refresh.
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
  `2775:2389`, home `2775:2563`. Built from cached metadata only, styling
  marked PROVISIONAL until their design context or SVG exports are cached:
  outfit post "home-feed-2" `2775:2840` (variant `2775:2953` = tapped tag),
  product detail `2775:3077`, profile `2775:3285`, profile Saved tab
  "Profile 4" `2775:3374`, wardrobe `2789:226`; posting `2849:1017` (media
  `2820:76`, tag items `2845:396` + search-sheet variants, details
  `2820:198`, publish `2820:253`) from the section screenshot
  `design/figma/screens/08_posting_2849-1017.png` (per-step crops `08a`–`08d`).
  Not in Figma, built from the same pieces: product "See all looks",
  wardrobe category, settings sheet. Next in the flow: brand profile
  `2856:1809`, brand showroom `2856:1919`.
- Controls whose screens don't exist yet show "Coming soon" — never leave a
  tappable-looking control dead.
- Fonts (the user's decision): **Poppins everywhere**, through the shared
  scale in `AppTypography` (`display`, `headline`, `heading`, `subheading`,
  `bodyStrong`, `body`, `label`, `labelMuted`, `caption`, `captionStrong`,
  `captionMuted`, `meta`, `overline`, `micro`, `onPhoto*`) — use those, don't
  add per-screen styles; tweak with `copyWith` (colour, decoration) only.
  Exceptions: the sign-in / sign-up / forgot-password / profile-setup forms
  keep Inter (as their Figma frames), and the welcome / style-quiz screens
  keep a few exact Figma one-offs. Poppins has no Cyrillic, so it falls back
  to Inter for Russian. Figma's "Canela Trial" → Playfair Display Black
  Italic. Figma's "normal" Poppins line height is 1.5 × size rounded to
  whole pixels (11→17, 12→18, 13→20), set explicitly with
  `TextLeadingDistribution.even`.
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
