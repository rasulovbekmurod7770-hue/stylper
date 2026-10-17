import 'package:flutter/widgets.dart';

/// On the web, picked photos come back as `blob:` URLs, which load like
/// network images.
ImageProvider deviceFileImage(String path) => NetworkImage(path);
