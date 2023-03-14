import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'widgets.dart';

import '../game/game.dart';
import '../cubit/cubit.dart';

class GameBody extends StatelessWidget {
  const GameBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return const GameWrapper();
      },
    );
  }
}

class GameWrapper extends StatefulWidget {
  const GameWrapper({super.key});

  @override
  State<GameWrapper> createState() => _GameWrapperState();
}

class _GameWrapperState extends State<GameWrapper> {
  late final rotationCubit = context.read<PlayerCubit>();
  late final gameCubit = context.read<GameCubit>();
  late final ballCubit = context.read<BallCubit>();
  late final scoreCubit = context.read<ScoreCubit>();

  late final game = WatchBashArena(
    playerCubit: rotationCubit,
    gameCubit: gameCubit,
    ballCubit: ballCubit,
    scoreCubit: scoreCubit,
  );

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(
              const Size.square(400),
            ),
            child: TouchInputController(
              child: RotaryInputController(
                child: GameWidget(
                  game: game,
                  initialActiveOverlays: const ['initial'],
                  overlayBuilderMap: {
                    'initial': (context, game) {
                      return const InitialOverlay();
                    },
                    'gameOver': (context, game) {
                      return const GameOverOverlay();
                    },
                    'won': (context, game) {
                      return const GameWonOverlay();
                    },
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
