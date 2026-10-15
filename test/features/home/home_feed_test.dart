import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/core/error/exceptions.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/usecase/usecase.dart';
import 'package:stylper/features/home/data/datasources/home_remote_data_source.dart';
import 'package:stylper/features/home/data/repositories/home_repository_impl.dart';
import 'package:stylper/features/home/domain/entities/home_feed.dart';
import 'package:stylper/features/home/domain/failures/home_failure.dart';
import 'package:stylper/features/home/domain/usecases/get_home_feed.dart';
import 'package:stylper/features/home/presentation/cubits/home_feed_cubit.dart';

class _MockRemote extends Mock implements HomeRemoteDataSource {}

class _MockGetHomeFeed extends Mock implements GetHomeFeed {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeRepositoryImpl', () {
    test('parses the fake backend feed', () async {
      final repository = HomeRepositoryImpl(
        remote: FakeHomeRemoteDataSource(FakeBackend(latency: Duration.zero)),
      );

      final feed = (await repository.getHomeFeed()).getOrElse(
        (failure) => throw StateError('$failure'),
      );

      expect(feed.city, 'Tashkent');
      expect(feed.featured.map((p) => p.author.name), [
        'Mina Cho',
        'Fozil Can Fly',
        'Bob',
      ]);
      expect(feed.featured.first.likeCount, 1248);
      expect(feed.peopleWearing.map((p) => p.name), ['Sofia', 'Leo', 'Amin']);
      expect(feed.trending, hasLength(4));
      expect(feed.trending.last.caption, 'I like my Outfit');
    });

    test('every feed image is bundled', () async {
      final feed = (await HomeRepositoryImpl(
        remote: FakeHomeRemoteDataSource(FakeBackend(latency: Duration.zero)),
      ).getHomeFeed()).getOrElse((failure) => throw StateError('$failure'));
      final paths = {
        for (final post in feed.featured) ...[
          post.imagePath,
          post.author.avatarPath,
        ],
        for (final person in feed.peopleWearing) person.photoPath,
        for (final post in feed.trending) post.imagePath,
      };
      for (final path in paths) {
        expect((await rootBundle.load(path)).lengthInBytes, isPositive);
      }
    });

    test('maps data-layer errors to failures', () async {
      final remote = _MockRemote();
      final repository = HomeRepositoryImpl(remote: remote);

      when(remote.getHomeFeed).thenThrow(const NetworkException());
      expect(
        await repository.getHomeFeed(),
        const Left<HomeFailure, HomeFeed>(
          HomeFailure(HomeFailureReason.network),
        ),
      );

      when(remote.getHomeFeed)
          .thenThrow(const ServerException(statusCode: 500, code: 'internal'));
      expect(
        await repository.getHomeFeed(),
        const Left<HomeFailure, HomeFeed>(
          HomeFailure(HomeFailureReason.unknown),
        ),
      );
    });
  });

  group('HomeFeedCubit', () {
    const feed = HomeFeed(
      city: 'Tashkent',
      featured: [],
      peopleWearing: [],
      trending: [],
    );
    const failure = HomeFailure(HomeFailureReason.network);
    late _MockGetHomeFeed getHomeFeed;

    setUpAll(() => registerFallbackValue(const NoParams()));
    setUp(() => getHomeFeed = _MockGetHomeFeed());

    blocTest<HomeFeedCubit, HomeFeedState>(
      'loads the feed',
      setUp: () =>
          when(() => getHomeFeed(any()))
              .thenAnswer((_) async => const Right(feed)),
      build: () => HomeFeedCubit(getHomeFeed),
      act: (cubit) => cubit.load(),
      expect: () => const [
        HomeFeedState(),
        HomeFeedState(status: HomeFeedStatus.ready, feed: feed),
      ],
    );

    blocTest<HomeFeedCubit, HomeFeedState>(
      'a failed refresh keeps the feed on screen',
      setUp: () =>
          when(() => getHomeFeed(any()))
              .thenAnswer((_) async => const Left(failure)),
      build: () => HomeFeedCubit(getHomeFeed),
      seed: () => const HomeFeedState(status: HomeFeedStatus.ready, feed: feed),
      act: (cubit) => cubit.load(),
      expect: () => const [
        HomeFeedState(feed: feed),
        HomeFeedState(
          status: HomeFeedStatus.failure,
          feed: feed,
          failure: failure,
        ),
      ],
    );
  });
}
