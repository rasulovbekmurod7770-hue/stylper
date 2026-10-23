import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:blurhash_dart/blurhash_dart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image/image.dart' as img;

import 'photo_encoder.dart';

/// [PhotoEncoder] on the device's own codecs: the engine resizes (applying
/// the EXIF orientation), flutter_image_compress writes WebP (native on
/// Android and iOS, the canvas on the web) without metadata, and the engine's
/// decoder gives sizes and the blurhash.
class DevicePhotoEncoder implements PhotoEncoder {
  const DevicePhotoEncoder();

  static const fullSide = 1080;
  static const thumbSide = 400;

  @override
  Future<PhotoForUpload> encode(String path) async {
    try {
      final source = await XFile(path).readAsBytes();
      final (width, height) = await _sizeOf(source);
      final (fullWidth, fullHeight) = fitLongestSide(width, height, fullSide);
      final (thumbWidth, thumbHeight) = fitLongestSide(
        width,
        height,
        thumbSide,
      );
      final thumb = await _webp(source, thumbWidth, thumbHeight, quality: 75);
      return PhotoForUpload(
        full: await _webp(source, fullWidth, fullHeight, quality: 80),
        thumb: thumb,
        width: fullWidth,
        height: fullHeight,
        blurhash: await _blurhash(thumb),
      );
    } on PhotoEncodingException {
      rethrow;
    } catch (e) {
      // Not an image, a format the codecs can't read, or no WebP encoder.
      throw PhotoEncodingException(e);
    }
  }

  /// [width]×[height] scaled so its longest side is [longest], never up.
  @visibleForTesting
  static (int, int) fitLongestSide(int width, int height, int longest) {
    final long = math.max(width, height);
    if (long <= longest) return (width, height);
    int scaled(int side) => math.max(1, (side * longest / long).round());
    return width >= height
        ? (longest, scaled(height))
        : (scaled(width), longest);
  }

  /// [source] at exactly [width]×[height], as WebP. flutter_image_compress
  /// scales by the shorter side and truncates (a 1080 target comes out
  /// 1079), so the engine resizes and it only encodes: given the image's own
  /// size, it doesn't scale again.
  static Future<Uint8List> _webp(
    Uint8List source,
    int width,
    int height, {
    required int quality,
  }) async {
    final codec = await ui.instantiateImageCodec(
      source,
      targetWidth: width,
      targetHeight: height,
    );
    final Uint8List png;
    try {
      final image = (await codec.getNextFrame()).image;
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      png = data!.buffer.asUint8List();
    } finally {
      codec.dispose();
    }
    final bytes = await FlutterImageCompress.compressWithList(
      png,
      minWidth: width,
      minHeight: height,
      quality: quality,
      format: CompressFormat.webp,
      keepExif: false,
    );
    // A browser without a WebP encoder hands back a PNG instead.
    if (!isWebp(bytes)) {
      throw const PhotoEncodingException('no WebP encoder');
    }
    return bytes;
  }

  static Future<(int, int)> _sizeOf(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    try {
      final image = (await codec.getNextFrame()).image;
      final size = (image.width, image.height);
      image.dispose();
      return size;
    } finally {
      codec.dispose();
    }
  }

  /// From a 32 px wide copy: a blurhash keeps only the broad colours.
  static Future<String> _blurhash(Uint8List thumb) async {
    final codec = await ui.instantiateImageCodec(thumb, targetWidth: 32);
    try {
      final image = (await codec.getNextFrame()).image;
      final pixels = await image.toByteData();
      final rgba = img.Image.fromBytes(
        width: image.width,
        height: image.height,
        bytes: pixels!.buffer,
        numChannels: 4,
      );
      image.dispose();
      return BlurHash.encode(rgba).hash;
    } finally {
      codec.dispose();
    }
  }
}
