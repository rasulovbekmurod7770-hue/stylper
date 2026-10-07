import 'dart:math' as math;
import 'dart:ui' as ui;

/// Builds a shader matching CSS `linear-gradient(<angle>deg, …)` over [rect].
///
/// Figma exports angled gradients in CSS terms (0° points up, 90° right) with
/// the gradient line sized to the box's corners. Flutter's `LinearGradient`
/// alignments only match that for square boxes, so wide text boxes and tags
/// need the CSS geometry computed explicitly.
ui.Shader cssLinearGradient({
  required double angleDegrees,
  required List<ui.Color> colors,
  required List<double> stops,
  required ui.Rect rect,
}) {
  final angle = angleDegrees * math.pi / 180;
  final direction = ui.Offset(math.sin(angle), -math.cos(angle));
  final length =
      (rect.width * math.sin(angle)).abs() +
      (rect.height * math.cos(angle)).abs();
  final half = direction * (length / 2);
  return ui.Gradient.linear(
    rect.center - half,
    rect.center + half,
    colors,
    stops,
  );
}
