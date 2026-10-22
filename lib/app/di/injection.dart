import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/fake_backend/fake_backend.dart';
import '../../core/network/auth_token_store.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/fake_auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/repositories/supabase_auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/email_auth.dart';
import '../../features/auth/domain/usecases/session.dart';
import '../../features/auth/domain/usecases/social_auth.dart';
import '../../features/auth/presentation/cubits/forgot_password_cubit.dart';
import '../../features/auth/presentation/cubits/sign_in_cubit.dart';
import '../../features/auth/presentation/cubits/sign_up_cubit.dart';
import '../../features/auth/presentation/cubits/social_sign_in_cubit.dart';
import '../../features/home/data/datasources/home_remote_data_source.dart';
import '../../features/home/data/repositories/home_repository_impl.dart';
import '../../features/home/domain/repositories/home_repository.dart';
import '../../features/home/domain/usecases/get_home_feed.dart';
import '../../features/home/presentation/cubits/home_feed_cubit.dart';
import '../../features/onboarding/data/datasources/onboarding_remote_data_source.dart';
import '../../features/onboarding/data/datasources/style_quiz_local_data_source.dart';
import '../../features/onboarding/data/datasources/supabase_onboarding_remote_data_source.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/onboarding_usecases.dart';
import '../../features/onboarding/presentation/cubits/profile_setup_cubit.dart';
import '../../features/onboarding/presentation/cubits/style_quiz_cubit.dart';
import '../../features/post/data/datasources/post_remote_data_source.dart';
import '../../features/product/data/datasources/product_remote_data_source.dart';
import '../../features/product/data/repositories/product_repository_impl.dart';
import '../../features/product/domain/repositories/product_repository.dart';
import '../../features/product/domain/usecases/get_product.dart';
import '../../features/product/presentation/cubits/product_detail_cubit.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/profile_usecases.dart';
import '../../features/profile/presentation/cubits/following_cubit.dart';
import '../../features/profile/presentation/cubits/profile_cubit.dart';
import '../../features/profile/presentation/cubits/saved_posts_cubit.dart';
import '../../features/search/data/datasources/search_remote_data_source.dart';
import '../../features/search/data/repositories/search_repository_impl.dart';
import '../../features/search/domain/repositories/search_repository.dart';
import '../../features/search/domain/usecases/search_usecases.dart';
import '../../features/search/presentation/cubits/search_cubit.dart';
import '../../features/wardrobe/data/datasources/wardrobe_remote_data_source.dart';
import '../../features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import '../../features/wardrobe/domain/repositories/wardrobe_repository.dart';
import '../../features/wardrobe/domain/usecases/wardrobe_usecases.dart';
import '../../features/wardrobe/presentation/cubits/wardrobe_cubit.dart';
import '../../features/wardrobe/presentation/cubits/add_item_cubit.dart';
import '../../features/wardrobe/presentation/cubits/wardrobe_items_cubit.dart';
import '../../features/wardrobe/presentation/cubits/wardrobe_membership_cubit.dart';
import '../../features/post/data/repositories/post_repository_impl.dart';
import '../../features/post/domain/repositories/post_repository.dart';
import '../../features/post/domain/usecases/post_usecases.dart';
import '../../features/post/presentation/cubits/post_detail_cubit.dart';
import '../../features/post/presentation/cubits/post_engagement_cubit.dart';
import '../../features/posting/data/datasources/posting_remote_data_source.dart';
import '../../features/posting/data/repositories/device_media_repository.dart';
import '../../features/posting/data/repositories/posting_repository_impl.dart';
import '../../features/posting/domain/repositories/media_repository.dart';
import '../../features/posting/domain/repositories/posting_repository.dart';
import '../../features/posting/domain/usecases/posting_usecases.dart';
import '../../features/posting/presentation/cubits/media_picker_cubit.dart';
import '../../features/posting/presentation/cubits/post_draft_cubit.dart';
import '../../features/posting/presentation/cubits/published_posts_cubit.dart';
import '../../features/posting/presentation/cubits/tag_search_cubit.dart';
import '../../features/posting/presentation/gallery_thumbnails.dart';
import '../session/session_cubit.dart';

final sl = GetIt.instance;

/// [supabase] switches the features already ported to Supabase over to it
/// (`BACKEND=supabase`, see `main.dart`); without it everything runs on the
/// fake backend. [backend] lets tests inject a [FakeBackend] without simulated
/// latency; [media] and [thumbnails] replace the device's photo library and
/// camera.
void configureDependencies({
  SupabaseClient? supabase,
  FakeBackend? backend,
  MediaRepository? media,
  GalleryThumbnails? thumbnails,
}) {
  // Infrastructure
  sl
    ..registerLazySingleton<AuthTokenStore>(InMemoryAuthTokenStore.new)
    // The photo library and camera (photo_manager / image_picker).
    ..registerLazySingleton<MediaRepository>(
      () => media ?? DeviceMediaRepository(),
    )
    ..registerLazySingleton<GalleryThumbnails>(
      () => thumbnails ?? const DeviceGalleryThumbnails(),
    );

  // ── Backend ──────────────────────────────────────────────────────────────
  // Every remote call goes through a *RemoteDataSource (or, for auth, the
  // repository itself). Features move from the in-memory FakeBackend to
  // Supabase one at a time, in the order of STYLPER_BACKEND_SPEC.md §10;
  // nothing outside this block needs to change.
  //
  // Ported: auth and onboarding. The rest still call FakeBackend, which
  // doesn't know Supabase users, so there they act as guests.
  sl.registerLazySingleton(() => backend ?? FakeBackend());
  if (supabase != null) {
    sl
      ..registerSingleton(supabase)
      ..registerLazySingleton<AuthRepository>(
        () => SupabaseAuthRepository(sl()),
      )
      ..registerLazySingleton<OnboardingRemoteDataSource>(
        () => SupabaseOnboardingRemoteDataSource(sl()),
      );
  } else {
    sl
      ..registerLazySingleton<AuthRemoteDataSource>(
        () => FakeAuthRemoteDataSource(sl()),
      )
      ..registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(remote: sl(), tokenStore: sl()),
      )
      ..registerLazySingleton<OnboardingRemoteDataSource>(
        () => FakeOnboardingRemoteDataSource(sl(), sl()),
      );
  }
  sl
    ..registerLazySingleton<HomeRemoteDataSource>(
      () => FakeHomeRemoteDataSource(sl(), sl()),
    )
    ..registerLazySingleton<PostRemoteDataSource>(
      () => FakePostRemoteDataSource(sl(), sl()),
    )
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => FakeProductRemoteDataSource(sl(), sl()),
    )
    ..registerLazySingleton<ProfileRemoteDataSource>(
      () => FakeProfileRemoteDataSource(sl(), sl()),
    )
    ..registerLazySingleton<WardrobeRemoteDataSource>(
      () => FakeWardrobeRemoteDataSource(sl(), sl()),
    )
    ..registerLazySingleton<PostingRemoteDataSource>(
      () => FakePostingRemoteDataSource(sl(), sl()),
    )
    ..registerLazySingleton<SearchRemoteDataSource>(
      () => FakeSearchRemoteDataSource(sl(), sl()),
    );
  // ─────────────────────────────────────────────────────────────────────────

  sl
    ..registerLazySingleton(StyleQuizLocalDataSource.new)
    // Repositories
    ..registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(remote: sl(), quizLocal: sl()),
    )
    ..registerLazySingleton<HomeRepository>(
      () => HomeRepositoryImpl(remote: sl()),
    )
    ..registerLazySingleton<PostRepository>(
      () => PostRepositoryImpl(remote: sl()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(remote: sl()),
    )
    ..registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(remote: sl()),
    )
    ..registerLazySingleton<WardrobeRepository>(
      () => WardrobeRepositoryImpl(remote: sl()),
    )
    ..registerLazySingleton<PostingRepository>(
      () => PostingRepositoryImpl(remote: sl()),
    )
    ..registerLazySingleton<SearchRepository>(
      () => SearchRepositoryImpl(remote: sl()),
    )
    // Use cases
    ..registerFactory(() => RestoreSession(sl()))
    ..registerFactory(() => WatchCurrentUser(sl()))
    ..registerFactory(() => SignOut(sl()))
    ..registerFactory(() => SignInWithEmail(sl()))
    ..registerFactory(() => SignUpWithEmail(sl()))
    ..registerFactory(() => SendPasswordResetEmail(sl()))
    ..registerFactory(() => SignInWithSocialProvider(sl()))
    ..registerFactory(() => SaveProfile(sl(), sl()))
    ..registerFactory(() => GetStyleQuiz(sl()))
    ..registerFactory(() => CompleteStyleQuiz(sl(), sl()))
    ..registerFactory(() => GetHomeFeed(sl()))
    ..registerFactory(() => GetPost(sl()))
    ..registerFactory(() => SetPostLiked(sl()))
    ..registerFactory(() => SetPostSaved(sl()))
    ..registerFactory(() => GetProduct(sl()))
    ..registerFactory(() => GetProfile(sl()))
    ..registerFactory(() => SetFollowing(sl()))
    ..registerFactory(() => GetSavedPosts(sl()))
    ..registerFactory(() => GetWardrobe(sl()))
    ..registerFactory(() => GetWardrobeItems(sl()))
    ..registerFactory(() => SetInWardrobe(sl()))
    ..registerFactory(() => AddWardrobeItem(sl()))
    ..registerFactory(() => SearchItems(sl()))
    ..registerFactory(() => GetRecentTags(sl()))
    ..registerFactory(() => GetPostStyles(sl()))
    ..registerFactory(() => PublishPost(sl()))
    ..registerFactory(() => GetSearchDiscovery(sl()))
    ..registerFactory(() => SearchBrandsAndPeople(sl()))
    // Presentation
    ..registerLazySingleton(
      () => SessionCubit(
        restoreSession: sl(),
        watchCurrentUser: sl(),
        signOut: sl(),
      ),
    )
    ..registerFactory(() => SignInCubit(sl()))
    ..registerFactory(() => SignUpCubit(sl()))
    ..registerFactory(() => ForgotPasswordCubit(sl()))
    ..registerFactory(() => SocialSignInCubit(sl()))
    ..registerFactory(() => ProfileSetupCubit(sl()))
    ..registerFactory(() => StyleQuizCubit(sl(), sl()))
    ..registerFactory(() => HomeFeedCubit(sl()))
    // App-wide, so every screen showing a post agrees on likes / saves.
    ..registerLazySingleton(() => PostEngagementCubit(sl(), sl()))
    ..registerFactoryParam<PostDetailCubit, String, void>(
      (postId, _) => PostDetailCubit(sl(), postId: postId),
    )
    ..registerFactoryParam<ProductDetailCubit, String, void>(
      (productId, _) => ProductDetailCubit(sl(), productId: productId),
    )
    ..registerFactoryParam<ProfileCubit, String, void>(
      (userId, _) => ProfileCubit(sl(), userId: userId),
    )
    // App-wide, so a post's Follow and the author's profile agree.
    ..registerLazySingleton(() => FollowingCubit(sl()))
    ..registerFactory(() => SavedPostsCubit(sl()))
    // App-wide, so every "save to wardrobe" control agrees.
    ..registerLazySingleton(() => WardrobeMembershipCubit(sl()))
    ..registerFactory(() => WardrobeCubit(sl()))
    ..registerFactory(() => AddItemCubit(sl()))
    ..registerFactoryParam<WardrobeItemsCubit, String, void>(
      (category, _) => WardrobeItemsCubit(sl(), category: category),
    )
    ..registerFactory(() => MediaPickerCubit(sl()))
    ..registerFactory(() => PostDraftCubit(sl(), sl()))
    ..registerFactory(() => TagSearchCubit(sl(), sl()))
    ..registerFactory(() => SearchCubit(sl(), sl()))
    // App-wide, so screens showing your posts pick up a new one.
    ..registerLazySingleton(PublishedPostsCubit.new);
}
