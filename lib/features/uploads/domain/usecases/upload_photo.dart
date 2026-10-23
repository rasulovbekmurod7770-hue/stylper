import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../entities/uploaded_photo.dart';
import '../failures/upload_failure.dart';
import '../repositories/upload_repository.dart';

final class PhotoUpload extends Equatable {
  const PhotoUpload(this.path, this.kind, {this.brandId});

  final String path;
  final UploadKind kind;
  final String? brandId;

  @override
  List<Object?> get props => [path, kind, brandId];
}

class UploadPhoto
    implements
        UseCase<Future<Either<UploadFailure, UploadedPhoto>>, PhotoUpload> {
  const UploadPhoto(this._uploads);

  final UploadRepository _uploads;

  @override
  Future<Either<UploadFailure, UploadedPhoto>> call(PhotoUpload upload) =>
      _uploads.uploadPhoto(upload.path, upload.kind, brandId: upload.brandId);
}
