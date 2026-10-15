import 'package:flutter/widgets.dart';

/// Image for a content path: a bundled asset while data comes from the fake
/// backend, an `http(s)` URL once it comes from the API.
ImageProvider imageFromPath(String path) =>
    path.startsWith('http') ? NetworkImage(path) : AssetImage(path);
