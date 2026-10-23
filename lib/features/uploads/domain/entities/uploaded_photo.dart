import 'package:equatable/equatable.dart';

/// What a photo is uploaded for (`media.kind`): it decides where the photo
/// is stored and what it may be attached to.
enum UploadKind {
  post,
  avatar,
  wardrobe,

  /// A brand's product or brand photo: the uploader must be on its team.
  product,
  brand,
}

/// A photo stored on the backend and ready to attach to a post, a profile or
/// a product (a `media` row with status `ready`).
class UploadedPhoto extends Equatable {
  const UploadedPhoto({
    required this.id,
    required this.url,
    required this.thumbUrl,
  });

  /// The `media` id to attach.
  final String id;

  /// The photo with its longest side 1080 px, for detail views.
  final String url;

  /// The same photo at 400 px, for feeds, grids and avatars.
  final String thumbUrl;

  @override
  List<Object?> get props => [id, url, thumbUrl];
}

abstract final class UploadLimits {
  /// The largest file the backend accepts (each of the two WebPs).
  static const maxBytes = 2 * 1024 * 1024;
}
