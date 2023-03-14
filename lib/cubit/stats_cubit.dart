import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class StatsCubit extends HydratedCubit<StatsState> {
  StatsCubit() : super(const StatsState.initial());

  void lost() {
    emit(state.lost());
  }

  void won() {
    emit(state.won());
  }

  @override
  StatsState? fromJson(Map<String, dynamic> json) {
    final played = json['played'] as int?;
    final won = json['won'] as int?;

    return StatsState(played ?? 0, won ?? 0);
  }

  @override
  Map<String, dynamic>? toJson(StatsState state) {
    return {
      'played': state.matchesPlayed,
      'won': state.matchesWon,
    };
  }
}

class StatsState extends Equatable {
  const StatsState(this.matchesPlayed, this.matchesWon);

  const StatsState.initial() : this(0, 0);

  final int matchesPlayed;
  final int matchesWon;

  StatsState lost() {
    return StatsState(matchesPlayed + 1, matchesWon);
  }

  StatsState won() {
    return StatsState(matchesPlayed + 1, matchesWon + 1);
  }

  @override
  List<Object> get props => [matchesPlayed, matchesWon];
}
