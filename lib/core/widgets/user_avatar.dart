import 'package:flutter/widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'feed_photo.dart';

/// A round profile photo, or the person's initials when they have none or
/// it can't be loaded.
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.name,
    required this.imagePath,
    required this.size,
  });

  final String name;
  final String? imagePath;
  final double size;

  /// Up to two initials, e.g. "John. B" → "JB".
  static String initials(String name) => name
      .split(RegExp(r'[\s._-]+'))
      .where((part) => part.isNotEmpty)
      .take(2)
      .map((part) => part.characters.first.toUpperCase())
      .join();

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final initials = DecoratedBox(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.brandGradient,
      ),
      child: Center(
        child: Text(
          UserAvatar.initials(name),
          style: AppTypography.bodyStrong.copyWith(
            fontSize: size * 0.36,
            height: 1,
            color: const Color(0xFFFFFFFF),
          ),
        ),
      ),
    );
    return SizedBox.square(
      dimension: size,
      child: path != null
          ? FeedPhoto.circle(path: path, fallback: initials)
          : initials,
    );
  }
}
