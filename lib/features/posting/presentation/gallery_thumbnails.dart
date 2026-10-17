import 'package:flutter/widgets.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import '../domain/entities/media.dart';

/// Images of library photos. Behind an interface because thumbnails come
/// from the platform, which tests replace.
abstract interface class GalleryThumbnails {
  /// A small square image for the grid.
  ImageProvider thumbnail(GalleryPhoto photo);

  /// A larger image for the selected photo's preview.
  ImageProvider preview(GalleryPhoto photo);
}

class DeviceGalleryThumbnails implements GalleryThumbnails {
  const DeviceGalleryThumbnails();

  @override
  ImageProvider thumbnail(GalleryPhoto photo) => AssetEntityImageProvider(
    photo.handle as AssetEntity,
    isOriginal: false,
    thumbnailSize: const ThumbnailSize.square(300),
  );

  @override
  ImageProvider preview(GalleryPhoto photo) => AssetEntityImageProvider(
    photo.handle as AssetEntity,
    isOriginal: false,
    thumbnailSize: const ThumbnailSize(1080, 1080),
  );
}
