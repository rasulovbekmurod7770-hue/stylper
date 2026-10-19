import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/core/usecase/usecase.dart';
import 'package:stylper/features/search/data/datasources/search_remote_data_source.dart';
import 'package:stylper/features/search/data/repositories/search_repository_impl.dart';
import 'package:stylper/features/search/domain/entities/search_results.dart';
import 'package:stylper/features/search/domain/failures/search_failure.dart';
import 'package:stylper/features/search/domain/usecases/search_usecases.dart';
import 'package:stylper/features/search/presentation/cubits/search_cubit.dart';
import 'package:stylper/features/search/presentation/widgets/search_rows.dart';

class _MockDiscover extends Mock implements GetSearchDiscovery {}

class _MockSearch extends Mock implements SearchBrandsAndPeople {}

void main() {
  late FakeBackend backend;
  late InMemoryAuthTokenStore tokens;
  late SearchRepositoryImpl search;

  setUp(() {
    backend = FakeBackend(latency: Duration.zero);
    tokens = InMemoryAuthTokenStore();
    search = SearchRepositoryImpl(
      remote: FakeSearchRemoteDataSource(backend, tokens),
    );
  });

  Future<void> signIn() async {
    final session = await backend.login(
      FakeBackend.demoEmail,
      FakeBackend.demoPassword,
    );
    await tokens.save(session['accessToken']! as String);
  }

  Future<SearchResults> find(String query) async =>
      (await search.search(query)).getOrElse((f) => throw StateError('$f'));

  group('GET /search', () {
    test('finds people by username, ignoring case and a leading @', () async {
      final results = await find('@AMIN');
      expect(results.people.first.handle, 'amin');
      expect(results.people.first.name, 'Amin');
    });

    test('finds people by a word of their name', () async {
      expect((await find('cho')).people.map((p) => p.handle), ['mina']);
      expect((await find('can fly')).people.map((p) => p.handle), ['fozil']);
    });

    test('an exact username comes before ones that only start with it', () {
      return find('bob').then((results) {
        expect(results.people.map((p) => p.handle).take(2), ['bob', 'Bobur']);
      });
    });

    test('usernames are unique', () async {
      final fozils = (await find('fozil')).people
          .where((p) => p.handle == 'fozil');
      expect(fozils, hasLength(1));
    });

    test('finds brands by name or username, with their item count', () async {
      final zara = (await find('zara')).brands.single;
      expect(zara.name, 'ZARA');
      expect(zara.handle, 'zara');
      expect(zara.isVerified, isTrue);
      expect(zara.isLocal, isFalse);
      expect(zara.productCount, greaterThan(0));

      expect((await find('terra')).brands.single.handle, 'terra_pro');
    });

    test('local brands come first among equal matches', () async {
      // "k" starts Kink (local) and is inside ARKET.
      final brands = (await find('k')).brands.map((b) => b.name);
      expect(brands.first, 'Kink');
      expect(brands, contains('ARKET'));
    });

    test('guests can search; nobody is "me" to them', () async {
      final results = await find('john');
      expect(results.people.single.isMe, isFalse);
      expect(results.people.single.followedByMe, isFalse);
    });

    test('signed in, you are "me" and see who you follow', () async {
      await signIn();
      expect((await find('john')).people.single.isMe, isTrue);

      await backend.setFollowing(
        await tokens.read(),
        'a_amin',
        following: true,
      );
      final amin = (await find('amin')).people.first;
      expect(amin.followedByMe, isTrue);
      expect(amin.followerCount, 721);
    });

    test('nothing matches nonsense, and a blank query finds nothing', () async {
      expect((await find('qqqq')).isEmpty, isTrue);
      expect((await find('  @ ')).isEmpty, isTrue);
    });
  });

  test(
    'GET /search/discover lists local brands first, then trending',
    () async {
      final discovery = (await search.discover()).getOrElse(
        (f) => throw StateError('$f'),
      );
      expect(discovery.city, 'Tashkent');
      expect(discovery.brands.take(2).every((b) => b.isLocal), isTrue);
      expect(discovery.brands, hasLength(6));
      expect(discovery.trending, isNotEmpty);
    },
  );

  test('brands without a logo show their monogram', () {
    expect(BrandAvatar.monogram('COS'), 'CO');
    expect(BrandAvatar.monogram('Terra Pro'), 'TP');
    expect(BrandAvatar.monogram('UNIQLO'), 'UN');
  });

  group('SearchCubit', () {
    const zara = SearchResults(
      brands: [
        BrandSummary(
          id: 'b_zara',
          name: 'ZARA',
          handle: 'zara',
          productCount: 3,
        ),
      ],
    );
    late _MockDiscover discover;
    late _MockSearch searchUseCase;

    setUp(() {
      discover = _MockDiscover();
      searchUseCase = _MockSearch();
      registerFallbackValue(const NoParams());
    });

    test('searches once, after the user pauses typing', () async {
      when(() => searchUseCase(any())).thenAnswer((_) async => right(zara));
      final cubit = SearchCubit(discover, searchUseCase)
        ..setQuery('z')
        ..setQuery('za')
        ..setQuery('zara');
      expect(cubit.state.isIdle, isFalse);
      await Future<void>.delayed(
        SearchCubit.debounce + const Duration(milliseconds: 50),
      );

      verify(() => searchUseCase('zara')).called(1);
      verifyNever(() => searchUseCase('za'));
      expect(cubit.state.results, zara);
      await cubit.close();
    });

    test('an answer to an older query is dropped', () async {
      final slow = Completer<Either<SearchFailure, SearchResults>>();
      when(() => searchUseCase('zara')).thenAnswer((_) => slow.future);
      when(() => searchUseCase('amin'))
          .thenAnswer((_) async => right(const SearchResults()));
      final cubit = SearchCubit(discover, searchUseCase)..setQuery('zara');
      await Future<void>.delayed(
        SearchCubit.debounce + const Duration(milliseconds: 50),
      );

      cubit.setQuery('amin');
      await Future<void>.delayed(
        SearchCubit.debounce + const Duration(milliseconds: 50),
      );
      slow.complete(right(zara));
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.query, 'amin');
      expect(cubit.state.results, const SearchResults());
      await cubit.close();
    });

    test('a blank or "@" query goes back to discovery without a request', () {
      final cubit = SearchCubit(discover, searchUseCase)..setQuery('@');
      expect(cubit.state.isIdle, isTrue);
      cubit.setQuery('   ');
      expect(cubit.state.isIdle, isTrue);
      verifyNever(() => searchUseCase(any()));
      return cubit.close();
    });

    test('closing cancels a pending search', () async {
      final cubit = SearchCubit(discover, searchUseCase)..setQuery('zara');
      await cubit.close();
      await Future<void>.delayed(
        SearchCubit.debounce + const Duration(milliseconds: 50),
      );
      verifyNever(() => searchUseCase(any()));
    });
  });
}
