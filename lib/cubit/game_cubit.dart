import 'package:bloc/bloc.dart';

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState.initial);

  bool get isPlaying => state == GameState.playing;
  bool get isInitial => state == GameState.initial;

  void startGame() {
    emit(GameState.playing);
  }

  void gameOver() {
    emit(GameState.gameOver);
  }

  void won() {
    if (state != GameState.won) {
      emit(GameState.won);
    }
  }

  void reset() {
    emit(GameState.initial);
  }
}

enum GameState {
  initial,
  playing,
  won,
  gameOver,
}
