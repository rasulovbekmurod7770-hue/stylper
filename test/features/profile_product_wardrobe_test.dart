import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/features/post/data/models/post_json.dart';
import 'package:stylper/features/post/domain/entities/post.dart';
import 'package:stylper/features/product/data/datasources/product_remote_data_source.dart';
import 'package:stylper/features/product/data/repositories/product_repository_impl.dart';
import 'package:stylper/features/product/domain/failures/product_failure.dart';
import 'package:stylper/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:stylper/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:stylper/features/profile/domain/entities/user_profile.dart';
import 'package:stylper/features/profile/domain/failures/profile_failure.dart';
import 'package:stylper/features/profile/domain/repositories/profile_repository.dart';
import 'package:stylper/features/profile/domain/usecases/profile_usecases.dart';
import 'package:stylper/features/profile/presentation/cubits/following_cubit.dart';
import 'package:stylper/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:stylper/features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'package:stylper/features/wardrobe/domain/failures/wardrobe_failure.dart';
import 'package:stylper/features/wardrobe/domain/usecases/wardrobe_usecases.dart';
import 'package:stylper/features/wardrobe/presentation/cubits/wardrobe_membership_cubit.dart';

class _MockSetFollowing extends Mock implements SetFollowing {}

class _MockSetInWardrobe extends Mock implements SetInWardrobe {}

void main() {
  late FakeBackend backend;
  late InMemoryAuthTokenStore tokens;
  late ProductRepositoryImpl products;
  late ProfileRepositoryImpl profiles;
  late WardrobeRepositoryImpl wardrobe;

  setUp(() {
    backend = FakeBackend(latency: Duration.zero);
    tokens = InMemoryAuthTokenStore();
    products = ProductRepositoryImpl(
      remote: FakeProductRemoteDataSource(backend, tokens),
    );
    profiles = ProfileRepositoryImpl(
      remote: FakeProfileRemoteDataSource(backend, tokens),
    );
    wardrobe = WardrobeRepositoryImpl(
      remote: FakeWardrobeRemoteDataSource(backend, tokens),
    );
  });

  Future<void> signIn() async {
    final session = await backend.login(
      FakeBackend.demoEmail,
      FakeBackend.demoPassword,
    );
    await tokens.save(session['accessToken']! as String);
  }

  T right<T>(Either<Object, T> result) =>
      result.getOrElse((failure) => throw StateError('$failure'));

  group('products', () {
    test(
      'a product brings its looks, styles, store and similar items',
      () async {
        final detail = right(await products.getProduct('p_cardigan_cos'));

        expect(detail.product.brand, 'COS');
        expect(detail.store?.url, Uri.parse('https://www.cos.com'));
        expect(
          detail.looks.map((look) => look.id),
          containsAll(['post_utility_chic', 'post_no_words', 'post_amin']),
        );
        expect(detail.styles.map((style) => style.name), [
          'streetwear',
          'minimal',
        ]);
        expect(detail.looksIn('minimal').map((look) => look.id), [
          'post_john_coat',
          'post_amin',
        ]);
        expect(
          detail.similar.map((p) => p.id),
          isNot(contains('p_cardigan_cos')),
        );
        expect(detail.inWardrobe, isFalse, reason: 'guest');
      },
    );

    test('brands without a known store have none', () async {
      expect(right(await products.getProduct('p_jeans_kink')).store, isNull);
    });

    test('an unknown product is not found', () async {
      expect(
        (await products.getProduct('nope')).getLeft().toNullable(),
        const ProductFailure(ProductFailureReason.notFound),
      );
    });

    test('wardrobe membership is per user', () async {
      await signIn();
      expect(
        right(await products.getProduct('p_cardigan_cos')).inWardrobe,
        isTrue,
      );
      expect(
        right(await products.getProduct('p_tee_zara')).inWardrobe,
        isFalse,
      );
    });
  });

  group('profiles', () {
    test('your own profile is the demo account', () async {
      await signIn();
      final me = right(await profiles.getProfile(ProfileRepository.me));

      expect(me.name, 'John. B');
      expect(me.handle, 'john');
      expect(me.isMe, isTrue);
      expect(me.followingCount, 340);
      expect(me.recentPosts, hasLength(3));
    });

    test('guests have no own profile, but see others', () async {
      expect(
        (await profiles.getProfile(ProfileRepository.me))
            .getLeft()
            .toNullable(),
        const ProfileFailure(ProfileFailureReason.signInRequired),
      );
      final leo = right(await profiles.getProfile('a_leo'));
      expect(leo.isMe, isFalse);
      expect(leo.recentPosts.map((p) => p.id), contains('post_utility_chic'));
    });

    test('following counts once and can be undone', () async {
      await signIn();
      expect(
        right(await profiles.setFollowing('a_amin', following: true)),
        const FollowState(followerCount: 721, following: true),
      );
      await profiles.setFollowing('a_amin', following: true);
      expect(right(await profiles.getProfile('a_amin')).followerCount, 721);
      expect(
        right(await profiles.setFollowing('a_amin', following: false)),
        const FollowState(followerCount: 720, following: false),
      );
    });

    test('an opened post says whether you follow its author', () async {
      Future<PostAuthor> authorOf(String postId) async =>
          PostJson.post(await backend.post(postId, token: await tokens.read()))
              .author;

      // Guests see Follow (and are asked to sign in when they tap it).
      var leo = await authorOf('post_utility_chic');
      expect(leo.isMe, isFalse);
      expect(leo.followedByMe, isFalse);

      await signIn();
      await profiles.setFollowing('a_leo', following: true);
      leo = await authorOf('post_utility_chic');
      expect(leo.followedByMe, isTrue);
      expect(
        leo.followerCount,
        right(await profiles.getProfile('a_leo')).followerCount,
      );

      // Your own post has nobody to follow.
      expect((await authorOf('post_john_coat')).isMe, isTrue);
    });

    test('you cannot follow yourself; guests must sign in', () async {
      expect(
        (await profiles.setFollowing(
          'a_amin',
          following: true,
        )).getLeft().toNullable(),
        const ProfileFailure(ProfileFailureReason.signInRequired),
      );
      await signIn();
      expect(
        (await profiles.setFollowing(
          'a_john',
          following: true,
        )).getLeft().toNullable(),
        const ProfileFailure(ProfileFailureReason.unknown),
      );
    });

    test('saved posts come newest first, with their creators', () async {
      await signIn();
      await backend.setSaved(await tokens.read(), 'post_mina', saved: true);
      final saved = right(await profiles.getSavedPosts());

      expect(saved.first.post.id, 'post_mina');
      expect(saved.first.engagement.saved, isTrue);
      expect(saved.map((s) => s.author.handle), contains('leo'));
    });
  });

  group('wardrobe', () {
    test('categories count the seeded items', () async {
      await signIn();
      final categories = right(await wardrobe.getCategories());
      expect(
        {for (final c in categories) c.id: c.itemCount},
        {'outerwear': 1, 'tops': 3, 'bottoms': 2, 'shoes': 1, 'accessories': 2},
      );
    });

    test('saving a product adds it; removing takes it out', () async {
      await signIn();
      expect(
        right(await wardrobe.setInWardrobe('p_tee_zara', saved: true)),
        isTrue,
      );
      final tops = right(await wardrobe.getItems('tops'));
      expect(tops.first.productId, 'p_tee_zara', reason: 'newest first');

      await wardrobe.setInWardrobe('w_sneakers', saved: false);
      expect(right(await wardrobe.getItems('shoes')), isEmpty);
    });

    test('only catalog products can be saved; guests must sign in', () async {
      expect(
        (await wardrobe.getCategories()).getLeft().toNullable(),
        const WardrobeFailure(WardrobeFailureReason.signInRequired),
      );
      await signIn();
      expect(
        (await wardrobe.setInWardrobe(
          'nope',
          saved: true,
        )).getLeft().toNullable(),
        const WardrobeFailure(WardrobeFailureReason.notFound),
      );
    });
  });

  group('FollowingCubit', () {
    const amin = FollowState(followerCount: 720, following: false);
    late _MockSetFollowing setFollowing;

    setUpAll(
      () => registerFallbackValue(const FollowToggle('', following: true)),
    );
    setUp(() => setFollowing = _MockSetFollowing());

    test('a follow shows at once and a refusal rolls it back', () async {
      final response = Completer<Either<ProfileFailure, FollowState>>();
      when(() => setFollowing(any())).thenAnswer((_) => response.future);
      final cubit = FollowingCubit(setFollowing);

      final done = cubit.toggle('a_amin', amin);
      expect(
        cubit.state.of('a_amin', amin),
        const FollowState(followerCount: 721, following: true),
      );
      // A second tap while the first is pending does nothing.
      await cubit.toggle('a_amin', amin);
      verify(() => setFollowing(any())).called(1);

      response.complete(
        const Left(ProfileFailure(ProfileFailureReason.network)),
      );
      await done;
      expect(cubit.state.of('a_amin', amin), amin);
      expect(cubit.state.failureCount, 1);
      await cubit.close();
    });

    test('the server\'s answer wins, and unfollowing undoes it', () async {
      when(() => setFollowing(any())).thenAnswer(
        (invocation) async => Right(
          (invocation.positionalArguments.single as FollowToggle).following
              ? const FollowState(followerCount: 725, following: true)
              : const FollowState(followerCount: 724, following: false),
        ),
      );
      final cubit = FollowingCubit(setFollowing);

      await cubit.toggle('a_amin', amin);
      expect(
        cubit.state.of('a_amin', amin),
        const FollowState(followerCount: 725, following: true),
      );
      // Another screen still holding the old loaded state agrees.
      await cubit.toggle('a_amin', amin);
      expect(
        cubit.state.of('a_amin', amin),
        const FollowState(followerCount: 724, following: false),
      );
      await cubit.close();
    });

    test('a reply that lands after another user signs in is dropped', () async {
      final response = Completer<Either<ProfileFailure, FollowState>>();
      when(() => setFollowing(any())).thenAnswer((_) => response.future);
      final cubit = FollowingCubit(setFollowing);

      final done = cubit.toggle('a_amin', amin);
      cubit.reset();
      response.complete(
        const Right(FollowState(followerCount: 721, following: true)),
      );
      await done;
      expect(cubit.state.of('a_amin', amin), amin);
      await cubit.close();
    });
  });

  group('WardrobeMembershipCubit', () {
    late _MockSetInWardrobe setInWardrobe;

    setUpAll(
      () => registerFallbackValue(const WardrobeToggle('', saved: true)),
    );
    setUp(() => setInWardrobe = _MockSetInWardrobe());

    test('a save shows at once and is kept when confirmed', () async {
      when(() => setInWardrobe(any()))
          .thenAnswer((_) async => const Right(true));
      final cubit = WardrobeMembershipCubit(setInWardrobe);

      expect(await cubit.toggle('p', current: false), isTrue);
      expect(cubit.state.contains('p', loaded: false), isTrue);
      await cubit.close();
    });

    test('a refused save is rolled back and reported', () async {
      when(() => setInWardrobe(any())).thenAnswer(
        (_) async => const Left(WardrobeFailure(WardrobeFailureReason.network)),
      );
      final cubit = WardrobeMembershipCubit(setInWardrobe);

      expect(await cubit.toggle('p', current: false), isFalse);
      expect(cubit.state.contains('p', loaded: false), isFalse);
      expect(cubit.state.failureCount, 1);

      cubit.reset();
      expect(cubit.state.overrides, isEmpty);
      await cubit.close();
    });
  });
}
