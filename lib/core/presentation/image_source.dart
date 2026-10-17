import 'package:flutter/widgets.dart';

import 'file_image_stub.dart' if (dart.library.io) 'file_image_io.dart';

/// Image for a content path: an `http(s)` URL from the API, a bundled
/// `assets/…` path (fake backend seed data), or a file on the device (a
/// photo picked for a new post).
ImageProvider imageFromPath(String path) {
  if (path.startsWith('http')) return NetworkImage(path);
  if (path.startsWith('assets/')) return AssetImage(path);
  return deviceFileImage(path);
}
