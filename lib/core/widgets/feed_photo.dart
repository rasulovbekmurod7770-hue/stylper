import 'package:flutter/widgets.dart';

import '../presentation/image_source.dart';
import '../theme/app_colors.dart';

/// A rounded feed photo that fills its box, cropping like CSS `cover`.
class FeedPhoto extends StatelessWidget {
  const FeedPhoto({
    super.key,
    required this.path,
    required double this.radius,
    this.fallback,
  });

  /// Fully round, for avatars.
  const FeedPhoto.circle({super.key, required this.path, this.fallback})
    : radius = null;

  final String path;

  /// Shown when the photo can't be loaded; the neutral fill without one.
  final Widget? fallback;

  /// Corner radius; null clips to a circle.
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final image = Image(
      image: imageFromPath(path),
      fit: BoxFit.cover,
      // Neutral fill while decoding, instead of a blank hole.
      frameBuilder: (context, child, frame, _) =>
          frame == null ? const ColoredBox(color: AppColors.inputFill) : child,
      errorBuilder: (context, _, _) =>
          fallback ?? const ColoredBox(color: AppColors.inputFill),
    );
    final radius = this.radius;
    return radius == null
        ? ClipOval(child: image)
        : ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}
