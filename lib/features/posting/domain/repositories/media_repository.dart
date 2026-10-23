import '../entities/media.dart';

/// The device's photo library and camera.
abstract interface class MediaRepository {
  /// Asks for photo access the first time; afterwards returns the answer the
  /// user gave, without asking again.
  Future<MediaAccess> requestAccess();

  /// Albums, the one with every photo first.
  Future<List<GalleryAlbum>> albums();

  /// Photos in [album], newest first, a page at a time.
  Future<List<GalleryPhoto>> photos(
    GalleryAlbum album, {
    required int page,
    required int pageSize,
  });

  /// A file of [photo] the app can display and upload (never the raw HEIC).
  Future<String?> fileOf(GalleryPhoto photo);

  /// Opens the camera; the path of the photo taken, or null if cancelled.
  Future<String?> takePhoto();

  /// Whether [takePhoto] can open a camera (not on the web, where it would
  /// only open a file dialog).
  bool get canTakePhoto;

  /// The system's photo picker, for one photo (a profile photo): needs no
  /// photo access, and works on the web too. The path of the photo (a
  /// `blob:` URL on the web), or null if cancelled.
  Future<String?> pickPhoto();

  /// With limited access: lets the user change which photos the app sees.
  Future<void> manageSelection();

  /// Opens the app's system settings, to allow photo access.
  Future<void> openSettings();
}
