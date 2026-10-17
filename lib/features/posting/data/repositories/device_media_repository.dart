import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/media.dart';
import '../../domain/repositories/media_repository.dart';

/// The real photo library (photo_manager) and camera (image_picker).
class DeviceMediaRepository implements MediaRepository {
  DeviceMediaRepository({ImagePicker? picker, SharedPreferencesAsync? prefs})
    : _picker = picker ?? ImagePicker(),
      _prefs = prefs ?? SharedPreferencesAsync();

  final ImagePicker _picker;
  final SharedPreferencesAsync _prefs;

  /// Set once the user has answered the photo access prompt.
  static const _askedKey = 'posting.photoAccessAsked';

  /// Photos only: on Android this asks for images, not videos.
  static const _request = PermissionRequestOption(
    androidPermission: AndroidPermission(
      type: RequestType.image,
      mediaLocation: false,
    ),
  );

  /// Uploads don't need more; a 12 MP original would only slow things down.
  static const _maxPhotoSide = 2048.0;

  @override
  Future<MediaAccess> requestAccess() async {
    // Ask once, as iOS does. Android would show its prompt again after a
    // "Don't allow", so afterwards only read the state: a denial is
    // changed in Settings, a partial selection with "Manage".
    // (iOS reports "not determined" again after a privacy reset; Android
    // never does, so this can't re-prompt there.)
    final asked = await _prefs.getBool(_askedKey) ?? false;
    var state = asked
        ? await PhotoManager.getPermissionState(requestOption: _request)
        : PermissionState.notDetermined;
    if (state == PermissionState.notDetermined) {
      state = await PhotoManager.requestPermissionExtend(
        requestOption: _request,
      );
      await _prefs.setBool(_askedKey, true);
    }
    return switch (state) {
      PermissionState.authorized => MediaAccess.full,
      PermissionState.limited => MediaAccess.limited,
      _ => MediaAccess.denied,
    };
  }

  @override
  Future<List<GalleryAlbum>> albums() async {
    final paths = await PhotoManager.getAssetPathList(type: RequestType.image);
    return [
      for (final path in paths)
        GalleryAlbum(id: path.id, name: path.name, handle: path),
    ];
  }

  @override
  Future<List<GalleryPhoto>> photos(
    GalleryAlbum album, {
    required int page,
    required int pageSize,
  }) async {
    final assets = await (album.handle as AssetPathEntity).getAssetListPaged(
      page: page,
      size: pageSize,
    );
    return [
      for (final asset in assets) GalleryPhoto(id: asset.id, handle: asset),
    ];
  }

  @override
  Future<String?> fileOf(GalleryPhoto photo) async =>
      // `file` is the compressed, displayable version (`originFile` can be
      // HEIC, which some Android versions can't show).
      (await (photo.handle as AssetEntity).file)?.path;

  @override
  Future<String?> takePhoto() async => (await _picker.pickImage(
    source: ImageSource.camera,
    maxWidth: _maxPhotoSide,
    maxHeight: _maxPhotoSide,
    imageQuality: 88,
    requestFullMetadata: false,
  ))?.path;

  @override
  Future<void> manageSelection() =>
      PhotoManager.presentLimited(type: RequestType.image);

  @override
  Future<void> openSettings() => PhotoManager.openSetting();
}
