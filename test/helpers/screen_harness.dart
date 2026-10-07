import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/l10n/l10n.dart';
import 'package:stylper/core/theme/app_theme.dart';

/// Figma frames are 390×844 with a 44px status bar and 34px home indicator.
const figmaFrameSize = Size(390, 844);
const figmaSafeArea = FakeViewPadding(top: 44, bottom: 34);

const _fonts = {
  'Inter': [
    'Inter-Regular',
    'Inter-Medium',
    'Inter-SemiBold',
    'Inter-Bold',
    'Inter-ExtraBold',
  ],
  'Poppins': [
    'Poppins-Regular',
    'Poppins-Medium',
    'Poppins-SemiBold',
    'Poppins-Bold',
  ],
  'PlayfairDisplay': ['PlayfairDisplay-BlackItalic'],
};

bool _fontsLoaded = false;

/// Loads the bundled fonts so goldens render real glyphs instead of boxes.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  for (final MapEntry(key: family, value: files) in _fonts.entries) {
    final loader = FontLoader(family);
    for (final file in files) {
      loader.addFont(rootBundle.load('assets/fonts/$file.ttf'));
    }
    await loader.load();
  }
  _fontsLoaded = true;
}

const screenKey = ValueKey('screen');

/// Pumps [screen] inside the app theme and localizations (at Figma frame size
/// unless [size] is given),
/// then waits for SVG and image assets to finish decoding.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  Locale locale = const Locale('en'),
  List<String> precacheImages = const [],
  Size size = figmaFrameSize,
  FakeViewPadding safeArea = figmaSafeArea,
  bool realShadows = false,
}) async {
  await loadAppFonts();
  // flutter_test draws shadows without blur by default; goldens should match
  // the real rendering. [expectScreenGolden] restores the default.
  if (realShadows) debugDisableShadows = false;
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..padding = safeArea
    ..viewPadding = safeArea;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      key: screenKey,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: screen,
      ),
    ),
  );
  await settleAssets(tester, precacheImages: precacheImages);
}

/// SVG and raster decoding happens off the fake clock, so let real time pass.
Future<void> settleAssets(
  WidgetTester tester, {
  List<String> precacheImages = const [],
}) async {
  await tester.runAsync(() async {
    final context = tester.element(find.byKey(screenKey));
    for (final asset in precacheImages) {
      await precacheImage(AssetImage(asset), context);
    }
    await Future<void>.delayed(const Duration(milliseconds: 300));
  });
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

/// Matches the pumped screen against `goldens/screens/<name>.png`.
Future<void> expectScreenGolden(String name) async {
  try {
    await expectLater(
      find.byKey(screenKey),
      matchesGoldenFile('screens/$name.png'),
    );
  } finally {
    // Must be restored before the test body ends (checked before tearDown).
    debugDisableShadows = true;
  }
}

/// Lets a cubit emission reach the widgets (one frame) and any implicit
/// animations it starts finish (subsequent frames).
Future<void> settleState(WidgetTester tester) async {
  await tester.pump();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Types into the [index]-th text field, then drops focus so no cursor or
/// focus border shows up in goldens.
Future<void> fillField(WidgetTester tester, int index, String text) async {
  await tester.enterText(find.byType(TextField).at(index), text);
  FocusManager.instance.primaryFocus?.unfocus();
  // First frame starts the focus-border animation, the second finishes it.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}
