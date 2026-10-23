import 'package:flutter/widgets.dart';

import 'file_image_stub.dart' if (dart.library.io) 'file_image_io.dart';

/// Image for a content path: an `http(s)` URL from the API, a bundled
/// `assets/…` path (fake backend seed data), a file on the device (a
/// photo picked for a new post), or a `data:` URI (photos uploaded to the
/// fake backend).
ImageProvider imageFromPath(String path) {
  if (path.startsWith('http')) return NetworkImage(path);
  if (path.startsWith('assets/')) return AssetImage(path);
  if (path.startsWith('data:')) return _dataImage(path);
  return deviceFileImage(path);
}

/// The same provider for the same URI, so rebuilding doesn't decode the
/// image again ([MemoryImage]s are equal only for the same bytes object).
/// The most recently used last (map literals keep insertion order).
final _dataImages = <String, MemoryImage>{};

MemoryImage _dataImage(String uri) {
  final image =
      _dataImages.remove(uri) ??
      MemoryImage(UriData.parse(uri).contentAsBytes());
  _dataImages[uri] = image;
  if (_dataImages.length > 20) _dataImages.remove(_dataImages.keys.first);
  return image;
}
