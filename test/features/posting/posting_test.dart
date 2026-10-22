import 'package:flutter_test/flutter_test.dart';
import 'package:stylper/core/fake_backend/fake_backend.dart';
import 'package:stylper/core/network/auth_token_store.dart';
import 'package:stylper/features/post/data/datasources/post_remote_data_source.dart';
import 'package:stylper/features/post/data/repositories/post_repository_impl.dart';
import 'package:stylper/features/posting/data/datasources/posting_remote_data_source.dart';
import 'package:stylper/features/posting/data/repositories/posting_repository_impl.dart';
import 'package:stylper/features/posting/domain/entities/media.dart';
import 'package:stylper/features/posting/domain/entities/post_draft.dart';
import 'package:stylper/features/posting/domain/entities/taggable_item.dart';
import 'package:stylper/features/posting/domain/failures/posting_failure.dart';
import 'package:stylper/features/posting/domain/usecases/posting_usecases.dart';
import 'package:stylper/features/posting/presentation/cubits/media_picker_cubit.dart';
import 'package:stylper/features/posting/presentation/cubits/post_draft_cubit.dart';
import 'package:stylper/features/posting/presentation/cubits/tag_search_cubit.dart';
import 'package:stylper/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:stylper/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:stylper/features/profile/domain/repositories/profile_repository.dart';
import 'package:stylper/core/domain/money.dart';
import 'package:stylper/features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import 'package:stylper/features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import 'package:stylper/features/wardrobe/domain/entities/wardrobe.dart';

import '../../helpers/fake_media.dart';

const _photo = 'assets/images/posts/john_knit.webp';

const _sweaterTag = DraftTag(
  item: TaggableItem(
    id: 'p_polo_arket',
    name: 'Rugby Polo Sweater',
    label: 'Sweater',
    brand: 'ARKET',
    imagePath: 'assets/images/style_quiz/rugby_polo_sweater_arket.webp',
  ),
  x: 0.4,
  y: 0.25,
);

void main() {
  late FakeBackend backend;
  late InMemoryAuthTokenStore tokens;
  late PostingRepositoryImpl posting;

  setUp(() {
    backend = FakeBackend(latency: Duration.zero);
    tokens = InMemoryAuthTokenStore();
    posting = PostingRepositoryImpl(
      remote: FakePostingRemoteDataSource(backend, tokens),
    );
  });

  Future<void> signIn() async {
    final session = await backend.login(
      FakeBackend.demoEmail,
      FakeBackend.demoPassword,
    );
    await tokens.save(session['accessToken']! as String);
  }

  Future<List<String>> search(
    String query, {
    String? category,
    bool mine = false,
  }) async => (await posting.searchItems(
    query,
    category: category,
    mine: mine,
  )).getOrElse((f) => throw StateError('$f')).map((p) => p.id).toList();

  group('item search (brands\' catalogs)', () {
    test('every word must match the brand, name or item type', () async {
      expect(await search('jeans zara'), ['p_jeans_vintage_zara']);
      expect(
        await search('JEANS'),
        unorderedEquals(['p_jeans_kink', 'p_jeans_vintage_zara']),
      );
      expect(await search('cardigan'), ['p_cardigan_cos']);
      expect(await search('nothing like this'), isEmpty);
    });

    test('a category narrows the catalog', () async {
      expect(await search('', category: 'shoes'), ['p_sneakers_terra_pro']);
      expect(
        await search('kink', category: 'accessories'),
        unorderedEquals(['p_watch_kink', 'p_sunglasses_kink']),
      );
    });

    test(
      '"My Wardrobe" keeps only your wardrobe, your own items first',
      () async {
        await signIn();
        final json = await backend.searchProducts(
          mine: true,
          token: await tokens.read(),
        );
        final products = (json['products']! as List<Object?>).length;
        final mine = await search('', mine: true);
        expect(mine.take(3), ['w_sneakers', 'w_sunglasses', 'w_watches']);
        expect(mine, hasLength(products + 3));
        final catalog = await search('');
        expect(catalog, containsAll(mine.skip(3)));
        // Items people add themselves never show in the catalog.
        expect(catalog, isNot(contains('w_sneakers')));
        // Brand and name match own items too.
        expect((await search('kink watch', mine: true)).first, 'w_watches');
      },
    );

    test('recent tags are items from your own posts', () async {
      await signIn();
      final recent = (await posting.recentTags()).getOrElse(
        (f) => throw StateError('$f'),
      );
      expect(recent, isNotEmpty);
      expect(recent.map((p) => p.id).toSet(), hasLength(recent.length));
    });
  });

  group('publishing', () {
    test(
      'the new post opens with its tags and shows on your profile',
      () async {
        await signIn();
        final id = (await posting.publish(
          const PostDraft(
            photoPath: _photo,
            tags: [_sweaterTag],
            caption: '  Soft layers  ',
            location: 'Tashkent',
            styles: ['minimal'],
          ),
        )).getOrElse((f) => throw StateError('$f'));

        final posts = PostRepositoryImpl(
          remote: FakePostRemoteDataSource(backend, tokens),
        );
        final post = (await posts.getPost(id))
            .getOrElse((f) => throw StateError('$f'));
        expect(post.imagePath, _photo);
        expect(post.caption, 'Soft layers');
        expect(post.location, 'Tashkent');
        expect(post.author.handle, 'john');
        expect(post.products.single.id, 'p_polo_arket');
        expect(post.products.single.tagX, 0.4);

        final profiles = ProfileRepositoryImpl(
          remote: FakeProfileRemoteDataSource(backend, tokens),
        );
        final me = (await profiles.getProfile(ProfileRepository.me))
            .getOrElse((f) => throw StateError('$f'));
        expect(me.recentPosts.first.id, id);
      },
    );

    test('needs a signed-in user', () async {
      final result = await posting.publish(const PostDraft(photoPath: _photo));
      expect(
        result.getLeft().toNullable(),
        const PostingFailure(PostingFailureReason.signInRequired),
      );
    });

    test('refuses an unknown item', () async {
      await signIn();
      final result = await posting.publish(
        const PostDraft(
          photoPath: _photo,
          tags: [
            DraftTag(
              item: TaggableItem(
                id: 'p_missing',
                name: 'Y',
                label: 'Y',
                brand: 'X',
              ),
              x: 0.5,
              y: 0.5,
            ),
          ],
        ),
      );
      expect(
        result.getLeft().toNullable(),
        const PostingFailure(PostingFailureReason.invalid),
      );
    });
  });

  group('your own items (not in any catalog)', () {
    late WardrobeRepositoryImpl wardrobe;
    late PostRepositoryImpl posts;

    setUp(() {
      wardrobe = WardrobeRepositoryImpl(
        remote: FakeWardrobeRemoteDataSource(backend, tokens),
      );
      posts = PostRepositoryImpl(
        remote: FakePostRemoteDataSource(backend, tokens),
      );
    });

    Future<WardrobeItem> add({Money? price}) async => (await wardrobe.addItem(
      NewWardrobeItem(
        name: 'Grey Cardigan',
        brand: 'TIMEOFLESS',
        category: 'tops',
        price: price,
      ),
    )).getOrElse((f) => throw StateError('$f'));

    Future<String> publishWith(TaggableItem item) async =>
        (await posting.publish(
          PostDraft(
            photoPath: _photo,
            tags: [DraftTag(item: item, x: 0.5, y: 0.4)],
          ),
        )).getOrElse((f) => throw StateError('$f'));

    test('go to your wardrobe, and only "My Wardrobe" finds them', () async {
      await signIn();
      final item = await add(
        price: const Money(amount: 350000, currency: 'UZS'),
      );
      expect(item.name, 'Grey Cardigan');
      expect(item.imagePath, isNull);
      expect(item.productId, isNull);

      final tops = (await wardrobe.getItems('tops'))
          .getOrElse((f) => throw StateError('$f'));
      expect(tops.first, item);
      expect((await search('cardigan', mine: true)).first, item.id);
      expect(await search('cardigan'), isNot(contains(item.id)));
    });

    test(
      'need a name, a brand and a category; the price is optional',
      () async {
        await signIn();
        expect((await add()).price, isNull);
        final blank = await wardrobe.addItem(
          const NewWardrobeItem(name: ' ', brand: 'X', category: 'tops'),
        );
        expect(blank.isLeft(), isTrue);
        final free = await wardrobe.addItem(
          const NewWardrobeItem(
            name: 'Scarf',
            brand: 'Bazaar',
            category: 'accessories',
            price: Money(amount: 0, currency: 'UZS'),
          ),
        );
        expect(free.isLeft(), isTrue);
      },
    );

    test('tagged on a post, everyone sees what they are', () async {
      await signIn();
      final item = await add(
        price: const Money(amount: 350000, currency: 'UZS'),
      );
      final id = await publishWith(TaggableItem.own(item));

      // Gone from the wardrobe later, the post still shows it.
      await wardrobe.setInWardrobe(item.id, saved: false);
      await tokens.clear();
      final post = (await posts.getPost(id))
          .getOrElse((f) => throw StateError('$f'));
      final tagged = post.products.single;
      expect(tagged.addedByAuthor, isTrue);
      expect(tagged.name, 'Grey Cardigan');
      expect(tagged.brand, 'TIMEOFLESS');
      expect(tagged.price, const Money(amount: 350000, currency: 'UZS'));
      expect(tagged.imagePath, isNull);
      expect(tagged.tagY, 0.4);
    });

    test('without a price, the post shows none', () async {
      await signIn();
      final id = await publishWith(TaggableItem.own(await add()));
      final post = (await posts.getPost(id))
          .getOrElse((f) => throw StateError('$f'));
      expect(post.products.single.price, isNull);
    });

    test('recent tags keep to catalog products', () async {
      await signIn();
      await publishWith(TaggableItem.own(await add()));
      final recent = (await posting.recentTags()).getOrElse(
        (f) => throw StateError('$f'),
      );
      expect(recent, isNotEmpty);
      expect(recent.any((item) => item.own), isFalse);
    });

    test("nobody can tag someone else's item", () async {
      final session = await backend.login(
        'katty.miller@stylper.ai',
        FakeBackend.demoPassword,
      );
      await tokens.save(session['accessToken']! as String);
      final result = await posting.publish(
        const PostDraft(
          photoPath: _photo,
          tags: [
            DraftTag(
              item: TaggableItem(
                id: 'w_sneakers', // John's
                name: 'Suede Sneakers',
                label: 'Suede Sneakers',
                brand: 'Terra Pro',
                own: true,
              ),
              x: 0.5,
              y: 0.5,
            ),
          ],
        ),
      );
      expect(
        result.getLeft().toNullable(),
        const PostingFailure(PostingFailureReason.invalid),
      );
    });
  });

  group('MediaPickerCubit', () {
    test(
      'with access, shows the library with the newest photo chosen',
      () async {
        final media = FakeMediaRepository();
        final cubit = MediaPickerCubit(media);
        await cubit.start();

        expect(cubit.state.status, MediaPickerStatus.ready);
        expect(cubit.state.limited, isFalse);
        expect(cubit.state.photos, hasLength(media.library.length));
        expect(cubit.state.selected?.id, media.library.first);
        expect(await cubit.chosenFile(), media.library.first);
        await cubit.close();
      },
    );

    test('limited access still shows the shared photos, with Manage', () async {
      final media = FakeMediaRepository(access: MediaAccess.limited);
      final cubit = MediaPickerCubit(media);
      await cubit.start();
      expect(cubit.state.status, MediaPickerStatus.ready);
      expect(cubit.state.limited, isTrue);

      await cubit.manageSelection();
      expect(media.manageCalls, 1);
      await cubit.close();
    });

    test(
      'without access the camera still works; Settings is offered',
      () async {
        final media = FakeMediaRepository(
          access: MediaAccess.denied,
          cameraPhoto: _photo,
        );
        final cubit = MediaPickerCubit(media);
        await cubit.start();
        expect(cubit.state.status, MediaPickerStatus.denied);
        expect(cubit.state.hasChoice, isFalse);

        await cubit.takePhoto();
        expect(cubit.state.cameraPhotoPath, _photo);
        expect(await cubit.chosenFile(), _photo);

        // Allowed in Settings, back in the app.
        media.access = MediaAccess.full;
        await cubit.start();
        expect(cubit.state.status, MediaPickerStatus.ready);
        // The photo just taken stays chosen.
        expect(await cubit.chosenFile(), _photo);
        await cubit.close();
      },
    );

    test('pages through a large library', () async {
      final media = FakeMediaRepository(
        library: [for (var i = 0; i < 130; i++) 'photo_$i'],
      );
      final cubit = MediaPickerCubit(media);
      await cubit.start();
      expect(cubit.state.photos, hasLength(MediaPickerCubit.pageSize));
      expect(cubit.state.hasMore, isTrue);

      await cubit.loadMore();
      await cubit.loadMore();
      expect(cubit.state.photos, hasLength(130));
      expect(cubit.state.hasMore, isFalse);
      await cubit.close();
    });
  });

  group('PostDraftCubit', () {
    late PostDraftCubit draft;

    setUp(() async {
      draft = PostDraftCubit(GetPostStyles(posting), PublishPost(posting));
      await draft.loadStyles();
    });

    tearDown(() => draft.close());

    test('loads the style options from the backend', () {
      expect(draft.state.styleOptions, contains('minimal'));
    });

    test('a different photo drops the tags placed on the old one', () {
      draft
        ..setPhoto(_photo)
        ..addTag(_sweaterTag)
        ..setPhoto(_photo);
      expect(draft.state.draft.tags, [_sweaterTag]);

      draft.setPhoto('assets/images/posts/leo.webp');
      expect(draft.state.draft.tags, isEmpty);
    });

    test('lists each mentioned brand once', () {
      draft
        ..setPhoto(_photo)
        ..addTag(_sweaterTag)
        ..addTag(_sweaterTag.copyWithPosition(0.6, 0.7));
      expect(draft.state.draft.brands, ['ARKET']);
    });

    test('styles toggle on and off', () {
      draft
        ..toggleStyle('minimal')
        ..toggleStyle('casual')
        ..toggleStyle('minimal');
      expect(draft.state.draft.styles, ['casual']);
    });

    test('publishing reports the new post', () async {
      await signIn();
      draft
        ..setPhoto(_photo)
        ..addTag(_sweaterTag);
      await draft.publish();
      expect(draft.state.status, PublishStatus.published);
      expect(draft.state.publishedPostId, isNotNull);
    });

    test('a refused publish keeps the draft to try again', () async {
      draft.setPhoto(_photo);
      await draft.publish();
      expect(draft.state.status, PublishStatus.failure);
      expect(
        draft.state.failure,
        const PostingFailure(PostingFailureReason.signInRequired),
      );
      expect(draft.state.draft.photoPath, _photo);
    });
  });

  group('TagSearchCubit', () {
    test('searches once the user pauses typing', () async {
      await signIn();
      final search = TagSearchCubit(
        SearchItems(posting),
        GetRecentTags(posting),
      );
      await search.load();
      expect(search.state.recent, isNotEmpty);
      expect(search.state.results.length, greaterThan(5));

      search
        ..setQuery('j')
        ..setQuery('jea')
        ..setQuery('jeans zara');
      await Future<void>.delayed(const Duration(milliseconds: 350));
      expect(search.state.results.map((p) => p.id), ['p_jeans_vintage_zara']);

      search.toggleCategory('tops');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(search.state.results, isEmpty);
      await search.close();
    });

    test('closing cancels a pending search', () async {
      final search = TagSearchCubit(
        SearchItems(posting),
        GetRecentTags(posting),
      )..setQuery('jeans');
      await search.close();
      await Future<void>.delayed(const Duration(milliseconds: 350));
    });
  });
}

extension on DraftTag {
  DraftTag copyWithPosition(double x, double y) =>
      DraftTag(item: item, x: x, y: y);
}
