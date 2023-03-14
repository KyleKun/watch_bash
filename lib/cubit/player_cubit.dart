import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit() : super(PlayerState.initial());

  void setMovement(PlayerMovement movement) {
    emit(PlayerState(movement));
  }

  void setRotaryImpulse(double impulse) {
    final x = state.movement.xPosition + impulse;
    emit(PlayerState(PlayerMovement(xPosition: x, isTouch: false)));
  }
}

class PlayerState extends Equatable {
  const PlayerState(
    this.movement,
  );

  PlayerState.initial() : this(PlayerMovement(xPosition: 0.0));

  final PlayerMovement movement;

  @override
  List<Object?> get props => [movement];
}

class PlayerMovement {
  PlayerMovement({
    required this.xPosition,
    this.isTouch = true,
  });

  final double xPosition;
  final bool isTouch;
}
