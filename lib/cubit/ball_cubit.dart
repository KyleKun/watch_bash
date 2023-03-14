import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

class BallCubit extends Cubit<BallState> {
  BallCubit() : super(const BallState.initial());

  void setPosition(double x, double y) {
    emit(BallState(x, y));
  }
}

class BallState extends Equatable {
  const BallState(this.x, this.y);

  const BallState.initial() : this(0.0, 0.0);

  final double x;
  final double y;

  @override
  List<Object?> get props => [x, y];
}
