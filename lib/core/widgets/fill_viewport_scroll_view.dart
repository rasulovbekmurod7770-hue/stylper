import 'package:flutter/widgets.dart';

/// Scroll view whose [child] is at least as tall as the viewport.
///
/// Lets a [Column] use `Spacer`s to spread content like the Figma frames,
/// while still scrolling when the keyboard or a small screen leaves less room.
class FillViewportScrollView extends StatelessWidget {
  const FillViewportScrollView({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
    );
  }
}
