import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/app/shell/app_tab_bar.dart';

import '../helpers/screen_harness.dart';

void main() {
  testWidgets('tabs report taps; "+" starts a post; the current tab is '
      'selected', (tester) async {
    final tapped = <MainTab>[];
    var creates = 0;
    await pumpScreen(
      tester,
      AppTabBar(
        currentTab: MainTab.home,
        onTabSelected: tapped.add,
        onCreate: () => creates++,
      ),
    );

    await tester.tap(find.bySemanticsLabel('Search'));
    await tester.tap(find.bySemanticsLabel('Profile'));
    await tester.tap(find.bySemanticsLabel('New post'));
    expect(tapped, [MainTab.search, MainTab.profile]);
    expect(creates, 1);

    expect(
      tester.getSemantics(find.bySemanticsLabel('Home')),
      isSemantics(label: 'Home', isButton: true, isSelected: true),
    );
  });
}
