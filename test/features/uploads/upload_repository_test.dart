import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:stylper/core/error/exceptions.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/features/auth/data/datasources/fake_auth_remote_data_source.dart';
import 'package:stylper/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:stylper/features/uploads/data/datasources/upload_remote_data_source.dart';
import 'package:stylper/features/uploads/data/device_photo_encoder.dart';
import 'package:stylper/features/uploads/data/photo_encoder.dart';
import 'package:stylper/features/uploads/data/repositories/upload_repository_impl.dart';
import 'package:stylper/features/uploads/domain/entities/uploaded_photo.dart';
import 'package:stylper/features/uploads/domain/failures/upload_failure.dart';

import '../../helpers/fake_media.dart';

const _photo = 'assets/images/posts/amin.webp';

/// A remote that fails every create-upload with [error].
class _FailingRemote implements UploadRemoteDataSource {
  _FailingRemote(this.error);

  final Exception error;

  @override
  Future<Map<String, Object?>> createUpload(Map<String, Object?> body) =>
      Future.error(error);

  @override
  Future<void> putObject(String url, Uint8List bytes) async {}

  @override
  Future<Map<String, Object?>> finalizeUpload(String mediaId) async => {};
}

void main() {
  late FakeBackend backend;
  late InMemoryAuthTokenStore tokens;
  late FakePhotoEncoder encoder;
  late UploadRepositoryImpl uploads;

  setUp(() async {
    backend = FakeBackend(latency: Duration.zero);
    tokens = InMemoryAuthTokenStore();
    encoder = FakePhotoEncoder();
    uploads = UploadRepositoryImpl(
      encoder: encoder,
      remote: FakeUploadRemoteDataSource(backend, tokens),
    );
    await AuthRepositoryImpl(
      remote: FakeAuthRemoteDataSource(backend),
      tokenStore: tokens,
    ).signInWithEmail(
      email: FakeBackend.demoEmail,
      password: FakeBackend.demoPassword,
    );
  });

  group('UploadRepository', () {
    test('compresses, creates, uploads both files and finalizes', () async {
      final photo = (await uploads.uploadPhoto(
        _photo,
        UploadKind.avatar,
      )).getOrElse((f) => fail('upload failed: ${f.reason}'));
      expect(encoder.encoded, [_photo]);
      expect(photo.id, isNotEmpty);
      final webp = Uri.parse(photo.thumbUrl).data!;
      expect(webp.mimeType, 'image/webp');
      expect(webp.contentAsBytes(), File(_photo).readAsBytesSync());
    });

    test("a file that isn't a photo is unusable, before any request", () async {
      encoder.fails = true;
      expect(
        (await uploads.uploadPhoto(_photo, UploadKind.avatar)).getLeft(),
        const Some(UploadFailure(UploadFailureReason.unusablePhoto)),
      );
    });

    test('signed out, it asks to sign in', () async {
      await tokens.clear();
      expect(
        (await uploads.uploadPhoto(_photo, UploadKind.avatar)).getLeft(),
        const Some(UploadFailure(UploadFailureReason.signInRequired)),
      );
    });

    test('backend errors become reasons', () async {
      Future<UploadFailureReason?> failWith(Exception error) async =>
          (await UploadRepositoryImpl(
                encoder: encoder,
                remote: _FailingRemote(error),
              ).uploadPhoto(_photo, UploadKind.avatar))
              .getLeft()
              .toNullable()
              ?.reason;

      ServerException server(String code) =>
          ServerException(statusCode: 400, code: code);
      expect(
        await failWith(server(ApiErrorCodes.tooManyRequests)),
        UploadFailureReason.tooManyUploads,
      );
      expect(
        await failWith(server(ApiErrorCodes.fileTooLarge)),
        UploadFailureReason.unusablePhoto,
      );
      expect(
        await failWith(server(ApiErrorCodes.uploadRejected)),
        UploadFailureReason.unusablePhoto,
      );
      expect(
        await failWith(server(ApiErrorCodes.forbidden)),
        UploadFailureReason.unknown,
      );
      expect(
        await failWith(const NetworkException()),
        UploadFailureReason.network,
      );
    });
  });

  group('FakeBackend uploads', () {
    Future<String?> token() => tokens.read();
    const body = {'kind': 'avatar', 'width': 1080, 'height': 1350, 'bytes': 9};

    Future<String?> codeOf(Future<Object?> call) async {
      try {
        await call;
        return null;
      } on ServerException catch (e) {
        return e.code;
      }
    }

    test('finalizing before both files are there is incomplete', () async {
      final created = await backend.createUpload(await token(), body);
      final id = {'media_id': created['media_id']};
      expect(
        await codeOf(backend.finalizeUpload(await token(), id)),
        ApiErrorCodes.uploadIncomplete,
      );
      await backend.putObject(created['full_put_url']! as String, Uint8List(9));
      expect(
        await codeOf(backend.finalizeUpload(await token(), id)),
        ApiErrorCodes.uploadIncomplete,
      );
    });

    test("someone else's upload can't be finalized or worn", () async {
      final created = await backend.createUpload(await token(), body);
      for (final url in ['full_put_url', 'thumb_put_url']) {
        await backend.putObject(created[url]! as String, Uint8List(9));
      }
      final other = await backend.register(
        'other@stylper.test',
        FakeBackend.demoPassword,
      );
      final otherToken = other['accessToken']! as String;
      expect(
        await codeOf(
          backend.finalizeUpload(otherToken, {'media_id': created['media_id']}),
        ),
        ApiErrorCodes.notFound,
      );
      expect(
        await codeOf(
          backend.editProfile(otherToken, {
            'name': '',
            'username': 'other_one',
            'bio': '',
            'avatarMediaId': created['media_id'],
          }),
        ),
        ApiErrorCodes.unauthorized,
      );
    });

    test('a pending upload is not a profile photo yet', () async {
      final created = await backend.createUpload(await token(), body);
      expect(
        await codeOf(
          backend.editProfile((await token())!, {
            'name': 'John',
            'username': 'john',
            'bio': '',
            'avatarMediaId': created['media_id'],
          }),
        ),
        ApiErrorCodes.unauthorized,
      );
    });

    test('limits: 2 MB, known kinds, brand photos need a team', () async {
      expect(
        await codeOf(
          backend.createUpload(await token(), {...body, 'bytes': 3 << 20}),
        ),
        ApiErrorCodes.fileTooLarge,
      );
      expect(
        await codeOf(
          backend.createUpload(await token(), {...body, 'kind': 'video'}),
        ),
        ApiErrorCodes.validation,
      );
      expect(
        await codeOf(
          backend.createUpload(await token(), {...body, 'kind': 'product'}),
        ),
        ApiErrorCodes.forbidden,
      );
      expect(
        await codeOf(backend.createUpload(null, body)),
        ApiErrorCodes.unauthorized,
      );
    });
  });

  group('DevicePhotoEncoder', () {
    (int, int) fit(int w, int h, int longest) =>
        DevicePhotoEncoder.fitLongestSide(w, h, longest);

    test('the longest side becomes exactly 1080 / 400, either way round', () {
      expect(fit(960, 1280, 1080), (810, 1080));
      expect(fit(1280, 960, 1080), (1080, 810));
      expect(fit(4032, 3024, 400), (400, 300));
      expect(fit(1170, 2532, 1080), (499, 1080));
      expect(fit(1147, 1080, 1080), (1080, 1017));
    });

    test('never scales up', () {
      expect(fit(800, 600, 1080), (800, 600));
      expect(fit(1080, 1080, 1080), (1080, 1080));
    });

    test('isWebp checks the file signature', () {
      expect(isWebp(File(_photo).readAsBytesSync()), isTrue);
      expect(isWebp(File('assets/icons/plus.svg').readAsBytesSync()), isFalse);
      expect(isWebp(Uint8List(4)), isFalse);
    });
  });
}
