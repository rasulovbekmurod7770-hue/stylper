import 'dart:io';

import 'package:flutter/widgets.dart';

/// A photo file on the device.
ImageProvider deviceFileImage(String path) => FileImage(File(path));
