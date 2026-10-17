import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/presentation/image_source.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/snackbars.dart';
import '../../domain/entities/media.dart';
import '../cubits/media_picker_cubit.dart';
import '../cubits/post_draft_cubit.dart';
import '../gallery_thumbnails.dart';
import '../widgets/discard_guard.dart';
import '../widgets/posting_widgets.dart';

/// Figma: "Screen1-MediaSelection" (2820:76) — the camera roll and the
/// camera. Photo access is asked for once; afterwards the library opens
/// straight away. Styling is PROVISIONAL (from the frame's screenshot).
class MediaSelectionPage extends StatefulWidget {
  const MediaSelectionPage({super.key});

  @override
  State<MediaSelectionPage> createState() => _MediaSelectionPageState();
}

class _MediaSelectionPageState extends State<MediaSelectionPage> {
  late final AppLifecycleListener _lifecycle;
  var _resolving = false;

  @override
  void initState() {
    super.initState();
    // Back from Settings with access granted: show the library.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        final picker = context.read<MediaPickerCubit>();
        if (picker.state.status == MediaPickerStatus.denied) picker.start();
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final l10n = context.l10n;
    setState(() => _resolving = true);
    final path = await context.read<MediaPickerCubit>().chosenFile();
    if (!mounted) return;
    setState(() => _resolving = false);
    if (path == null) return context.showMessage(l10n.errorUnknown);
    context.read<PostDraftCubit>().setPhoto(path);
    context.push(AppRoutes.createTag);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<MediaPickerCubit, MediaPickerState>(
          builder: (context, state) => Stack(
            children: [
              Column(
                children: [
                  PostingTopBar(
                    title: l10n.postingNewPost,
                    onClose: () => closePosting(context),
                    onNext: state.hasChoice && !_resolving ? _next : null,
                  ),
                  const PostingSteps(current: 0),
                  const SizedBox(height: 12),
                  Expanded(child: _body(context, state)),
                ],
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: MediaQuery.paddingOf(context).bottom + 16,
                child: _SourceTabs(
                  onTakePhoto: context.read<MediaPickerCubit>().takePhoto,
                ),
              ),
              if (_resolving)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x33FAFAF7),
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, MediaPickerState state) {
    return switch (state.status) {
      MediaPickerStatus.loading => const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      ),
      MediaPickerStatus.denied => const _AccessDenied(),
      MediaPickerStatus.ready => _Library(state: state),
    };
  }
}

class _Library extends StatelessWidget {
  const _Library({required this.state});

  final MediaPickerState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<MediaPickerCubit>();
    final thumbnails = context.read<GalleryThumbnails>();
    final camera = state.cameraPhotoPath;
    final selected = state.selected;
    final album = state.album;
    final isFirstAlbum = album != null && album == state.albums.firstOrNull;

    return NotificationListener<ScrollNotification>(
      // Load the next page near the end of the grid.
      onNotification: (notification) {
        if (notification.metrics.extentAfter < 400) cubit.loadMore();
        return false;
      },
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverToBoxAdapter(
              // "MainPreview": the chosen photo.
              child: AspectRatio(
                aspectRatio: 350 / 311,
                child: ColoredBox(
                  color: AppColors.surfaceMuted,
                  child: camera != null
                      ? Image(image: imageFromPath(camera), fit: BoxFit.cover)
                      : selected != null
                      ? Image(
                          image: thumbnails.preview(selected),
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        )
                      : null,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // "GalleryHeader": the album, which opens the album list.
                  Semantics(
                    button: true,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: state.albums.length > 1
                          ? () => _pickAlbum(context, state)
                          : null,
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              album == null || isFirstAlbum
                                  ? l10n.postingRecentPhotos
                                  : album.name,
                              style: AppTypography.bodyStrong,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (state.albums.length > 1)
                            const Icon(
                              Icons.expand_more,
                              size: 20,
                              color: AppColors.textPrimary,
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (state.limited) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.postingLimitedAccess,
                            style: AppTypography.captionMuted,
                          ),
                        ),
                        TextButton(
                          onPressed: cubit.manageSelection,
                          child: Text(
                            l10n.postingManage,
                            style: AppTypography.captionStrong.copyWith(
                              color: AppColors.brandRose,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (state.photos.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  l10n.postingNoPhotos,
                  style: AppTypography.body,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  childAspectRatio: 114.67 / 101,
                ),
                itemCount: state.photos.length,
                itemBuilder: (context, index) {
                  final photo = state.photos[index];
                  return _GalleryTile(
                    image: thumbnails.thumbnail(photo),
                    selected: photo == selected && camera == null,
                    onTap: () => cubit.select(photo),
                  );
                },
              ),
            ),
          SliverToBoxAdapter(
            // Room above the floating Camera Roll / Take Photo tabs.
            child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 90),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAlbum(BuildContext context, MediaPickerState state) async {
    final cubit = context.read<MediaPickerCubit>();
    final l10n = context.l10n;
    final album = await showModalBottomSheet<GalleryAlbum>(
      context: context,
      backgroundColor: AppColors.background,
      showDragHandle: true,
      builder: (sheet) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(l10n.postingAlbums, style: AppTypography.subheading),
            ),
            for (final (index, album) in state.albums.indexed)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                title: Text(
                  index == 0 ? l10n.postingRecentPhotos : album.name,
                  style: album == state.album
                      ? AppTypography.bodyStrong
                      : AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                ),
                onTap: () => Navigator.of(sheet).pop(album),
              ),
          ],
        ),
      ),
    );
    if (album != null) await cubit.selectAlbum(album);
  }
}

class _GalleryTile extends StatelessWidget {
  const _GalleryTile({
    required this.image,
    required this.selected,
    required this.onTap,
  });

  final ImageProvider image;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: AppColors.surfaceMuted,
              child: Image(image: image, fit: BoxFit.cover),
            ),
            if (selected) ...[
              // "OverlayMask" and "SelectedCheck".
              const ColoredBox(color: Color(0x33FFFFFF)),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.brandPink,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// No photo access: say why, and offer Settings. Taking a photo still works.
class _AccessDenied extends StatelessWidget {
  const _AccessDenied();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.photo_library_outlined,
              size: 40,
              color: AppColors.textSubtle,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.postingAllowAccessTitle,
              style: AppTypography.subheading,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.postingAllowAccessBody,
              style: AppTypography.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: context.read<MediaPickerCubit>().openSettings,
              child: Text(
                l10n.postingOpenSettings,
                style: AppTypography.bodyStrong.copyWith(
                  color: AppColors.brandRose,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "BottomTabs": Camera Roll (this screen) and Take Photo.
class _SourceTabs extends StatelessWidget {
  const _SourceTabs({required this.onTakePhoto});

  final VoidCallback onTakePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.all(Radius.circular(22)),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              l10n.postingCameraRoll,
              style: AppTypography.bodyStrong,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Semantics(
            button: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTakePhoto,
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: Border.all(color: AppColors.outlineStrong),
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // PROVISIONAL icon until "camera" is exported.
                    const Icon(
                      Icons.photo_camera_outlined,
                      size: 16,
                      color: AppColors.textPrimary,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n.postingTakePhoto,
                        style: AppTypography.bodyStrong,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
