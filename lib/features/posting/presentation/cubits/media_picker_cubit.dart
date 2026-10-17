import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/media.dart';
import '../../domain/repositories/media_repository.dart';

enum MediaPickerStatus { loading, ready, denied }

final class MediaPickerState extends Equatable {
  const MediaPickerState({
    this.status = MediaPickerStatus.loading,
    this.limited = false,
    this.albums = const [],
    this.album,
    this.photos = const [],
    this.selected,
    this.cameraPhotoPath,
    this.hasMore = false,
  });

  final MediaPickerStatus status;

  /// The user shared only some photos; they can change that ("Manage").
  final bool limited;
  final List<GalleryAlbum> albums;
  final GalleryAlbum? album;
  final List<GalleryPhoto> photos;
  final GalleryPhoto? selected;

  /// A photo just taken with the camera; it wins over [selected].
  final String? cameraPhotoPath;
  final bool hasMore;

  bool get hasChoice => cameraPhotoPath != null || selected != null;

  MediaPickerState copyWith({
    MediaPickerStatus? status,
    bool? limited,
    List<GalleryAlbum>? albums,
    GalleryAlbum? album,
    List<GalleryPhoto>? photos,
    GalleryPhoto? Function()? selected,
    String? Function()? cameraPhotoPath,
    bool? hasMore,
  }) => MediaPickerState(
    status: status ?? this.status,
    limited: limited ?? this.limited,
    albums: albums ?? this.albums,
    album: album ?? this.album,
    photos: photos ?? this.photos,
    selected: selected == null ? this.selected : selected(),
    cameraPhotoPath: cameraPhotoPath == null
        ? this.cameraPhotoPath
        : cameraPhotoPath(),
    hasMore: hasMore ?? this.hasMore,
  );

  @override
  List<Object?> get props => [
    status,
    limited,
    albums,
    album,
    photos,
    selected,
    cameraPhotoPath,
    hasMore,
  ];
}

/// Step 1 of posting: the in-app camera roll and the camera. Photo access is
/// asked for once, the first time; after that the library just opens.
class MediaPickerCubit extends Cubit<MediaPickerState> {
  MediaPickerCubit(this._media) : super(const MediaPickerState());

  final MediaRepository _media;

  static const pageSize = 60;
  var _loadingMore = false;

  /// Checks access (prompting only the first time), then loads the photos.
  Future<void> start() async {
    final access = await _media.requestAccess();
    if (isClosed) return;
    if (access == MediaAccess.denied) {
      return emit(state.copyWith(status: MediaPickerStatus.denied));
    }
    final albums = await _media.albums();
    if (isClosed) return;
    emit(
      state.copyWith(limited: access == MediaAccess.limited, albums: albums),
    );
    if (albums.isEmpty) {
      return emit(
        state.copyWith(status: MediaPickerStatus.ready, photos: const []),
      );
    }
    await _openAlbum(
      state.album != null && albums.contains(state.album)
          ? state.album!
          : albums.first,
    );
  }

  Future<void> selectAlbum(GalleryAlbum album) => _openAlbum(album);

  Future<void> _openAlbum(GalleryAlbum album) async {
    final photos = await _media.photos(album, page: 0, pageSize: pageSize);
    if (isClosed) return;
    final keep = photos.contains(state.selected);
    emit(
      state.copyWith(
        status: MediaPickerStatus.ready,
        album: album,
        photos: photos,
        hasMore: photos.length == pageSize,
        // Start with the newest photo chosen, as in Figma.
        selected: () => keep
            ? state.selected
            : (state.cameraPhotoPath == null ? photos.firstOrNull : null),
      ),
    );
  }

  /// The next page of the current album, when scrolled to the end.
  Future<void> loadMore() async {
    final album = state.album;
    if (album == null || !state.hasMore || _loadingMore) return;
    _loadingMore = true;
    final page = state.photos.length ~/ pageSize;
    final more = await _media.photos(album, page: page, pageSize: pageSize);
    _loadingMore = false;
    if (isClosed) return;
    emit(
      state.copyWith(
        photos: [...state.photos, ...more],
        hasMore: more.length == pageSize,
      ),
    );
  }

  void select(GalleryPhoto photo) =>
      emit(state.copyWith(selected: () => photo, cameraPhotoPath: () => null));

  Future<void> takePhoto() async {
    final path = await _media.takePhoto();
    if (path == null || isClosed) return;
    emit(state.copyWith(cameraPhotoPath: () => path, selected: () => null));
  }

  /// With limited access: change which photos are shared, then reload.
  Future<void> manageSelection() async {
    await _media.manageSelection();
    if (!isClosed) await start();
  }

  Future<void> openSettings() => _media.openSettings();

  /// The chosen photo as a file to post, or null if none is chosen.
  Future<String?> chosenFile() async {
    final camera = state.cameraPhotoPath;
    if (camera != null) return camera;
    final selected = state.selected;
    return selected == null ? null : _media.fileOf(selected);
  }
}
