// Live tests of photo uploads: the create-upload / finalize-upload Edge
// Functions on the local stack, the files in the dev R2 bucket, and the
// profile photo. Needs the stack started after `supabase/functions/.env` was
// filled in, and IMG_PUBLIC_BASE in env/test.json. Run with the others (see
// auth_onboarding_live_test.dart). Each run leaves a few small files in the
// dev bucket.
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:stylper/core/config/backend_config.dart';
import 'package:stylper/core/error/exceptions.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/features/auth/data/repositories/supabase_auth_repository.dart';
import 'package:stylper/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:stylper/features/profile/data/datasources/supabase_profile_remote_data_source.dart';
import 'package:stylper/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:stylper/features/profile/domain/entities/profile_settings.dart';
import 'package:stylper/features/profile/domain/repositories/profile_repository.dart';
import 'package:stylper/features/uploads/data/datasources/supabase_upload_remote_data_source.dart';
import 'package:stylper/features/uploads/data/photo_encoder.dart';
import 'package:stylper/features/uploads/data/repositories/upload_repository_impl.dart';
import 'package:stylper/features/uploads/domain/entities/uploaded_photo.dart';
import 'package:stylper/features/uploads/domain/failures/upload_failure.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'live_support.dart';

/// WebP files from the app's assets, standing in for the device's codecs.
final _full = File('assets/images/posts/amin.webp').readAsBytesSync();
final _thumb = File('assets/images/wardrobe/sneakers.webp').readAsBytesSync();

class _AssetEncoder implements PhotoEncoder {
  @override
  Future<PhotoForUpload> encode(String path) async => PhotoForUpload(
    full: _full,
    thumb: _thumb,
    width: 729,
    height: 964,
    blurhash: 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
  );
}

void main() {
  late SupabaseClient client;
  late SupabaseAuthRepository auth;
  late SupabaseUploadRemoteDataSource remote;
  late UploadRepositoryImpl uploads;
  late ProfileRepositoryImpl profiles;

  setUp(() {
    expect(
      BackendConfig.imgPublicBase,
      isNotEmpty,
      reason: 'IMG_PUBLIC_BASE goes in env/test.json',
    );
    client = liveClient();
    auth = SupabaseAuthRepository(client);
    remote = SupabaseUploadRemoteDataSource(client);
    uploads = UploadRepositoryImpl(encoder: _AssetEncoder(), remote: remote);
    profiles = ProfileRepositoryImpl(
      remote: SupabaseProfileRemoteDataSource(
        client,
        FakeProfileRemoteDataSource(
          FakeBackend(latency: Duration.zero),
          InMemoryAuthTokenStore(),
        ),
      ),
    );
  });

  tearDown(() => client.dispose());

  /// A new account, signed in; its username is set with the first save.
  Future<({String id, String username})> signUpNew(String prefix) async {
    final account = newAccount(prefix);
    await signUpLive(client, auth, account.email);
    return (id: auth.currentUser!.id, username: account.username);
  }

  Future<UploadedPhoto> upload() async => (await uploads.uploadPhoto(
    'picked.jpg',
    UploadKind.avatar,
  )).getOrElse((f) => fail('upload failed: ${f.reason}'));

  Future<String?> codeOf(Future<Object?> call) async {
    try {
      await call;
      return null;
    } on ServerException catch (e) {
      return e.code;
    }
  }

  Future<void> setAvatar(String? mediaId, {required String username}) async =>
      (await profiles.updateProfile(
        ProfileEdit(
          name: '',
          username: username,
          bio: '',
          avatar: AvatarChange(mediaId),
        ),
      )).getOrElse((f) => fail('save failed: ${f.reason}'));

  test(
    'an avatar goes to R2 as two WebP files and becomes your photo',
    () async {
      final (id: userId, :username) = await signUpNew('up');
      final photo = await upload();

      final folder =
          '${BackendConfig.imgPublicBase}/avatar/$userId/${photo.id}';
      expect(photo.url, '${folder}_1080.webp');
      expect(photo.thumbUrl, '${folder}_400.webp');
      for (final (url, sent) in [
        (photo.url, _full),
        (photo.thumbUrl, _thumb),
      ]) {
        final served = await http.get(Uri.parse(url));
        expect(served.statusCode, 200, reason: url);
        expect(served.headers['content-type'], 'image/webp');
        expect(served.bodyBytes, sent);
      }
      final row = await client
          .from('media')
          .select('owner_id, kind, status, bytes, width, height, blurhash')
          .eq('id', photo.id)
          .single();
      expect(row, {
        'owner_id': userId,
        'kind': 'avatar',
        'status': 'ready',
        'bytes': _full.length,
        'width': 729,
        'height': 964,
        'blurhash': 'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
      });

      await setAvatar(photo.id, username: username);
      final me = (await profiles.getProfile(ProfileRepository.me))
          .getOrElse((f) => fail('no profile: ${f.reason}'));
      expect(me.avatarPath, photo.thumbUrl, reason: 'avatars use the thumb');

      await setAvatar(null, username: username);
      expect(
        (await profiles.getProfile(ProfileRepository.me))
            .toNullable()
            ?.avatarPath,
        isNull,
      );
    },
  );

  test('finalize waits for both files and rejects ones that are not '
      'WebP', () async {
    await signUpNew('up_bad');
    final body = {
      'kind': 'avatar',
      'width': 729,
      'height': 964,
      'bytes': _full.length,
    };

    final early = await remote.createUpload(body);
    final earlyId = early['media_id']! as String;
    expect(
      await codeOf(remote.finalizeUpload(earlyId)),
      ApiErrorCodes.uploadIncomplete,
    );
    await remote.putObject(early['full_put_url']! as String, _full);
    expect(
      await codeOf(remote.finalizeUpload(earlyId)),
      ApiErrorCodes.uploadIncomplete,
      reason: 'the thumb is still missing',
    );

    final fake = await remote.createUpload(body);
    final svg = File('assets/icons/plus.svg').readAsBytesSync();
    for (final url in ['full_put_url', 'thumb_put_url']) {
      await remote.putObject(fake[url]! as String, Uint8List.fromList(svg));
    }
    expect(
      await codeOf(remote.finalizeUpload(fake['media_id']! as String)),
      ApiErrorCodes.uploadRejected,
    );
    final row = await client
        .from('media')
        .select('status')
        .eq('id', fake['media_id']! as String)
        .single();
    expect(row['status'], 'rejected');
  });

  test('only a finished upload of your own can be your photo', () async {
    final otherPhoto = await (() async {
      await signUpNew('up_other');
      return upload();
    })();
    await auth.signOut();

    final (id: _, :username) = await signUpNew('up_me');
    final pending = await remote.createUpload({
      'kind': 'avatar',
      'width': 729,
      'height': 964,
      'bytes': _full.length,
    });
    for (final mediaId in [pending['media_id']! as String, otherPhoto.id]) {
      final saved = await profiles.updateProfile(
        ProfileEdit(
          name: '',
          username: username,
          bio: '',
          avatar: AvatarChange(mediaId),
        ),
      );
      expect(saved.isLeft(), isTrue, reason: mediaId);
    }
  });

  test('brand photos need the brand team; guests need to sign in', () async {
    await signUpNew('up_brand');
    expect(
      await codeOf(
        remote.createUpload({
          'kind': 'product',
          'brand_id': '00000000-0000-4000-8000-000000000000',
          'width': 729,
          'height': 964,
          'bytes': _full.length,
        }),
      ),
      ApiErrorCodes.forbidden,
    );
    await auth.signOut();
    expect(
      (await uploads.uploadPhoto(
        'picked.jpg',
        UploadKind.avatar,
      )).getLeft().toNullable(),
      const UploadFailure(UploadFailureReason.signInRequired),
    );
  });
}
