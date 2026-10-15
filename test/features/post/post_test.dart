import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/features/home/data/datasources/home_remote_data_source.dart';
import 'package:stylper/features/home/data/repositories/home_repository_impl.dart';
import 'package:stylper/features/post/data/datasources/post_remote_data_source.dart';
import 'package:stylper/features/post/data/repositories/post_repository_impl.dart';
import 'package:stylper/features/post/domain/entities/post.dart';
import 'package:stylper/features/post/domain/failures/post_failure.dart';
import 'package:stylper/features/post/domain/usecases/post_usecases.dart';
import 'package:stylper/features/post/presentation/cubits/post_engagement_cubit.dart';

class _MockSetLiked extends Mock implements SetPostLiked {}

class _MockSetSaved extends Mock implements SetPostSaved {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PostRepositoryImpl with the fake backend', () {
    late FakeBackend backend;
    late InMemoryAuthTokenStore tokens;
    late PostRepositoryImpl posts;

    setUp(() {
      backend = FakeBackend(latency: Duration.zero);
      tokens = InMemoryAuthTokenStore();
      posts = PostRepositoryImpl(
        remote: FakePostRemoteDataSource(backend, tokens),
      );
    });

    Future<void> signIn() async {
      final session = await backend.login(
        FakeBackend.demoEmail,
        FakeBackend.demoPassword,
      );
      await tokens.save(session['accessToken']! as String);
    }

    Future<Post> load(String id) async =>
        (await posts.getPost(id))
            .getOrElse((failure) => throw StateError('$failure'));

    test('loads a post with its tagged products and similar posts', () async {
      final post = await load('post_utility_chic');

      expect(post.author.handle, 'leo');
      expect(post.products.map((p) => '${p.brand} · ${p.shortName}'), [
        'COS · Cardigan',
        'Terra Pro · T-Shirt',
        'ZARA · Trousers',
      ]);
      expect(
        post.products.first.price,
        const Money(amount: 89, currency: 'USD'),
      );
      expect(post.similar, hasLength(4));
      expect(post.engagement, const PostEngagement(likeCount: 412));
    });

    test('every post and product image is bundled', () async {
      final ids = [
        'post_mina',
        'post_fozil',
        'post_bobur',
        'post_sofia',
        'post_leo',
        'post_amin',
        'post_utility_chic',
        'post_soft_neutrals',
        'post_no_words',
        'post_like_my_outfit',
      ];
      for (final id in ids) {
        final post = await load(id);
        for (final path in {
          post.imagePath,
          post.author.avatarPath,
          ...post.products.map((p) => p.imagePath),
          ...post.similar.map((p) => p.imagePath),
        }) {
          expect(
            (await rootBundle.load(path)).lengthInBytes,
            isPositive,
            reason: '$id: $path',
          );
        }
      }
    });

    test('an unknown post is not found', () async {
      expect(
        await posts.getPost('nope'),
        const Left<PostFailure, Post>(PostFailure(PostFailureReason.notFound)),
      );
    });

    test('guests must sign in to like or save', () async {
      const signIn = Left<PostFailure, PostEngagement>(
        PostFailure(PostFailureReason.signInRequired),
      );
      expect(await posts.setLiked('post_mina', liked: true), signIn);
      expect(await posts.setSaved('post_mina', saved: true), signIn);
    });

    test('a like is counted once and shows up in the feed', () async {
      await signIn();

      final liked = await posts.setLiked('post_mina', liked: true);
      expect(
        liked,
        const Right<PostFailure, PostEngagement>(
          PostEngagement(likeCount: 1249, liked: true),
        ),
      );
      // Liking again doesn't count twice.
      expect(
        (await posts.setLiked(
          'post_mina',
          liked: true,
        )).toNullable()!.likeCount,
        1249,
      );
      expect((await load('post_mina')).engagement.liked, isTrue);

      final feed = (await HomeRepositoryImpl(
        remote: FakeHomeRemoteDataSource(backend, tokens),
      ).getHomeFeed()).toNullable()!;
      expect(feed.featured.first.engagement.liked, isTrue);

      final unliked = await posts.setLiked('post_mina', liked: false);
      expect(unliked.toNullable(), const PostEngagement(likeCount: 1248));
    });

    test('saving is per user', () async {
      await signIn();
      await posts.setSaved('post_sofia', saved: true);
      expect((await load('post_sofia')).engagement.saved, isTrue);

      await tokens.clear();
      expect((await load('post_sofia')).engagement.saved, isFalse);
    });
  });

  group('PostEngagementCubit', () {
    const loaded = PostEngagement(likeCount: 10);
    late _MockSetLiked setLiked;
    late _MockSetSaved setSaved;
    late PostEngagementCubit cubit;

    setUpAll(() => registerFallbackValue(const PostToggle('', on: true)));
    setUp(() {
      setLiked = _MockSetLiked();
      setSaved = _MockSetSaved();
      cubit = PostEngagementCubit(setLiked, setSaved);
    });
    tearDown(() => cubit.close());

    test('a like shows at once, then takes the server count', () async {
      final response = Completer<Either<PostFailure, PostEngagement>>();
      when(() => setLiked(any())).thenAnswer((_) => response.future);

      final done = cubit.toggleLike('p', loaded);
      expect(
        cubit.state.of('p', loaded),
        const PostEngagement(likeCount: 11, liked: true),
      );

      response.complete(
        const Right(PostEngagement(likeCount: 15, liked: true)),
      );
      await done;
      expect(
        cubit.state.of('p', loaded),
        const PostEngagement(likeCount: 15, liked: true),
      );
      verify(() => setLiked(const PostToggle('p', on: true))).called(1);
    });

    test('a refused like is rolled back and reported', () async {
      when(() => setLiked(any())).thenAnswer(
        (_) async => const Left(PostFailure(PostFailureReason.network)),
      );

      await cubit.toggleLike('p', loaded);

      expect(cubit.state.of('p', loaded), loaded);
      expect(cubit.state.failure, const PostFailure(PostFailureReason.network));
      expect(cubit.state.failureCount, 1);
    });

    test('taps while a like is pending are ignored', () async {
      final response = Completer<Either<PostFailure, PostEngagement>>();
      when(() => setLiked(any())).thenAnswer((_) => response.future);

      final first = cubit.toggleLike('p', loaded);
      await cubit.toggleLike('p', cubit.state.of('p', loaded));
      response.complete(
        const Right(PostEngagement(likeCount: 11, liked: true)),
      );
      await first;

      verify(() => setLiked(any())).called(1);
      expect(cubit.state.of('p', loaded).liked, isTrue);
    });

    test('like and save on one post settle independently', () async {
      when(() => setLiked(any())).thenAnswer(
        (_) async => const Left(PostFailure(PostFailureReason.unknown)),
      );
      when(() => setSaved(any())).thenAnswer(
        (_) async => const Right(PostEngagement(likeCount: 10, saved: true)),
      );

      await Future.wait([
        cubit.toggleLike('p', loaded),
        cubit.toggleSave('p', loaded),
      ]);

      expect(
        cubit.state.of('p', loaded),
        const PostEngagement(likeCount: 10, saved: true),
      );
    });

    test('reset forgets this session\'s changes', () async {
      when(() => setSaved(any())).thenAnswer(
        (_) async => const Right(PostEngagement(likeCount: 10, saved: true)),
      );
      await cubit.toggleSave('p', loaded);
      cubit.reset();
      expect(cubit.state.of('p', loaded), loaded);
    });
  });
}
