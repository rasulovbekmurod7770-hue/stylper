import 'package:flutter_bloc/flutter_bloc.dart';

/// App-wide: the id of the post the user published last, so screens that
/// stay alive in other tabs (their profile) can refresh.
class PublishedPostsCubit extends Cubit<String?> {
  PublishedPostsCubit() : super(null);

  void published(String postId) => emit(postId);
}
