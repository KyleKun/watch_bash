import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'game_cubit.dart';

enum ScoreOwner {
  player,
  cpuLeft,
  cpuRight,
  cpuTop,
}

class ScoreCubit extends Cubit<ScoreState> {
  ScoreCubit() : super(const ScoreState.invisible());

  void reset() {
    emit(const ScoreState.initial());
  }

  void setInvisible() {
    emit(const ScoreState.invisible());
  }

  void decreaseScore(ScoreOwner scoreOwner, BuildContext context) {
    emit(
      ScoreState(
        scoreOwner == ScoreOwner.player
            ? state.playerScore - 1
            : state.playerScore,
        scoreOwner == ScoreOwner.cpuLeft
            ? state.cpuLeftScore - 1
            : state.cpuLeftScore,
        scoreOwner == ScoreOwner.cpuRight
            ? state.cpuRightScore - 1
            : state.cpuRightScore,
        scoreOwner == ScoreOwner.cpuTop
            ? state.cpuTopScore - 1
            : state.cpuTopScore,
      ),
    );

    // Check if player won
    if (state.cpuLeftScore == 0 &&
        state.cpuRightScore == 0 &&
        state.cpuTopScore == 0 &&
        state.playerScore >= 1) {
      final gameCubit = BlocProvider.of<GameCubit>(context);
      gameCubit.won();
    }
  }
}

class ScoreState extends Equatable {
  const ScoreState(
    this.playerScore,
    this.cpuLeftScore,
    this.cpuRightScore,
    this.cpuTopScore,
  );

  static const invisibleScore = -1;
  static const initialScore = 15;

  const ScoreState.invisible()
      : this(invisibleScore, invisibleScore, invisibleScore, invisibleScore);
  const ScoreState.initial()
      : this(initialScore, initialScore, initialScore, initialScore);

  final int playerScore;
  final int cpuLeftScore;
  final int cpuRightScore;
  final int cpuTopScore;

  @override
  List<Object?> get props => [
        playerScore,
        cpuLeftScore,
        cpuRightScore,
        cpuTopScore,
      ];
}
