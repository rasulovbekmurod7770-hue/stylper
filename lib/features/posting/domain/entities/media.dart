import 'package:equatable/equatable.dart';

/// What the user let the app see of their photo library.
enum MediaAccess {
  /// Every photo — asked once, never again.
  full,

  /// Only the photos they picked (iOS 14+, Android 14+); they can change the
  /// selection later.
  limited,

  /// No access; they can allow it in Settings. Taking a photo still works.
  denied,
}

/// A photo album on the device ("Recents", "Camera", …).
class GalleryAlbum extends Equatable {
  const GalleryAlbum({
    required this.id,
    required this.name,
    required this.handle,
  });

  final String id;
  final String name;

  /// The platform's album object, opaque to the app.
  final Object handle;

  @override
  List<Object?> get props => [id, name];
}

/// A photo in the device's library.
class GalleryPhoto extends Equatable {
  const GalleryPhoto({required this.id, required this.handle});

  final String id;

  /// The platform's photo object (for thumbnails and the file), opaque to
  /// the app.
  final Object handle;

  @override
  List<Object?> get props => [id];
}
