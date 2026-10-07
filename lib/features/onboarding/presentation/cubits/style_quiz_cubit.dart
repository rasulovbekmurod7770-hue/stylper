import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/style_quiz.dart';
import '../../domain/failures/onboarding_failure.dart';
import '../../domain/usecases/onboarding_usecases.dart';

enum StyleQuizStatus { loading, ready, submitting, completed, failure }

final class StyleQuizState extends Equatable {
  const StyleQuizState({
    this.status = StyleQuizStatus.loading,
    this.quiz,
    this.topIndex = 0,
    this.bottomIndex = 0,
    this.failure,
  });

  final StyleQuizStatus status;
  final StyleQuiz? quiz;
  final int topIndex;
  final int bottomIndex;
  final OnboardingFailure? failure;

  OutfitItem? get top => quiz?.tops.elementAtOrNull(topIndex);
  OutfitItem? get bottom => quiz?.bottoms.elementAtOrNull(bottomIndex);

  StyleQuizState copyWith({
    StyleQuizStatus? status,
    StyleQuiz? quiz,
    int? topIndex,
    int? bottomIndex,
    OnboardingFailure? failure,
  }) => StyleQuizState(
    status: status ?? this.status,
    quiz: quiz ?? this.quiz,
    topIndex: topIndex ?? this.topIndex,
    bottomIndex: bottomIndex ?? this.bottomIndex,
    failure: failure,
  );

  @override
  List<Object?> get props => [status, quiz, topIndex, bottomIndex, failure];
}

class StyleQuizCubit extends Cubit<StyleQuizState> {
  StyleQuizCubit(this._getStyleQuiz, this._completeStyleQuiz)
    : super(const StyleQuizState());

  final GetStyleQuiz _getStyleQuiz;
  final CompleteStyleQuiz _completeStyleQuiz;

  Future<void> load() async {
    final result = await _getStyleQuiz(const NoParams());
    if (isClosed) return;
    emit(
      result.match(
        (failure) =>
            StyleQuizState(status: StyleQuizStatus.failure, failure: failure),
        (quiz) => StyleQuizState(status: StyleQuizStatus.ready, quiz: quiz),
      ),
    );
  }

  /// Moves to the next (`step: 1`) or previous (`step: -1`) top, wrapping around.
  void cycleTop(int step) {
    final count = state.quiz?.tops.length ?? 0;
    if (count < 2) return;
    emit(state.copyWith(topIndex: (state.topIndex + step) % count));
  }

  void cycleBottom(int step) {
    final count = state.quiz?.bottoms.length ?? 0;
    if (count < 2) return;
    emit(state.copyWith(bottomIndex: (state.bottomIndex + step) % count));
  }

  Future<void> submit() async {
    final (top, bottom) = (state.top, state.bottom);
    if (top == null || bottom == null) return;
    if (state.status == StyleQuizStatus.submitting) return;

    emit(state.copyWith(status: StyleQuizStatus.submitting));
    final result = await _completeStyleQuiz(
      LikedOutfit(top: top, bottom: bottom),
    );
    if (isClosed) return;
    emit(
      result.match(
        (failure) =>
            state.copyWith(status: StyleQuizStatus.failure, failure: failure),
        (_) => state.copyWith(status: StyleQuizStatus.completed),
      ),
    );
  }
}
