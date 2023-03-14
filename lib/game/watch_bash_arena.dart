// ignore_for_file: unused_field

import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_bloc/flame_bloc.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';

import '../cubit/cubit.dart';
import 'game.dart';

class WatchBashArena extends Forge2DGame {
  WatchBashArena({
    required this.playerCubit,
    required this.gameCubit,
    required this.ballCubit,
    required this.scoreCubit,
  }) : super(gravity: Vector2.zero());

  final PlayerCubit playerCubit;
  final GameCubit gameCubit;
  final BallCubit ballCubit;
  final ScoreCubit scoreCubit;

  late final Player _player;
  late final CPU _cpuLeft;
  late final CPU _cpuTop;
  late final CPU _cpuRight;

  late Timer interval;
  List<Ball> balls = [];

  late FlameMultiBlocProvider flameMultiBlocProvider;

  @override
  Future<void> onLoad() async {
    // Setup the game state
    await add(
      flameMultiBlocProvider = FlameMultiBlocProvider(
        providers: [
          FlameBlocProvider<PlayerCubit, PlayerState>.value(
            value: playerCubit,
          ),
          FlameBlocProvider<GameCubit, GameState>.value(
            value: gameCubit,
          ),
          FlameBlocProvider<BallCubit, BallState>.value(
            value: ballCubit,
          ),
          FlameBlocProvider<ScoreCubit, ScoreState>.value(
            value: scoreCubit,
          ),
        ],
        children: [
          GameStateSyncController(),
          _player = Player(),
          _cpuLeft = CPU(
            position: Vector2(
              2.85,
              size.y / 2.0,
            ),
            side: CPUPosition.left,
            color: Colors.orangeAccent,
          ),
          _cpuTop = CPU(
            position: Vector2(
              size.x / 2.0,
              2.85,
            ),
            side: CPUPosition.top,
            color: Colors.redAccent,
          ),
          _cpuRight = CPU(
            position: Vector2(
              size.x - 2.85,
              size.y / 2.0,
            ),
            side: CPUPosition.right,
            color: Colors.green,
          ),
        ],
      ),
    );

    // Add all the components
    await _initializeGame();
  }

  Future<void> _initializeGame() async {
    // Add walls and scores behind the walls
    const scorePadding = 1.5;
    await add(
      FlameBlocProvider<ScoreCubit, ScoreState>.value(
        value: scoreCubit,
        children: [
          Walls(),
          ScoreText(
            position: Vector2(size.x / 2.0, size.y - scorePadding),
            owner: ScoreOwner.player,
          ),
          ScoreText(
            position: Vector2(size.x / 2.0, scorePadding),
            owner: ScoreOwner.cpuTop,
          ),
          ScoreText(
            position: Vector2(scorePadding, size.y / 2.0),
            owner: ScoreOwner.cpuLeft,
          ),
          ScoreText(
            position: Vector2(size.x - scorePadding / 1.5, size.y / 2.0),
            owner: ScoreOwner.cpuRight,
          ),
        ],
      ),
    );

    // While we do have spawners, they are simply bodies and the actual spawning is done here
    const ballPadding = 4.2;
    final corners = [
      Vector2(ballPadding, ballPadding),
      Vector2(size.x - ballPadding, ballPadding),
      Vector2(ballPadding, size.y - ballPadding),
      Vector2(size.x - ballPadding, size.y - ballPadding),
    ];

    // Spawn a ball each 1.25 seconds
    interval = Timer(1.25, repeat: true, onTick: () async {
      if (!gameCubit.isPlaying) return;

      // Get random position that is one of the corners (spawner padding)
      final randomCorner = corners[Random().nextInt(corners.length)];

      late Ball newBall;

      await add(
        FlameBlocProvider<BallCubit, BallState>.value(
          value: ballCubit,
          children: [
            newBall = Ball(
              radius: 0.44,
              position: randomCorner,
            ),
          ],
        ),
      );

      // So we can keep track of the balls in the game to remove them later
      balls.add(newBall);

      // Add impulse based on the corner
      final randomImpulseFactorX = Random().nextDouble() * 4 - 1;
      final randomImpulseFactorY = Random().nextDouble() * 4 - 1;
      Future.delayed(const Duration(milliseconds: 100), () {
        if (randomCorner == Vector2(ballPadding, ballPadding)) {
          newBall.body.applyLinearImpulse(
              Vector2(5 + randomImpulseFactorX, 2 + randomImpulseFactorY));
        } else if (randomCorner == Vector2(size.x - ballPadding, ballPadding)) {
          newBall.body.applyLinearImpulse(
              Vector2(-5 + randomImpulseFactorX, 2 + randomImpulseFactorY));
        } else if (randomCorner == Vector2(ballPadding, size.y - ballPadding)) {
          newBall.body.applyLinearImpulse(
              Vector2(5 + randomImpulseFactorX, -2 + randomImpulseFactorY));
        } else if (randomCorner ==
            Vector2(size.x - ballPadding, size.y - ballPadding)) {
          newBall.body.applyLinearImpulse(
              Vector2(-5 + randomImpulseFactorX, -2 + randomImpulseFactorY));
        }
      });
    });

    // Add ball spawners at the corners
    const spawnerPadding = 3.3;
    await addAll([
      BallSpawner(
        position: Vector2(spawnerPadding, spawnerPadding),
      ),
      BallSpawner(
        position: Vector2(size.x - spawnerPadding, spawnerPadding),
      ),
      BallSpawner(
        position: Vector2(spawnerPadding, size.y - spawnerPadding),
      ),
      BallSpawner(
        position: Vector2(size.x - spawnerPadding, size.y - spawnerPadding),
      ),
    ]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    interval.update(dt);
  }
}

class GameStateSyncController extends Component
    with HasGameRef<WatchBashArena>, FlameBlocListenable<GameCubit, GameState> {
  GameStateSyncController();

  @override
  void onNewState(GameState state) {
    switch (state) {
      case GameState.initial:
        removeBalls();
        gameRef.scoreCubit.setInvisible();
        gameRef.overlays.clear();
        gameRef.overlays.add('initial');
        break;
      case GameState.playing:
        removeBalls();
        gameRef.scoreCubit.reset();
        gameRef.overlays.clear();
        break;
      case GameState.gameOver:
        gameRef.overlays.clear();
        gameRef.overlays.add('gameOver');
        break;
      case GameState.won:
        gameRef.overlays.clear();
        gameRef.overlays.add('won');
        break;
    }
  }

  void removeBalls() {
    for (Ball ball in gameRef.balls.reversed) {
      ball.removeFromParent();
    }
  }
}
