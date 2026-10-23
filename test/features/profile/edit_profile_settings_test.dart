import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/core/usecase/usecase.dart';
import 'package:stylper/core/validation/validators.dart';
import 'package:stylper/features/auth/data/datasources/fake_auth_remote_data_source.dart';
import 'package:stylper/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:stylper/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:stylper/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:stylper/features/profile/domain/entities/profile_settings.dart';
import 'package:stylper/features/profile/domain/failures/profile_failure.dart';
import 'package:stylper/features/profile/domain/repositories/profile_repository.dart';
import 'package:stylper/features/profile/domain/usecases/profile_usecases.dart';
import 'package:stylper/features/profile/presentation/cubits/edit_profile_cubit.dart';
import 'package:stylper/features/profile/presentation/cubits/settings_cubit.dart';
import 'package:stylper/features/uploads/data/datasources/upload_remote_data_source.dart';
import 'package:stylper/features/uploads/data/repositories/upload_repository_impl.dart';
import 'package:stylper/features/uploads/domain/failures/upload_failure.dart';
import 'package:stylper/features/uploads/domain/usecases/upload_photo.dart';

import '../../helpers/fake_media.dart';

class _MockGetSettings extends Mock implements GetSettings {}

class _MockUpdateSettings extends Mock implements UpdateSettings {}

/// Edit Profile and Settings, through the real use cases and repository on
/// the fake backend, signed in as John.
void main() {
  late FakeBackend backend;
  late InMemoryAuthTokenStore tokens;
  late AuthRepositoryImpl auth;
  late ProfileRepositoryImpl profiles;

  setUp(() async {
    backend = FakeBackend(latency: Duration.zero);
    tokens = InMemoryAuthTokenStore();
    auth = AuthRepositoryImpl(
      remote: FakeAuthRemoteDataSource(backend),
      tokenStore: tokens,
    );
    profiles = ProfileRepositoryImpl(
      remote: FakeProfileRemoteDataSource(backend, tokens),
    );
    await auth.signInWithEmail(
      email: FakeBackend.demoEmail,
      password: FakeBackend.demoPassword,
    );
  });

  Future<ProfileFailureReason?> save(String username) async =>
      (await UpdateProfile(profiles, auth)(
        ProfileEdit(name: 'John', username: username, bio: ''),
      )).getLeft().toNullable()?.reason;

  test(
    'Edit Profile saves name, username and bio; the session follows',
    () async {
      final result = await UpdateProfile(profiles, auth)(
        const ProfileEdit(
          name: 'John Brown',
          username: 'john_b',
          bio: 'Layers, always.',
        ),
      );
      expect(result.isRight(), isTrue);
      final me = (await profiles.getProfile(ProfileRepository.me))
          .getOrElse((_) => fail('no profile'));
      expect(
        (me.name, me.handle, me.bio),
        ('John Brown', 'john_b', 'Layers, always.'),
      );
      expect(auth.currentUser!.username, 'john_b');
    },
  );

  test(
    'usernames of people and brands, and reserved ones, are taken',
    () async {
      for (final taken in ['katty_miller', 'cos', 'zara', 'stylper', 'admin']) {
        expect(
          await save(taken),
          ProfileFailureReason.usernameTaken,
          reason: taken,
        );
      }
      expect(await save('john'), isNull, reason: 'your own stays yours');
    },
  );

  test('an empty name falls back to the username', () async {
    await UpdateProfile(profiles, auth)(
      const ProfileEdit(name: '', username: 'john', bio: ''),
    );
    final me = (await profiles.getProfile(ProfileRepository.me))
        .getOrElse((_) => fail('no profile'));
    expect(me.name, 'john');
  });

  test('settings start as a new account\'s and keep changes', () async {
    expect(
      (await profiles.getSettings()).getOrElse((_) => fail('no settings')),
      const ProfileSettings(),
    );
    const changed = ProfileSettings(isPrivate: true, notifyDrops: true);
    expect((await profiles.updateSettings(changed)).isRight(), isTrue);
    expect(
      (await profiles.getSettings()).getOrElse((_) => fail('no settings')),
      changed,
    );
  });

  group('EditProfileCubit', () {
    /// A photo the picker and the camera return.
    const photo = 'assets/images/posts/amin.webp';

    EditProfileCubit cubit({
      FakeMediaRepository? media,
      FakePhotoEncoder? encoder,
    }) => EditProfileCubit(
      GetProfile(profiles),
      UpdateProfile(profiles, auth),
      media ?? FakeMediaRepository(pickedPhoto: photo, cameraPhoto: photo),
      UploadPhoto(
        UploadRepositoryImpl(
          encoder: encoder ?? FakePhotoEncoder(),
          remote: FakeUploadRemoteDataSource(backend, tokens),
        ),
      ),
    );

    Future<String?> savedAvatar() async =>
        (await profiles.getProfile(ProfileRepository.me))
            .getOrElse((_) => fail('no profile'))
            .avatarPath;

    test('a picked photo uploads at once; Save makes it the profile '
        'photo', () async {
      final edit = cubit();
      await edit.load();
      expect(edit.state.photoPath, isNull, reason: 'John has no photo yet');
      await edit.choosePhoto();
      expect(edit.state.photo, isA<PhotoUploaded>());
      expect(edit.state.photoPath, photo, reason: 'shown from the device');
      expect(await savedAvatar(), isNull, reason: 'not saved yet');

      await edit.save(name: 'John', username: 'john', bio: '');
      expect(edit.state.status, EditProfileStatus.saved);
      expect(await savedAvatar(), startsWith('data:image/webp;base64,'));
    });

    test('Save waits for a photo still uploading', () async {
      final gate = Completer<void>();
      final edit = cubit(encoder: FakePhotoEncoder(gate: gate));
      await edit.load();
      unawaited(edit.choosePhoto(camera: true));
      await pumpEventQueue();
      expect(edit.state.uploadingPhoto, isTrue);

      final saving = edit.save(name: 'John', username: 'john', bio: '');
      await pumpEventQueue();
      expect(edit.state.status, EditProfileStatus.saving);
      gate.complete();
      await saving;
      expect(edit.state.status, EditProfileStatus.saved);
      expect(await savedAvatar(), startsWith('data:image/webp'));
    });

    test("a photo that can't be used says so and keeps the old one", () async {
      final edit = cubit(encoder: FakePhotoEncoder(fails: true));
      await edit.load();
      final before = edit.state.photoPath;
      await edit.choosePhoto();
      expect(
        edit.state.photoFailure,
        const UploadFailure(UploadFailureReason.unusablePhoto),
      );
      expect(edit.state.photo, isNull);
      expect(edit.state.photoPath, before);
    });

    test('a failed upload during Save stops it, keeping the form', () async {
      final gate = Completer<void>();
      final encoder = FakePhotoEncoder(gate: gate, fails: true);
      final edit = cubit(encoder: encoder);
      await edit.load();
      unawaited(edit.choosePhoto());
      await pumpEventQueue();
      final saving = edit.save(name: 'John', username: 'john', bio: '');
      gate.complete();
      await saving;
      expect(edit.state.status, EditProfileStatus.ready);
      expect(edit.state.photoPath, isNull);
      expect(await savedAvatar(), isNull);
    });

    test('Remove photo saves the profile without one', () async {
      final first = cubit();
      await first.load();
      await first.choosePhoto();
      await first.save(name: 'John', username: 'john', bio: '');

      final edit = cubit();
      await edit.load();
      expect(edit.state.photoPath, startsWith('data:image/webp'));
      edit.removePhoto();
      expect(edit.state.photoPath, isNull);
      await edit.save(name: 'John', username: 'john', bio: '');
      expect(await savedAvatar(), isNull);
    });

    test('cancelling the picker changes nothing', () async {
      final media = FakeMediaRepository();
      final edit = cubit(media: media);
      await edit.load();
      final before = edit.state;
      await edit.choosePhoto();
      await edit.choosePhoto(camera: true);
      expect(edit.state, before);
    });

    blocTest<EditProfileCubit, EditProfileState>(
      'starts from the profile, refuses an empty username, and shows a '
      'taken one inline',
      build: cubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.save(name: 'John', username: '', bio: '');
        await cubit.save(name: 'John', username: '@COS', bio: '');
      },
      verify: (cubit) {
        expect(cubit.state.status, EditProfileStatus.ready);
        expect(cubit.state.profile?.handle, 'john');
        expect(cubit.state.usernameTaken, isTrue);
      },
    );

    blocTest<EditProfileCubit, EditProfileState>(
      'an empty username is a field error, not a request',
      build: cubit,
      act: (cubit) async {
        await cubit.load();
        await cubit.save(name: 'John', username: ' ', bio: '');
      },
      verify: (cubit) =>
          expect(cubit.state.usernameError, ValidationError.required),
    );
  });

  group('SettingsCubit', () {
    late _MockGetSettings getSettings;
    late _MockUpdateSettings updateSettings;

    setUp(() {
      getSettings = _MockGetSettings();
      updateSettings = _MockUpdateSettings();
      when(() => getSettings(const NoParams()))
          .thenAnswer((_) async => const Right(ProfileSettings()));
      registerFallbackValue(const ProfileSettings());
    });

    blocTest<SettingsCubit, SettingsState>(
      'a change shows at once',
      setUp: () =>
          when(() => updateSettings(any()))
              .thenAnswer((_) async => const Right(unit)),
      build: () => SettingsCubit(getSettings, updateSettings),
      act: (cubit) async {
        await cubit.load();
        await cubit.change((s) => s.copyWith(isPrivate: true));
      },
      skip: 2,
      expect: () => [
        const SettingsState(
          status: SettingsStatus.ready,
          settings: ProfileSettings(isPrivate: true),
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'a change that can\'t be saved is undone, with a note',
      setUp: () => when(() => updateSettings(any())).thenAnswer(
        (_) async => const Left(ProfileFailure(ProfileFailureReason.network)),
      ),
      build: () => SettingsCubit(getSettings, updateSettings),
      act: (cubit) async {
        await cubit.load();
        await cubit.change((s) => s.copyWith(isPrivate: true));
      },
      skip: 3,
      expect: () => [
        const SettingsState(status: SettingsStatus.ready, saveFailed: true),
      ],
    );
  });
}
