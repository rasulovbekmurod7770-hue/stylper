import 'package:fpdart/fpdart.dart';

import '../entities/uploaded_photo.dart';
import '../failures/upload_failure.dart';

abstract interface class UploadRepository {
  /// Prepares the photo at [path] (a file on the device, or a `blob:` URL on
  /// the web) and uploads it; signed-in users only. [brandId] is required for
  /// [UploadKind.product] and [UploadKind.brand] photos.
  Future<Either<UploadFailure, UploadedPhoto>> uploadPhoto(
    String path,
    UploadKind kind, {
    String? brandId,
  });
}
