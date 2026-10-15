import 'package:flutter/widgets.dart';

import '../../../../core/presentation/image_source.dart';
import '../../../../core/theme/app_colors.dart';

/// A rounded feed photo that fills its box, cropping like CSS `cover`.
class FeedPhoto extends StatelessWidget {
  const FeedPhoto({super.key, required this.path, required double this.radius});

  /// Fully round, for avatars.
  const FeedPhoto.circle({super.key, required this.path}) : radius = null;

  final String path;

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
    );
    final radius = this.radius;
    return radius == null
        ? ClipOval(child: image)
        : ClipRRect(borderRadius: BorderRadius.circular(radius), child: image);
  }
}
