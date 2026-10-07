import 'package:flutter/widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/css_gradient.dart';

/// Translucent pink pill naming a clothing item and its brand,
/// e.g. "**White T-Shirt** - Terra Pro".
class ProductTag extends StatelessWidget {
  const ProductTag({super.key, required this.name, required this.brand});

  final String name;
  final String brand;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _TagPainter(),
      child: SizedBox(
        height: 24.39,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9),
          child: Center(
            widthFactor: 1,
            child: Text.rich(
              TextSpan(
                style: AppTypography.productTag,
                children: [
                  TextSpan(
                    text: name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' - $brand'),
                ],
              ),
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _TagPainter extends CustomPainter {
  const _TagPainter();

  static const _borderWidth = 1.307;
  static const _radius = Radius.circular(11.761);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final fill = Paint()
      ..shader = cssLinearGradient(
        angleDegrees: 45.93,
        colors: const [Color(0x7DE05369), Color(0x7DAC1C38)], // ~49% alpha
        stops: const [0, 1],
        rect: rect,
      );
    canvas.drawRRect(RRect.fromRectAndRadius(rect, _radius), fill);

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = _borderWidth
      ..color = AppColors.tagBorder;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(_borderWidth / 2), _radius),
      border,
    );
  }

  @override
  bool shouldRepaint(_TagPainter oldDelegate) => false;
}
