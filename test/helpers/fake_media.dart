import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:stylper/features/posting/domain/entities/media.dart';
import 'package:stylper/features/posting/domain/repositories/media_repository.dart';
import 'package:stylper/features/posting/presentation/gallery_thumbnails.dart';
import 'package:stylper/features/uploads/data/photo_encoder.dart';

/// A photo library of bundled images, standing in for the device's (the
/// photos' handles are their asset paths).
class FakeMediaRepository implements MediaRepository {
  FakeMediaRepository({
    this.access = MediaAccess.full,
    this.library = defaultLibrary,
    this.cameraPhoto,
    this.pickedPhoto,
    this.canTakePhoto = true,
  });

  static const defaultLibrary = [
    'assets/images/posts/john_knit.webp',
    'assets/images/posts/soft_neutrals.webp',
    'assets/images/wardrobe/sneakers.webp',
    'assets/images/posts/sofia.webp',
    'assets/images/posts/john_coat.webp',
    'assets/images/wardrobe/watches.webp',
    'assets/images/posts/leo.webp',
    'assets/images/wardrobe/sunglasses.webp',
    'assets/images/posts/mina.webp',
  ];

  /// The answer the user gives; tests change it to simulate Settings.
  MediaAccess access;
  final List<String> library;

  /// What the camera returns; null means the user cancelled.
  String? cameraPhoto;

  /// What the system photo picker returns; null means the user cancelled.
  String? pickedPhoto;

  @override
  final bool canTakePhoto;

  var accessChecks = 0;
  var manageCalls = 0;
  var settingsCalls = 0;

  static const album = GalleryAlbum(
    id: 'recents',
    name: 'Recents',
    handle: 'recents',
  );

  @override
  Future<MediaAccess> requestAccess() async {
    accessChecks++;
    return access;
  }

  @override
  Future<List<GalleryAlbum>> albums() async =>
      library.isEmpty ? const [] : const [album];

  @override
  Future<List<GalleryPhoto>> photos(
    GalleryAlbum album, {
    required int page,
    required int pageSize,
  }) async => [
    for (final path in library.skip(page * pageSize).take(pageSize))
      GalleryPhoto(id: path, handle: path),
  ];

  @override
  Future<String?> fileOf(GalleryPhoto photo) async => photo.handle as String;

  @override
  Future<String?> takePhoto() async => cameraPhoto;

  @override
  Future<String?> pickPhoto() async => pickedPhoto;

  @override
  Future<void> manageSelection() async => manageCalls++;

  @override
  Future<void> openSettings() async => settingsCalls++;
}

/// Thumbnails of [FakeMediaRepository] photos.
class AssetGalleryThumbnails implements GalleryThumbnails {
  const AssetGalleryThumbnails();

  @override
  ImageProvider thumbnail(GalleryPhoto photo) =>
      AssetImage(photo.handle as String);

  @override
  ImageProvider preview(GalleryPhoto photo) =>
      AssetImage(photo.handle as String);
}

/// Stands in for the device's image codecs: the test photos are WebP files
/// already, so both "compressed" files are the photo itself.
class FakePhotoEncoder implements PhotoEncoder {
  FakePhotoEncoder({this.fails = false, this.gate});

  /// Like a file that isn't an image.
  bool fails;

  /// When set, encoding waits for it, so a test can catch an upload midway.
  Completer<void>? gate;

  final encoded = <String>[];

  @override
  Future<PhotoForUpload> encode(String path) async {
    await gate?.future;
    if (fails) throw const PhotoEncodingException('not an image');
    encoded.add(path);
    final bytes = File(path).readAsBytesSync();
    return PhotoForUpload(
      full: bytes,
      thumb: bytes,
      width: 1080,
      height: 1350,
      blurhash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
    );
  }
}
