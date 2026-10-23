import 'dart:typed_data';

/// A photo made ready for upload (STYLPER_BACKEND_SPEC.md §6): two WebP files
/// without metadata (EXIF can hold the GPS location) and a blurhash to show
/// while they load.
class PhotoForUpload {
  const PhotoForUpload({
    required this.full,
    required this.thumb,
    required this.width,
    required this.height,
    required this.blurhash,
  });

  /// Longest side 1080 px, quality 80.
  final Uint8List full;

  /// Longest side 400 px, quality 75.
  final Uint8List thumb;

  /// Of [full].
  final int width;
  final int height;
  final String blurhash;
}

/// Turns a picked photo into a [PhotoForUpload]. Tests replace it, since the
/// device one needs the platform's image codecs.
abstract interface class PhotoEncoder {
  /// [path] is a file on the device, or a `blob:` URL on the web. Throws
  /// [PhotoEncodingException] when it can't be read or written as WebP.
  Future<PhotoForUpload> encode(String path);
}

class PhotoEncodingException implements Exception {
  const PhotoEncodingException(this.cause);

  final Object cause;

  @override
  String toString() => 'PhotoEncodingException($cause)';
}

/// Whether [bytes] start with the WebP signature, `RIFF····WEBP`.
bool isWebp(Uint8List bytes) =>
    bytes.length >= 12 &&
    String.fromCharCodes(bytes, 0, 4) == 'RIFF' &&
    String.fromCharCodes(bytes, 8, 12) == 'WEBP';
