import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/uploaded_photo.dart';
import '../../domain/failures/upload_failure.dart';
import '../../domain/repositories/upload_repository.dart';
import '../datasources/upload_remote_data_source.dart';
import '../photo_encoder.dart';

/// Uploads as STYLPER_BACKEND_SPEC.md §6 describes: compress on the device,
/// create-upload, PUT both files to storage, finalize-upload.
class UploadRepositoryImpl implements UploadRepository {
  const UploadRepositoryImpl({required this._encoder, required this._remote});

  final PhotoEncoder _encoder;
  final UploadRemoteDataSource _remote;

  @override
  Future<Either<UploadFailure, UploadedPhoto>> uploadPhoto(
    String path,
    UploadKind kind, {
    String? brandId,
  }) async {
    final PhotoForUpload photo;
    try {
      photo = await _encoder.encode(path);
    } on PhotoEncodingException {
      return const Left(UploadFailure(UploadFailureReason.unusablePhoto));
    }
    if (photo.full.length > UploadLimits.maxBytes ||
        photo.thumb.length > UploadLimits.maxBytes) {
      return const Left(UploadFailure(UploadFailureReason.unusablePhoto));
    }

    try {
      final created = await _remote.createUpload({
        'kind': kind.name,
        'brand_id': ?brandId,
        'width': photo.width,
        'height': photo.height,
        'bytes': photo.full.length,
        'blurhash': photo.blurhash,
      });
      await Future.wait([
        _remote.putObject(created['full_put_url']! as String, photo.full),
        _remote.putObject(created['thumb_put_url']! as String, photo.thumb),
      ]);
      final done = await _remote.finalizeUpload(created['media_id']! as String);
      return Right(
        UploadedPhoto(
          id: done['media_id']! as String,
          url: done['full_url']! as String,
          thumbUrl: done['thumb_url']! as String,
        ),
      );
    } on ServerException catch (e) {
      return Left(
        UploadFailure(switch (e.code) {
          ApiErrorCodes.unauthorized => UploadFailureReason.signInRequired,
          ApiErrorCodes.tooManyRequests => UploadFailureReason.tooManyUploads,
          ApiErrorCodes.fileTooLarge ||
          ApiErrorCodes.uploadRejected => UploadFailureReason.unusablePhoto,
          _ => UploadFailureReason.unknown,
        }),
      );
    } on NetworkException {
      return const Left(UploadFailure(UploadFailureReason.network));
    }
  }
}
